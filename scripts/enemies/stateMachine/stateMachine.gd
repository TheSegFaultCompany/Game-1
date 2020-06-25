extends KinematicBody2D

class_name stateMachine

onready var States = {
	"Idle" : $Idle,
	"Patrol" : $Patrol,
	"Player Spotted" : "Subnode",
	"Chase" : $Chase,
	"Attack" : "Subnode",
	"Lost Player" : "Subnode",
	"Search" : "Subnode"
}

var stateStack : Array
var playerDetection = null
onready var Player = get_tree().get_node("Player")
export var eye_reach = 90
export var vision = 600

func _ready():
	stateStack.push_front(States.get("Idle"))
	stateStack.push_front(States.get("Patrol"))

func _physics_process(_delta):
	if (stateStack.front().has_method("move_player")):
		stateStack.front().move_player(_delta)

func _process(_delta):
	if sees_player():
		stateStack.push_front("Chase")

#Function to check if the enemy can see the player
func sees_player():
	#Create the four eyes around the enemy
	var eye_center = get_global_position()
	var eye_top = eye_center + Vector2(0, -eye_reach)
	var eye_left = eye_center + Vector2(-eye_reach, 0)
	var eye_right = eye_center + Vector2(eye_reach, 0)
	
	#Create the extent shapes around the player
	var player_pos = Player.get_global_position()
	var player_extents = Player.get_node("CollisionShape2D").shape.extents
	var top_left = player_pos + Vector2(-player_extents.x, -player_extents.y)
	var top_right = player_pos + Vector2(player_extents.x, -player_extents.y)
	var bottom_left = player_pos + Vector2(-player_extents.x, player_extents.y)
	var bottom_right = player_pos + Vector2(player_extents.x, player_extents.y)
	
	var space_states = get_world_2d().direct_space_state
	
	#Check if the view is obstructed
	for eye in [eye_center, eye_top, eye_left, eye_right]:
		for cornor in [top_left, top_right, bottom_left, bottom_right]:
			if (cornor - eye).length() > vision:
				continue
			var collision = space_states.intersect_ray(eye, cornor, [], 1)
			if collision and collision.collider.name == "Player":
				return true
	return false
