extends Node

# Index of the current detector.
var detector_index: int = 0

func _ready() -> void:
	yield(get_tree(), "idle_frame")
	var player: Entity = load("res://res/entities/player/player.tscn").instance()
	get_tree().root.add_child(player)
	var camera := Camera2D.new()
	camera.zoom = Vector2(0.3, 0.3)
	camera.current = true
	camera.smoothing_enabled = true
	player.add_child(camera)

func _physics_process(delta: float) -> void:
	# Grab all entities
	var active_entities: Array = get_tree().get_nodes_in_group(GroupConstants.ENTITY_GROUP)
	# Run all active entities' logic.
	for entity in active_entities:
		(entity as Entity)._logic_process(delta)
	# Run a single entity's detection each frame; improves performance at the
	# cost of a slower update time.
	if active_entities.size() > detector_index:
		(active_entities[detector_index] as Entity)._detect_entities()
		detector_index += 1
	else:
		detector_index = 0
