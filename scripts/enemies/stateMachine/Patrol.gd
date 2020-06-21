extends Node

# Constants used
const UP = Vector2(0, -1)
const GRAVITY = 20
const SPEED = 50
const MAX_SPEED = 100
const ACCELERATION = 50

# Onready variable required for calculations and movement
onready var anim : KinematicBody2D = get_parent()
onready var player = get_tree().get_nodes_in_group("player").front()
onready var sprite = get_parent().get_node("AnimatedSprite")
onready var rayCast = get_parent().get_node("RayCast2D")
onready var turnTimer = get_parent().get_node("TurnTimer")

# Variables used in the function
var motion = Vector2()
var turnAbility = true
var direction = 1

# Function called by the StateMachine
func move_player(_delta):
	# Flip the sprite based on the movement direction
	if direction == 1:
		sprite.flip_h = false
		motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
	else:
		sprite.flip_h = true
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
	
	# Add the gravity vector to the enemy
	motion.y += GRAVITY
	if anim.is_on_floor():
		motion.y = 0
	
	# Turn the character around if it's interacting with the wall
	if anim.is_on_wall() and turnAbility == true:
		direction *= -1
		rayCast.position.x *= -1
		turnTimer.start()
		turnAbility = false
	
	# Turn the character arround if it's walking off a ledge
	if rayCast.is_colliding() == false:
		direction *= -1
		rayCast.position.x *= -1
	
	# Play the walking animation
	sprite.play("Walking")
	anim.move_and_slide(motion, UP)

# Resetting the turn around timer
func _on_TurnTimer_timeout():
	turnAbility = true
