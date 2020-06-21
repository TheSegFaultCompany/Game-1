extends Node

onready var anim : AnimatedSprite = get_parent().get_node("AnimatedSprite")
onready var kinem = get_parent()

func move_player(_delta):
#	kinem.move_and_slide(Vector2(100, 100))
	anim.play("Idle")
