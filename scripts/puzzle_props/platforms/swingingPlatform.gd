extends Node2D

onready var links = $Links
onready var platform = $Links/KinematicBody2D

var direction = 1
onready var tween = get_node("Tween")
onready var tween2 = get_node("Tween2")

func _ready():
	tween.interpolate_property(links, "rotation_degrees", rad2deg(-PI/2), rad2deg(PI/2), Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.start()
	tween2.interpolate_property(platform, "rotation_degrees", rad2deg(PI/2), rad2deg(-PI/2), Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween2.start()

func _physics_process(_delta):
	pass


func _on_Tween_tween_completed(object, key):
	if direction == 1:
		direction = -1
		tween.interpolate_property(links, "rotation_degrees", rad2deg(PI/2), rad2deg(-PI/2), Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
		tween.start()
		tween2.interpolate_property(platform, "rotation_degrees", rad2deg(-PI/2), rad2deg(PI/2), Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
		tween2.start()
	else:
		direction = 1
		tween.interpolate_property(links, "rotation_degrees", rad2deg(-PI/2), rad2deg(PI/2), Tween.TRANS_CIRC,Tween.EASE_IN_OUT)
		tween.start()
		tween2.interpolate_property(platform, "rotation_degrees", rad2deg(PI/2), rad2deg(-PI/2), Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
		tween2.start()
