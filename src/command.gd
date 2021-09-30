class_name Command
extends Resource

export(Array, int) var arguments: Array = [0]
export var description: String

var name: String = ""

func _execute(_arguments: Array) -> void:
	Console.error("Command \"" + name + "\" is missing an execution function.")
