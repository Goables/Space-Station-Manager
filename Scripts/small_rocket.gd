extends Node2D

@onready var animated_sprite_2d = $AnimatedSprite2D


func _on_visibility_changed():
	if visible:
		animated_sprite_2d.set_frame_and_progress(0,0)
		animated_sprite_2d.play()
