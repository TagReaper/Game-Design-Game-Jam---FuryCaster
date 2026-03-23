extends Camera2D

@export var Text1: RichTextLabel
@export var Text2: RichTextLabel
@export var anim: AnimationPlayer

func _process(delta):
	global_position.x = move_toward(global_position.x, 100000, 3)
	
	if Input.is_action_pressed("jump"):
		anim.speed_scale = 5
	else:
		anim.speed_scale = 1

func _on_animation_player_animation_finished(anim_name):
	SceneLoader.load_scene("res://Scenes/Level.tscn")
