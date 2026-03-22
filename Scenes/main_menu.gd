extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$AudioStreamPlayer.volume_db = -50 + Global.MUSIC_Volume * (-15+50)


func _on_start_pressed():
	SceneLoader.load_scene("res://Scenes/Level.tscn")


func _on_options_pressed():
	SceneLoader.load_scene("res://Scenes/options.tscn")


func _on_exit_pressed():
	get_tree().quit()
