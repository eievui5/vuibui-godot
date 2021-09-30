class_name Damage
extends Resource

# The strength of the damage, or in other words, how much damage is done.
var magnitude: float
# A list of customizable properties.
var properties: Dictionary
# The entity where the damage originated; can be null.
var source: Node2D = null

func _init(_magnitude: float):
	magnitude = _magnitude
