class_name Entity
extends KinematicBody2D

export var detection_radius: float = 24.0
export var health: float = 100.0

onready var DetectionArea := Area2D.new()

var detected_entities: Array
var knockback: Vector2
var velocity: Vector2

func _ready() -> void:
	collision_layer = CollisionConstants.ENTITY
	collision_mask = CollisionConstants.WORLD
	DetectionArea.collision_layer = 0
	DetectionArea.collision_mask = CollisionConstants.ENTITY
	var detection_shape := CollisionShape2D.new()
	detection_shape.shape = CircleShape2D.new()
	detection_shape.shape.radius = detection_radius
	add_child(DetectionArea)
	DetectionArea.add_child(detection_shape)
	add_to_group(GroupConstants.ENTITY_GROUP)

func _logic_process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, delta * 600.0)
	move_and_slide(velocity + knockback)

func _detect_entities() -> void:
	var nearby_entities: Array = DetectionArea.get_overlapping_bodies()
	nearby_entities.erase(self)
	detected_entities = nearby_entities

func take_damage(damage: Damage) -> void:
	var note := DamageNote.new(global_position, damage)
	get_tree().root.add_child(note)
	health -= damage.magnitude
	if damage.source:
		knockback = (
			global_position - damage.source.global_position
		).normalized() * 200.0
	if health <= 0:
		death()

func death() -> void:
	queue_free()
