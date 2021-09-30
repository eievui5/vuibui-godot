extends Entity

func _ready() -> void:
	$Area2D.connect("body_entered", self, "_body_entered")

func _logic_process(delta: float) -> void:
	var target_position: Vector2
	if detected_entities.size() > 0 and is_instance_valid(detected_entities[0]):
		target_position = (detected_entities[0].global_position
			- global_position).normalized() * 12.0
	velocity = velocity.move_toward(target_position, delta * 64.0 * 30.0)
	._logic_process(delta)

func _body_entered(body: Entity) -> void:
	if body == self:
		return;
	var damage = Damage.new(10.0)
	damage.source = self
	body.take_damage(damage)
