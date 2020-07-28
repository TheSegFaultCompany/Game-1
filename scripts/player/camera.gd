extends Camera2D

onready var player = get_parent().get_node("Player")
var enemy

export var syad = false
var switch = false

func _ready():
	if syad:
		enemy = get_parent().get_node("Syad")

func _physics_process(delta):
	if (!switch):
		position = player.position
	else:
		position = enemy.position

func _switch():
	if (!switch):
		switch = true
		enemy.activate()
	else:
		enemy.deactivate()
		switch = false

# Listener for when the player uses the ghost dimension key
func _on_Player_turnOnShader():
	if $CanvasLayer/BlackAndWhiteShader.is_visible_in_tree():
		$CanvasLayer/BlackAndWhiteShader.hide()
	else:
		$CanvasLayer/BlackAndWhiteShader.show()
