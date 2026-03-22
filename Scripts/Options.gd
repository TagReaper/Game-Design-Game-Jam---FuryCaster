extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$AudioStreamPlayer.volume_db = -50 + Global.MUSIC_Volume * (-15+50)


func _on_return_pressed():
	SceneLoader.load_scene("res://Scenes/main_menu.tscn")

func _on_sfx_drag_ended(value_changed):
	Global.SFX_Volume = value_changed

func _on_check_box_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_music_drag_ended(value_changed):
	Global.MUSIC_Volume = value_changed
