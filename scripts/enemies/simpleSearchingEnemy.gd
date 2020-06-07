extends enemy

const UP = Vector2(0, -1)
const ACCELERATION = 50
const MAX_SPEED_WALKING = 50
const MAX_CHASE_SPEED = 300
const GRAVITY = 20

var motion = Vector2(0, GRAVITY)
var direction = 1

onready var right_floor = $RightFloorCheck
onready var left_floor = $LeftFloorCheck
onready var right_search = $RightSearchRay
onready var left_search = $LeftSearchRay
onready var right_coll = $RightMovementCollision
onready var left_coll = $LeftMovementCollision
export var ghost_dimension = true
var ghost = ghost_dimension

func _ready():
	if (ghost_dimension == true):
#		_deactivate_node()
#		set_physics_process(false)
		_change_collision()
		self.hide()

# Function to flip the character and set the collisions properly
func flip_character():
	if direction == 1:
		direction *= -1
		right_coll.set_disabled(true)
		right_floor.set_enabled(false)
		right_floor.set_enabled(false)
		
		left_coll.set_disabled(false)
		left_floor.set_enabled(true)
		left_search.set_enabled(true)
		$AnimatedSprite.set_flip_h(true)
	else:
		direction *= -1
		right_coll.set_disabled(false)
		right_floor.set_enabled(true)
		right_floor.set_enabled(true)
		
		left_coll.set_disabled(true)
		left_floor.set_enabled(false)
		left_search.set_enabled(false)
		$AnimatedSprite.set_flip_h(false)

# Main movement mechanics
func _physics_process(_delta):
	motion.y += GRAVITY
	if (is_on_floor()):
		motion.y = 0
	
	if (direction == 1 and _check_player(right_search) and ghost != ghost_dimension):
		motion.x = 2*MAX_SPEED_WALKING
		$AnimatedSprite.play("spotted")
		# Code for detecting and chasing the player goes here
	elif (direction == -1 and _check_player(left_search) and ghost != ghost_dimension):
		motion.x = 2*MAX_SPEED_WALKING
		#$AnimatedSprite.play("spotted")
	else:
		$AnimatedSprite.play("walking")
		motion.x = MAX_SPEED_WALKING
	if ((right_floor.is_enabled() and !right_floor.is_colliding()) or (left_floor.is_enabled() and !left_floor.is_colliding())):
		flip_character()
	motion.x *= direction
	move_and_slide(motion, Vector2(0, -1))

# Function to deactivate all the collision in the node, for full deactivation
func _deactivate_node():
	right_coll.set_disabled(true)
	right_floor.set_enabled(false)
	right_floor.set_enabled(false)
	left_coll.set_disabled(true)
	left_floor.set_enabled(false)
	left_search.set_enabled(false)

# Set the collision to not collide with the player, shifted to another layer
func _change_collision():
	self.set_collision_layer_bit(0, false)
	self.set_collision_mask_bit(0, false)

# Set the collision mask correctly for the player to collide with the enemy
func _activate_collision():
	self.set_collision_layer_bit(0, true)
	self.set_collision_mask_bit(0, true)

# Function to deactivate the node based on if the character is in the right dimension
# The patrol route isn't changed or deactivated, just the collision between the player
# and the enemy is returned.
func _on_Player_turnOnShader():
	if (ghost_dimension == true):
		ghost_dimension = false
		_activate_collision()
#		flip_character()
#		set_physics_process(true)
		self.show()
	elif (ghost_dimension == false):
		ghost_dimension = true
		_change_collision()
#		_deactivate_node()
#		set_physics_process(false)
		self.hide()
