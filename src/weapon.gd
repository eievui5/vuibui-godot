class_name Weapon
extends Node2D

# This signal is a capsule to combine all child areas' signals into a single,
# root-level signal.
# warning-ignore:unused_signal
signal contact(body)

var animation_player: AnimationPlayer
var animation_list: PoolStringArray
var attacking: bool = false

func _ready() -> void:
	for child in get_children():
		if child is AnimationPlayer:
			animation_player = child
			animation_list = animation_player.get_animation_list()
			animation_player.connect("animation_started", self, "_animation_started")
			animation_player.connect("animation_finished", self, "_animation_finished")
		if child is Area2D:
			child.connect("body_entered", self, "_body_entered")
	assert(animation_player)

func use() -> void:
	animation_player.play(animation_list[randi() % animation_list.size()])

func _body_entered(body: Entity):
	emit_signal("contact", body)

func _animation_started(_anim_name: String) -> void:
	attacking = true

func _animation_finished(_anim_name: String) -> void:
	attacking = false
