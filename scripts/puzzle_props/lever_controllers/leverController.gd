extends Node

export var pathToObject : String
export var functionToConnectTo : String
export var signalName : String

signal newSignal

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("newSignal", get_tree().get_root().find_node("pathToObject"), functionToConnectTo)
	pass

