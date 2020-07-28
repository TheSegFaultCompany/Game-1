extends KinematicBody2D

signal turnOnShader
signal switchPlayer

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
export var grapplingOn = false
export var anti_gravity = false
export var syad = false

var grappling
var talking = false
var currentCamera = false
# Motion vector for movement of the player object
var motion = Vector2()

#onready var camera = $Camera2D

func _ready():
	connect("switchPlayer", get_parent().get_node("Camera2D"), "_switch")
	grappling = grapplingOn

# Function for the click event, use the grappling hook or toggle reverse gravity
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and grappling == true:
			# The vector must be the same values as the same as the size of the default viewport
			# This can be found under Project->Project Settings...->General->Display->Size
			$chain.shoot(event.position - Vector2(1024, 600)/2)
		else:
			$chain.release()
		if event.pressed and dead:
			$DeathScreen._restart()
	if event is InputEventKey and event.pressed:
		if dead:
			$DeathScreen._restart()
			return
		if event.scancode == KEY_T:
			anti_gravity = !anti_gravity
		# Testing dialogue options
		elif event.scancode == KEY_L:
			$dialogueLoader.loadDialogue("res://dialogue/dialogueJSONFiles/testDialogue.json")
		# Function testing the camera switching code
		elif event.scancode == KEY_K:
			if syad:
				emit_signal("switchPlayer")
				if (!currentCamera):
					currentCamera = true
				else:
					currentCamera = false

# Function for when the character is impaled by the spider
func impale():
	var bloodSpatter = preload("res://scenes/player/BloodEffect.tscn")
	self.add_child(bloodSpatter.instance())
	self.set_collision_layer_bit(0, 0)
	self.set_collision_mask_bit(0, 0)
	$AnimatedSprite.play("default")
	kill()

# Function for when the character is stabbed by the spider
func stab():
	var bloodSpatter = preload("res://scenes/player/BloodEffect.tscn")
	# Randomly generate the direction on which the character falls
	var tween = Tween.new()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var rand = rng.randi_range(-10, 10)
	self.add_child(tween)
	tween.connect("tween_all_completed", self, "_on_tween_complete")
	if rand > 0:
		tween.interpolate_property(self, "rotation_degrees", 0, 90, 0.5, Tween.TRANS_CIRC)
	else:
		tween.interpolate_property(self, "rotation_degrees", 0, -90, 0.5, Tween.TRANS_CIRC)
	tween.start()
	self.add_child(bloodSpatter.instance())

# Function for when the turn is completed
func _on_tween_complete():
	kill()

# Function for killing the player
func kill():
	$DeathScreen/ColorRect.visible = true
	$DeathScreen/AnimationPlayer.play("game_over")
	dead = true

# Process where all the movement calculations are done
func _physics_process(_delta: float) -> void:
	if dead == true or talking or currentCamera:
		return
	if Input.is_action_just_pressed("turn_on_shader"):
		emit_signal("turnOnShader")
	
	# Parameter for friction
	var friction = false

	# Used to be calculating the
	var walk = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")) * MAX_SPEED
	
	# Falling Up or Down, depending on the orientation of the gravity
	if (anti_gravity == true):
		$AnimatedSprite.flip_v = true
		motion.y -= GRAVITY
	else:
		$AnimatedSprite.flip_v = false
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
		grappling = grapplingOn
	
	#If the player is on the floor, then initiate the jump or
	# Slow down the movement if no input is pressed
	if is_on_floor() and anti_gravity == false:
		_normalJumping(friction)
	elif is_on_ceiling() and anti_gravity == true:
		_upsideDownJumping(friction)
	
	motion = move_and_slide(motion, UP, false, 4, PI/4, false)
	
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("pushable"):
			collision.collider.apply_central_impulse(-collision.normal * 80)

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

func dialogue_started():
	var control = get_parent().get_node("CanvasLayer/Control")
	control.show()
	talking = true

func dialogue_finished():
	var control = get_parent().get_node("CanvasLayer/Control")
	control.hide()
	talking = false
