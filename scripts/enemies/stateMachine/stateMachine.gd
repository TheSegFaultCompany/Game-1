extends Node

class_name stateMachine

onready var States = {
	"Idle" : $Idle,
	"Patrol" : $Patrol,
	"Player Spotted" : "Subnode",
	"Chase" : "Subnode",
	"Attack" : "Subnode",
	"Lost Player" : "Subnode",
	"Search" : "Subnode"
}

var stateStack : Array

func _ready():
	stateStack.push_front(States.get("Idle"))
	stateStack.push_front(States.get("Patrol"))

func _physics_process(_delta):
	if (stateStack.front().has_method("move_player")):
		stateStack.front().move_player(_delta)
