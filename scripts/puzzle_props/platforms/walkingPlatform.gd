extends Node2D

onready var front_check = $KinematicBody2D/FrontCheck
onready var back_check = $KinematicBody2D/BackCheck

onready var front_legs = $KinematicBody2D/FrontLegs.get_children()
onready var back_legs = $KinematicBody2D/BackLegs.get_children()

export var x_speed = 80
export var y_speed = 40
export var move_to = Vector2()

export var step_rate = 0.6
var time_since_last_check = 0
var cur_f_leg = 0
var cur_b_leg = 0
var use_front = false
onready var tween = $KinematicBody2D/Tween

var follow = Vector2.ZERO

func _ready():
	front_check.force_raycast_update()
	back_check.force_raycast_update()
	for i in range(4):
		step()
	var duration = move_to.length()
	tween.interpolate_property(self, "follow", Vector2.ZERO, move_to, 15.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 1.0)
	tween.interpolate_property(self, "follow", move_to, Vector2.ZERO, 15.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 15.0 + 1.0)
	tween.start()

func _physics_process(delta):
	$KinematicBody2D.position = $KinematicBody2D.position.linear_interpolate(follow, 0.075)

# Function to move a step through the world
func _process(delta):
	time_since_last_check += delta
	if time_since_last_check >= step_rate:
		time_since_last_check = 0
		step()

# Function for each step taken
func step():
	var leg = null
	var sensor = null
	if use_front:
		leg = front_legs[cur_f_leg]
		cur_f_leg += 1
		cur_f_leg %= front_legs.size()
		sensor = front_check
	else:
		leg = back_legs[cur_b_leg]
		cur_b_leg += 1
		cur_b_leg %= back_legs.size()
		sensor = back_check
	use_front = !use_front
	
	var target = sensor.get_collision_point()
	leg.step(target)
