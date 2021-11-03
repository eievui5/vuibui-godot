# Global resource manager to facilitate loading assets from "floating" modules.
# All modules are loaded here either from an interal module list or a list
# in the user:// directory. This allows the user to load custom modules to
# modify the game.

extends Node

const MAIN_MODULES: Array = ["res://res/"]
const MODULE_FILE_NAME: String = "module.cfg"

const MODULE_FILE_TEXT: String = \
"""#
# This is a module configuration file for VuiBui Godot.
# Each line will be treated as the path to a module's root directory within the
# user:// directory (where this file is stored).
#
# Modules are loaded from top to bottom, meaning the lowest module will override
# the changes made by the highest module, should any conflicts arise.
#
# Lines beginning with # are treated as comments.
#
# Tabs are supported, allowing a cleaner file structure if desired.
#
"""

# This is mostly deprecated and should be refactored into a more refined,
# central structure. (See below)
class Module:
	# The internal name of the module, used to reference it and its resources.
	var namespace: String
	var newgame_cell: String
	var root_path: String

# The module which is currently "in charge" of the engine. This determines what
# happens when starting a new game and is tied to the save file. Basically, this
# IS the game.
var master_module: Module
# Other loaded modules, and their related data.
var active_modules: Dictionary

# Dictionaries of resource names and paths, used to quickly look up module
# resources without needing a full path.
var cell_list: Dictionary
var command_list: Dictionary
var entity_list: Dictionary
# gfx_list is ommited because users do not need to access graphics.
var item_list: Dictionary

func _ready():
	# Load internal root module - this is the main game.
	Console.debug("Loading main modules.")
	for module in MAIN_MODULES:
		load_module(module)

	Console.debug("Searching for user modules in: " + OS.get_user_data_dir())

	var module_file := File.new()
	var open_error = module_file.open("user://module_list.txt", File.READ)
	if open_error == OK:
		#
		while not module_file.eof_reached():
			var module_path: String = module_file.get_line()

			module_path = module_path.strip_edges()
			if module_path.length() == 0 or module_path.begins_with("#"):
				continue
			if not module_path.ends_with("/"):
				module_path += "/"
			Console.debug("Loading module: " + String(module_path))
			module_path = "user://" + module_path
			load_module(module_path)
	elif open_error == ERR_FILE_NOT_FOUND:
		# If the module file could not be found, write a default file for the
		# user.
		module_file.open("user://module_list.txt", File.WRITE)
		module_file.store_string(MODULE_FILE_TEXT)
	else:
		# Otherwise we have a genuine error, and should let the user know.
		Console.error("Could not open module_list.txt.")
	module_file.close()

	# Now collect references to the loaded resources.
	construct_res_list("res://res/cells/", cell_list)
	construct_res_list("res://res/commands/", command_list)
	construct_res_list("res://res/entities/", entity_list)
	construct_res_list("res://res/items/", item_list)

func construct_res_list(path: String, dest: Dictionary) -> void:
	for i in collect_files_recursive(path):
		i = path + i
		dest[i.get_file().replace("." + i.get_extension(), "")] = i

func load_module(path: String) -> void:
	var new_module := Module.new()

	var module_info := File.new()
	if module_info.open(path + MODULE_FILE_NAME, File.READ) != OK:
		Console.error("Could not find a \"" + MODULE_FILE_NAME + "\" file in" + path)
		return

	var is_master: bool = false

	while not module_info.eof_reached():
		var line: String = module_info.get_line()

		if line.find("=") != -1:
			var expression: PoolStringArray = line.split("=", false, 1)
			var destination: String = expression[0].strip_edges()
			var source: String = expression[1].strip_edges()

			match destination:
				"master":
					is_master = source == "true"
				"name":
					if source.find(" ") != -1:
						Console.error("Invalid name in " + path + MODULE_FILE_NAME + ", cannot contain spaces.")
						return

					new_module.namespace = source
				"resources":
					ProjectSettings.load_resource_pack(source)
				"newgame_cell":
					new_module.newgame_cell = source
				_:
					Console.error("Invalid assignment in " + path + MODULE_FILE_NAME + ": " + line)
		else:
			Console.error("Unrecognized line \"" + line + "\"in " + path + MODULE_FILE_NAME + ".")

	# Error checking
	if new_module.namespace.length() == 0:
		Console.error(path + MODULE_FILE_NAME + " is missing a name!\nPlease add \"name = <module name> to the config file.")
		return
	for i in active_modules:
		if i == new_module.namespace:
			Console.error("Naming conflict in " + path + MODULE_FILE_NAME + ", name is already used.")
			return
	if is_master:
		if master_module != null:
			Console.error("Cannot set " + new_module.namespace + " as master module; overridden by " + master_module.namespace + ".")
		else:
			Console.debug("Loading " + new_module.namespace + " as master module.")
			master_module = new_module

	new_module.root_path = path

	active_modules[new_module.namespace] = new_module
	Console.debug(new_module.namespace + " loaded.")

# Recursively collect all paths to all files in a given directory.
func collect_files_recursive(path: String) -> Array:
	var files: Array = []
	var dir := Directory.new()

	# If the directory does not exist, do not return any files.
	if dir.open(path) != OK:
		return []

	dir.list_dir_begin()
	while true:
		var file: String = dir.get_next()

		if file == "":
			break

		# Ignore hidden files and navigation paths ("." and "..")
		if not file.begins_with("."):
			# If a directory is found, just run this function again to collect
			# its files.
			if dir.current_is_dir():
				files.append_array(collect_files_recursive(path + "/" + file))
			else:
				files.append(file)
	return files

func get_cell(identifier: String):
	if not cell_list.has(identifier):
		return null
	return load(cell_list[identifier])

func get_command(identifier: String) -> Command:
	if not command_list.has(identifier):
		return null
	return command_list[identifier]

func get_entity(identifier: String) -> Entity:
	if not entity_list.has(identifier):
		return null
	return load(entity_list[identifier]).instance() as Entity

func get_item(identifier: String) -> InvItem:
	if not item_list.has(identifier):
		return null
	return load(item_list[identifier]) as InvItem
