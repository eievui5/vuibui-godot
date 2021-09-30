extends Node

# Global resource loader - This is important for loading and consolidating
# mods and game extensions, but for now just loads the base res://res directory.

# Commands are stored as classes for quick access to the console.
var command_list: Array
# Entities are stored as paths to conserve memory.
var entity_list: Array

func _ready():
	load_command_list("res://res/")
	load_entity_list("res://res/")

func collect_files_recursive(path: String) -> Array:
	var files: Array = []
	var dir := Directory.new()
	dir.open(path)
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
