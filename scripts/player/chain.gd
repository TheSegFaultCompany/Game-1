extends Node2D

# To make sure the hook can interact with tilemap, make sure the second unit
# in the collision layer and collision mask is activated as well.
onready var links = $links
var direction := Vector2(0, 0)
var tip := Vector2(0, 0)

const SPEED = 50

var flying = false
var hooked = false

# Function for shooting the chain from the player
func shoot(dir: Vector2) -> void:
	direction = dir.normalized()
	flying = true
	tip = self.global_position

# Function to release the hook once the click no longer happens
func release() -> void:
	flying = false
	hooked = false

# Function to throw the player towards the chain
func _process(_delta: float) -> void:
	self.visible = flying or hooked
	if not self.visible:
		return
	var tip_loc = to_local(tip)
	links.rotation = self.position.angle_to_point(tip_loc) - deg2rad(90)
	$Tip.rotation = self.position.angle_to_point(tip_loc) - deg2rad(90)
	links.position = tip_loc
	links.region_rect.size.y = tip_loc.length()
	if tip_loc.length() > 1000:
		release()

# Function for the main physics movement to throw the tip of the hook
# Towards direction of the mouse click
func _physics_process(_delta: float) -> void:
	$Tip.global_position = tip
	if flying:
		if $Tip.move_and_collide(direction * SPEED):
			hooked = true
			flying = false
	tip = $Tip.global_position
