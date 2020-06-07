extends Node

# Class to manage all of the enemy switching from ghost dimension to
# the normal game

onready var listOfEnemies = get_tree().get_nodes_in_group("enemy")

func _on_Player_turnOnShader():
	for enem in listOfEnemies:
		enem._on_Player_turnOnShader()
