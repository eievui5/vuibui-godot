extends Entity

const ACCELERATION: float = 64.0 * 30.0
const SPEED: float = 60.0

# Disable the player's input but continue to process logic.
var disable_input: bool = false
var weapon: Weapon
var weapon_item: WeaponItem

func _ready():
	weapon_item = ResourceManager.get_item("debug_weapon")

	if weapon_item:
		weapon = weapon_item.instance_weapon()
		add_child(weapon)
		weapon.show_behind_parent = true
		weapon.connect("contact", self, "_weapon_contact")

func _logic_process(delta: float) -> void:
	var input_vector: Vector2

	if not disable_input:
		if not weapon or not weapon.attacking:
			if weapon and Input.is_action_just_pressed("game_action"):
				weapon.rotation = get_angle_to(get_global_mouse_position()) + PI / 2
				weapon.use()

			input_vector = SPEED * Vector2(
				Input.get_action_strength("game_right") - Input.get_action_strength("game_left"),
				Input.get_action_strength("game_down") - Input.get_action_strength("game_up"))

	velocity = velocity.move_toward(input_vector, ACCELERATION * delta)
	._logic_process(delta)

func _weapon_contact(body: Entity) -> void:
	if body == self:
		return

	var damage = Damage.new(10.0)
	damage.source = self
	body.take_damage(damage)
