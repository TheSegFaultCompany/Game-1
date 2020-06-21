extends KinematicBody2D

signal turnOnShader
# Declare member variables here.
const UP = Vector2(0, -1)
const GRAVITY = 20
const ACCELERATION = 50
const MAX_SPEED = 250
const SNECK_SPEED = 100
const JUMP_HEIGHT = -600
const CHAIN_PULL = 25

# The vector for the chain velocity
var chain_velocity := Vector2(0, 0)
var dead = false
# Export variables for toggling abilities
export var grappling = false
export var anti_gravity = false

# Motion vector for movement of the player object
var motion = Vector2()

# Function for the click event, use the grappling hook
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and grappling == true:
			$chain.shoot(event.position - get_viewport().size * 0.5)
		else:
			$chain.release()

func impale():
	var bloodSpatter = preload("res://scenes/player/BloodEffect.tscn")
	self.add_child(bloodSpatter.instance())
	self.set_collision_layer_bit(0, 0)
	self.set_collision_mask_bit(0, 0)
	$AnimatedSprite.play("default")
	kill()

func kill():
	dead = true

# Process where all the movement calculations are done
func _physics_process(_delta: float) -> void:
	if dead:
		return
	if Input.is_action_just_pressed("turn_on_shader"):
		emit_signal("turnOnShader")
	
	# Parameter for friction
	var friction = false

	# Used to be calculating the
	var walk = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")) * MAX_SPEED
	
	# Falling Up or Down, depending on the orientation of the gravity
	if (anti_gravity):
		motion.y -= GRAVITY
	else:
		motion.y += GRAVITY
	
	# Hook Physics
	if $chain.hooked and grappling == true:
		chain_velocity = to_local($chain.tip).normalized() * CHAIN_PULL
		if chain_velocity.y > 0:
			#chain_velocity.y *= 0.55
			chain_velocity.y *= 0.95
			pass
		else:
			chain_velocity.y *= 1.65
		if sign(chain_velocity.x) != sign(walk):
			chain_velocity.x *= 0.7
			pass
	else:
		chain_velocity = Vector2(0, 0)
	# Add the grappling motion to the player motion
	motion += chain_velocity
	
	# Moving the character right
	if Input.is_action_pressed("ui_right"):
		$AnimatedSprite.flip_h = false
		if Input.is_action_pressed("ui_down"):
			motion.x = min(motion.x + ACCELERATION, SNECK_SPEED)
		else:
			motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
		$AnimatedSprite.play("Walking (right)")
	# Moving the character left
	elif Input.is_action_pressed("ui_left"):
		$AnimatedSprite.flip_h = true
		if Input.is_action_pressed("ui_down"):
			motion.x = max(motion.x - ACCELERATION, -SNECK_SPEED)
		else:
			motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		$AnimatedSprite.play("Walking (right)")
	# Idle animation played otherwise
	else:
		$AnimatedSprite.play("default")
		friction = true
	# Shifting the character into a crouching position
	# When shifting the character cannot use the grappling hook
	if Input.is_action_pressed("ui_down"):
		$CollisionStanding.disabled = true
		$CollisionCrouching.disabled = false
		grappling = false
	else:
		$CollisionStanding.disabled = false
		$CollisionCrouching.disabled = true
		grappling = true
	
	#If the player is on the floor, then initiate the jump or
	# Slow down the movement if no input is pressed
	if is_on_floor() and anti_gravity == false:
		_normalJumping(friction)
	elif is_on_ceiling() and anti_gravity == true:
		_upsideDownJumping(friction)
	else:
		#If the character is moving up, then play the up animation
		if motion.y < 0:
			#$AnimatedSprite.play("Jumping")
			pass
		else:
			if motion.x > 0:
				$AnimatedSprite.play("Walking (right)")
	motion = move_and_slide_with_snap(motion, Vector2(0, -35), UP)

func _upsideDownJumping(friction: bool) -> void:
	if Input.is_action_just_pressed("ui_up"):
		motion.y = -JUMP_HEIGHT
	if friction == true:
		motion.x = lerp(motion.x, 0, 0.2)
	pass

func _normalJumping(friction: bool) -> void:
	if Input.is_action_just_pressed("ui_up"):
		motion.y = JUMP_HEIGHT
	if friction == true:
		motion.x = lerp(motion.x, 0, 0.2)
