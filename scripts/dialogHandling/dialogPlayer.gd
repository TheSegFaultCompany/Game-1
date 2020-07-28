extends Node

class_name DialoguePlayer

signal started
signal finished

onready var title : String = ""
onready var text : String = ""
onready var responses : String = ""
onready var finished = true

var _conversation : Array
var _index_current = 0
var optionsArray : Array
var jumpArray : Array

func _ready():
	connect("finished", get_tree().get_nodes_in_group("player")[0], "dialogue_finished")
	connect("started", get_tree().get_nodes_in_group("player")[0], "dialogue_started")

func start(dialogue_dic) -> void:
	# Takes the dictionary of conservation data returned from Dialogue.load()
	# and stores it in an array
	emit_signal("started")
	_conversation = dialogue_dic.values()
	_index_current = 0
	finished = false
	_update()

func next(newLine : int):
	_index_current = newLine
	if(_index_current >= _conversation.size()):
		emit_signal("finished")
		return
	_update()

func get_name()->String:
	return title

func _input(event):
	if event is InputEventKey and event.pressed:
		if optionsArray.size() >= 1 and event.scancode == KEY_A:
			next(jumpArray[0])
		if optionsArray.size() >= 2 and event.scancode == KEY_S:
			next(jumpArray[1])
		if optionsArray.size() >= 3 and event.scancode == KEY_D:
			next(jumpArray[2])

func _update():
	text = _conversation[_index_current].text
	title = _conversation[_index_current].name
	optionsArray = _conversation[_index_current].options
	jumpArray = _conversation[_index_current].nextValue
	if optionsArray.size() == 1:
		responses = "[A] " + optionsArray[0]
	elif optionsArray.size() == 2:
		responses = "[A] " + optionsArray[0] + " [S] " + optionsArray[1]
	elif optionsArray.size() == 3:
		responses = "[A] " + optionsArray[0] + " [S] " + optionsArray[1] + " [D] " + optionsArray[2]
	var control = get_parent()
	control.update_content()
 
