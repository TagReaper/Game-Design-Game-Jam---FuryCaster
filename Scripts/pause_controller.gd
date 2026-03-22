extends Node

@export var can_toggle_pause: bool = true

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		if !get_tree().paused:
			pause()
		else:
			resume()

func freeze_frame(_time: float) -> void:
	pause()
	await get_tree().create_timer(_time).timeout
	resume()

func pause():
	if can_toggle_pause:
		get_tree().set_deferred("paused", true)

func resume():
	if can_toggle_pause:
		get_tree().set_deferred("paused", false)
