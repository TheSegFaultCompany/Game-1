extends Camera2D

# Listener for when the player uses the ghost dimension key
func _on_Player_turnOnShader():
	if $CanvasLayer/BlackAndWhiteShader.is_visible_in_tree():
		$CanvasLayer/BlackAndWhiteShader.hide()
	else:
		$CanvasLayer/BlackAndWhiteShader.show()
