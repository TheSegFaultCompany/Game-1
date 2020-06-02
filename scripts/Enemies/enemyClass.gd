extends Node2D
class_name enemies

onready var player = get_tree().get_root().get_child(0).get_node("Player")

func _check_player():
	var stuff = $KinematicBody2D/RayCast2D
	stuff.set_cast_to(player.global_position-self.global_position)
	var coll = stuff.get_collider()
	print(coll)

func _process(delta):
	_check_player()
	#print(player.global_position)
