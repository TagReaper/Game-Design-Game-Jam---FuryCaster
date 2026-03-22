extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$AudioStreamPlayer.volume_db = -80 + Global.MUSIC_Volume * (-15+80)


func _on_return_pressed():
	SceneLoader.load_scene("res://Scenes/main_menu.tscn")

func _on_check_box_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_sfx_value_changed(value):
	Global.SFX_Volume = value

func _on_music_value_changed(value):
	Global.MUSIC_Volume = value # Replace with function body.
