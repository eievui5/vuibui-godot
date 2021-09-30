extends Node

# Global resource loader - This is important for loading and consolidating
# mods and game extensions, but for now just loads the base res://res directory.

# Commands are stored as classes for quick access to the console.
var command_list: Array
# Entities are stored as paths to conserve memory.
var entity_list: Array

func _ready():
	# Load internal root module - this is the main game.
	load_module("res://res/")
	
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
	load_command_list(path)
	load_entity_list(path)

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

func load_command_list(path: String) -> void:
	path += "commands/"
	for file in collect_files_recursive(path):
		var command: Command = load(path + file)
		# Collect command names from file names.
		command.name = file.get_file().replace("." + file.get_extension(), "")
		command_list.append(command)

func load_entity_list(path: String) -> void:
	path += "entities/"
	for file in collect_files_recursive(path):
		var file_extension: String = file.get_extension()
		if file_extension == "tscn" or file_extension == "scn":
			entity_list.append(path + file)
