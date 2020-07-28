extends Control

signal dialogue_ended()

onready var dialogue_player = $DialogPlayer

onready var name_label := get_node("Panel/Panel2/Name")
onready var text_label := get_node("Panel/Text")
onready var response_label := $Panel/PlayerInput

onready var portrait := $Portrait as TextureRect

func start(dialogue: Dictionary) -> void:
	"""
	Reinitializes the UI and asks the dialog player to
	play the dialog
	"""
	dialogue_player = $DialogPlayer
	dialogue_player.start(dialogue)
	update_content()
	show()

func finish()->void:
	hide()

func _input(event):
	if event is InputEventKey and event.scancode == KEY_E:
		$AnimationPlayer.stop(true)
		$Panel/Text.percent_visible = 1.00
		$AnimationPlayer2.stop(true)
		$Panel/PlayerInput.percent_visible = 1.00

func update_content() -> void:
	$AnimationPlayer.stop(true)
	var dialogue_player_name = dialogue_player.get_name()
	var database = DialogueDatabase.new()
	database._ready()
	name_label = get_node("Panel/Panel2/Name")
	text_label = get_node("Panel/Text")
	response_label = $Panel/PlayerInput
	portrait = $Portrait as TextureRect
	
	name_label.text = dialogue_player_name
	text_label.text = dialogue_player.text
	response_label.text = dialogue_player.responses
	$AnimationPlayer.play("spellOutLetterByLetter")
	portrait.texture = database.get_texture(dialogue_player_name)
