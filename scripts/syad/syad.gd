extends KinematicBody2D

const UP = Vector2(0, -1)
const WALKING_SPEED = 100
const GRAVITY = 20
const ACCELERATION = 20
const MAX_SPEED = 250
const JUMP_HEIGHT = -600

var motion = Vector2()
var active = false

func activate():
	active = true

func deactivate():
	active = false

func _physics_process(delta):
	if !active:
		return
	var friction = false
	
	motion.y += GRAVITY
	
	if Input.is_action_pressed("ui_right"):
		motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
	
	elif Input.is_action_pressed("ui_left"):
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
	
	else:
		friction = true
	
	if is_on_floor():
		_normal_jump(friction)
	
	motion = move_and_slide(motion, UP, false, 4, PI/4, false)


func _normal_jump(friction : bool)-> void:
	if Input.is_action_just_pressed("ui_up"):
		motion.y = JUMP_HEIGHT
	if friction:
		motion.x = lerp(motion.x, 0, 0.2)
