extends Node

const MODULE_FILE_NAME: String = "module.cfg"

class Module:
	# The internal name of the module, used to reference it and its resources.
	var namespace: String
	# Commands are stored as classes for quick access to the console.
	var command_list: Array
	# Entities are stored as paths to conserve memory.
	var entity_list: Array

# Global resource loader - This is important for loading and consolidating
# mods and game extensions, but for now just loads the base res://res directory.

var active_modules: Array = []
var master_module: String

func _ready():
	# Load internal root module - this is the main game.
	Console.debug("Loading main modules.")
	for module in ["res://res/", "res://debug_mod/"]:
		load_module(module)
	
	Console.debug("Searching for user modules in: " + OS.get_user_data_dir())
	var module_file := File.new()
	if module_file.open("user://module_list.txt", File.READ) == OK:
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
	else:
		module_file.open("user://module_list.txt", File.WRITE)
		module_file.store_string(
"""# This is a module configuration file for VuiBui Godot.
# Each line will be treated as the path to a module's root directory within the
# user:// directory (where this file is stored).

# Lines beginning with # are treated as comments.

# Tabs are supported, allowing a cleaner file structure if desired.

""")
	module_file.close()

func load_module(path: String):
	var new_module := Module.new()
	if load_module_info(new_module, path) != OK:
		Console.error("Error loading " + path)
		return
	new_module.command_list = load_command_list(path)
	new_module.entity_list = load_entity_list(path)
	active_modules.append(new_module)
	Console.debug(new_module.namespace + " loaded.")

func collect_files_recursive(path: String) -> Array:
	var files: Array = []
	var dir := Directory.new()
	if dir.open(path) != OK:
		return []
	dir.list_dir_begin()

	while true:
		var file: String = dir.get_next()
		if file == "":
			break
		if not file.begins_with("."):
			if dir.current_is_dir():
				for subfile in collect_files_recursive(path + file):
					files.append(file + "/" + subfile)
			else:
				files.append(file)
	return files

func load_module_info(module: Module, path: String) -> int:
	var module_info := File.new()
	if module_info.open(path + MODULE_FILE_NAME, File.READ) != OK:
		Console.error("Module path \"" + path + "\" is missing a \"" + MODULE_FILE_NAME + "\" file.")
		return FAILED
	
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
				"namespace":
					if source.find(" ") != -1:
						Console.error("Invalid namespace in " + path \
							+ MODULE_FILE_NAME + ", cannot contain spaces.")
						return FAILED
					module.namespace = source
				_:
					Console.error("Invalid assignment in " + path \
						+ MODULE_FILE_NAME + ": " + line)
	
	# Error checking
	if module.namespace.length() == 0:
		Console.error(path + MODULE_FILE_NAME + " is missing a namespace!\nPlease add \"namespace = <module namespace> to the config file.")
		return FAILED
	for active_module in active_modules:
		if active_module.namespace == module.namespace:
			Console.error("Namespace conflict in " + path + MODULE_FILE_NAME + ", namespace is already used.")
			return FAILED
	if is_master:
		if master_module.length() != 0:
			Console.error("Cannot set " + module.namespace + " as master module; overridden by " + master_module)
		else:
			Console.debug("Loading " + module.namespace + " as master module.")
			master_module = module.namespace
	
	return OK

func load_command_list(path: String) -> Array:
	var command_list: Array = []
	path += "commands/"
	for file in collect_files_recursive(path):
		var command: Command = load(path + file)
		# Collect command names from file names.
		command.name = file.get_file().replace("." + file.get_extension(), "")
		command_list.append(command)
	return command_list

func load_entity_list(path: String) -> Array:
	var entity_list: Array = []
	path += "entities/"
	for file in collect_files_recursive(path):
		var file_extension: String = file.get_extension()
		if file_extension == "tscn" or file_extension == "scn":
			entity_list.append(path + file)
	return entity_list

func split_identifier(identifier: String) -> PoolStringArray:
	var splits: PoolStringArray = identifier.split(":", false, 1)
	if splits.size() == 1:
		# Use default namespace if missing
		splits.insert(0, master_module)
	return splits

func get_module(namespace: String) -> Module:
	for module in active_modules:
		if module.namespace == namespace:
			return module
	return null

func get_command(identifier: String) -> Command:
	var split: PoolStringArray = split_identifier(identifier)
	var namespace: String = split[0]
	var target: String = split[1]
	for module in active_modules:
		if module.namespace == namespace:
			for command in module.command_list:
				if command.name == target:
					return command
	return null
