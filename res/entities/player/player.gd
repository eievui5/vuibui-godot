extends Entity

const ACCELERATION: float = 64.0 * 30.0
const SPEED: float = 64.0

onready var weapon: Weapon = $Weapon

# Disable the player's input but continue to process logic.
var disable_input: bool = false

func _ready():
	add_to_group(GroupConstants.PLAYER_GROUP)
	weapon.connect("contact", self, "_weapon_contact")

func _logic_process(delta: float) -> void:
	var input_vector: Vector2
	if not disable_input:
		if not weapon.attacking:
			if Input.is_action_just_pressed("game_action"):
				weapon.rotation = get_angle_to(get_global_mouse_position()) \
					+ PI / 2
				weapon.use()
			input_vector = Vector2(
				Input.get_action_strength("game_right")
				- Input.get_action_strength("game_left"),
				Input.get_action_strength("game_down")
				- Input.get_action_strength("game_up")
			) * SPEED
	velocity = velocity.move_toward(input_vector, ACCELERATION * delta)
	._logic_process(delta)

func _weapon_contact(body: Entity) -> void:
	if body == self:
		return
	
	var damage = Damage.new(10.0)
	damage.source = self
	body.take_damage(damage)
