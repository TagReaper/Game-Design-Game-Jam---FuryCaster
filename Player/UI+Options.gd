extends CanvasLayer

@onready var controllers = get_tree().get_nodes_in_group("Controllers")
@onready var pauseController = controllers[0]

func _process(delta):
	$Music.volume_db = -80 + Global.MUSIC_Volume * (-15+80)
	
	if get_tree().paused && pauseController.manualPause:
		$UI.visible = false
		$Options.visible = true
		$Options/VBoxContainer2/Label3/CheckBox.disabled = false
		$Options/VBoxContainer2/Music.editable = true
		$Options/VBoxContainer2/SFX.editable = true
		$Options/VBoxContainer2/Return.disabled = false
	else:
		$UI.visible = true
		$Options.visible = false
		$Options/VBoxContainer2/Label3/CheckBox.disabled = true
		$Options/VBoxContainer2/Music.editable = false
		$Options/VBoxContainer2/SFX.editable = false
		$Options/VBoxContainer2/Return.disabled = true

func _on_check_box_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_return_pressed():
	get_tree().quit()


func _on_sfx_value_changed(value):
	Global.SFX_Volume = value


func _on_music_value_changed(value):
	Global.MUSIC_Volume = value
