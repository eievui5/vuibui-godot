extends Node2D

# Root node for managing the game world.

onready var objects = $Objects

var active_cells: Array
var active_entities: Array
var active_player: Entity
# Index of the current detector.
var detector_index: int = 0

func _physics_process(delta: float) -> void:
	# Run all active entities' logic.
	for entity in active_entities:
		if not is_instance_valid(entity):
			active_entities.erase(entity)
			continue
		entity._logic_process(delta)

	# Run a single entity's detection each frame; improves performance at the
	# cost of a slower update time.
	if active_entities.size() > detector_index:
		if is_instance_valid(active_entities[detector_index]):
			active_entities[detector_index]._detect_entities()
			detector_index += 1
	else:
		detector_index = 0

func add_cell(cell_path: String):
	var new_cell = ResourceManager.get_cell(cell_path).instance()

	add_child(new_cell)
	move_child(new_cell, 0)
	active_cells.append(new_cell)

func remove_cell(cell):
	active_cells.remove(cell)
	cell.free()

func spawn_entity(entity_path: String) -> Entity:
	var new_entity = ResourceManager.get_entity(entity_path).instance()

	active_entities.append(new_entity)
	objects.add_child(new_entity)
	return new_entity
