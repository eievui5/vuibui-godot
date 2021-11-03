extends Node

func _ready() -> void:
	# Load the master module's newgame cell.
	Worldspace.add_cell(ResourceManager.master_module.newgame_cell)

	# Create a player and spawn it into the world.
	var player: Entity = Worldspace.spawn_entity("player")
	Worldspace.active_player = player

	# Assign a camera to the player.
	var camera := Camera2D.new()
	camera.zoom = Vector2(0.3, 0.3)
	camera.current = true
	camera.smoothing_enabled = true
	player.add_child(camera)
