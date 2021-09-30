extends CanvasLayer

onready var output: RichTextLabel = $Output
onready var command: LineEdit = $CommandInput

var debug_enabled: bool = OS.is_debug_build()
var history: Array

func _ready() -> void:
	output.bbcode_text = ""
	command.connect("text_entered", self, "process_command")

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("console_command"):
		yield(get_tree(), "idle_frame")
		toggle_command_input()
	if Input.is_action_just_pressed("ui_up") and command.has_focus():
		if history.size():
			command.text = history.pop_back()

func print(line: String) -> void:
	output.bbcode_text += "\n [color=red]$ [/color]" + line

func error(line: String) -> void:
	output.bbcode_text += "\n [color=red]$ Error: [/color]" + line

func debug(line: String) -> void:
	if debug_enabled:
		output.bbcode_text += "\n [color=fuchsia]$ Debug: [/color]" + line

func toggle_command_input() -> void:
	command.text = ""
	command.visible = not command.visible
	for player in get_tree().get_nodes_in_group(GroupConstants.PLAYER_GROUP):
		player.disable_input = not player.disable_input
	if command.visible:
		command.grab_focus()

func process_command(input: String) -> void:
	if not input:
		return
	if not history.size() or history[history.size() - 1] != input:
		history.append(input)

	output.bbcode_text += "\n [color=blue]~ [/color]" + input
	# Parse the input string.
	# If there is only one token.
	var tokens: Array = []
	var last_space: int = 0

	while input.find(" ", last_space + 1) != -1:
		var next_space: int = input.find(" ", last_space + 1)
		tokens.push_back(input.substr(last_space, next_space - last_space))
		last_space = next_space + 1
	tokens.push_back(input.substr(last_space, input.length() - last_space))

	# Match first token
	var main_token: String = tokens.pop_front()
	var command_found: bool = false
	for console_command in ResourceManager.command_list:
		if main_token == console_command.name:
			command_found = true
			var valid: bool = false
			for argc in console_command.arguments:
				if argc == tokens.size():
					valid = true
			if valid:
				console_command._execute(tokens)
				break
			else:
				Console.error("Invalid number of arguments for command \"" + main_token + "\".")
	if not command_found:
		Console.error("Command \"" + main_token + "\" not found.")

	toggle_command_input()
