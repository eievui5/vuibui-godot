class_name DamageNote
extends Node2D

const LIFETIME: float = 1.0
const SCALE: float = 0.7
const SCALETIME: float = 0.1

var damage: Damage
var timer: float = 0.0

func _init(_position: Vector2, _damage: Damage) -> void:
	global_position = _position
	damage = _damage
	scale = Vector2.ZERO

func _ready() -> void:
	var label := Label.new()
	label.align = Label.ALIGN_CENTER
	label.valign = Label.VALIGN_CENTER
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label.grow_vertical = Control.GROW_DIRECTION_BOTH
	label.rect_size = Vector2.ZERO
	label.text = String(int(ceil(damage.magnitude)))
	add_child(label)

func _process(delta: float) -> void:
	if timer < SCALETIME:
		scale = scale.move_toward(Vector2(SCALE, SCALE), SCALE / SCALETIME * delta)
	position.y -= delta * 5.0
	timer += delta
	if timer > LIFETIME - SCALETIME:
		scale = scale.move_toward(Vector2.ZERO, SCALE / SCALETIME * delta)
	if timer >= LIFETIME:
		queue_free()
