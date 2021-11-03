class_name Command
extends Resource

# An array of valid argument counts.
export(Array, int) var arguments: Array = [0]
# A description of the command. If this is empty, the command will be hidden
# from the help command.
export var description: String

func _execute(_arguments: Array) -> void:
	Console.error("Missing an execution function.")
