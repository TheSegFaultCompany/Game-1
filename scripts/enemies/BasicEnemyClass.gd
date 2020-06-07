extends KinematicBody2D
class_name enemy
# A RayCast2D node is passed to this function which returns true or false based on if the player is
# in the raycast
func _check_player(rayCast: RayCast2D) -> bool:
	if (rayCast.is_colliding()):
		var coll = rayCast.get_collider()
		if (coll.is_in_group("player")):
			return true
	return false
