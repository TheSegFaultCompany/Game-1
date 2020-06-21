extends KinematicBody2D

onready var front_check = $FrontCheck
onready var low_mid_check = $LowMidCheck
onready var high_mid_check = $HgihMidCheck
onready var back_check = $BackCheck

onready var front_legs = $FrontLegs.get_children()
onready var back_legs = $BackLegs.get_children()

export var x_speed = 20
export var y_speed = 40

export var step_rate = 0.6
export var playerDetectDistance = 190
var time_since_last_check = 0
var cur_f_leg = 0
var cur_b_leg = 0
var use_front = false
var player
 
func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	front_check.force_raycast_update()
	back_check.force_raycast_update()
	for i in range(4):
		step()

# Update the position of the character
func _physics_process(delta):
	var move_vec = Vector2(x_speed, 0)
	if high_mid_check.is_colliding():
		move_vec.y = -y_speed
	elif !low_mid_check.is_colliding():
		move_vec.y = y_speed
	move_and_collide(move_vec * delta)

# Function to move a step through the world
func _process(delta):
	time_since_last_check += delta
	if time_since_last_check >= step_rate:
		time_since_last_check = 0
		step()
	if player_in_range() and !player.dead:
		front_legs[0].attack(player)

func player_in_range():
	var space_state = get_world_2d().direct_space_state
	if global_position.distance_to(player.global_position) > playerDetectDistance:
		return false
	var result = space_state.intersect_ray(global_position, player.global_position, [], collision_mask)
	if result:
		return true
	return false

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
