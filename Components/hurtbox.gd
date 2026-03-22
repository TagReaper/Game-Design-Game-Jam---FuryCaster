class_name Hurtbox extends Area2D

@export var owner_hostile: bool
@export var SFX: AudioStreamPlayer2D
@onready var controllers = get_tree().get_nodes_in_group("Controllers")
@onready var pauseController = controllers[0]


func _ready():
	monitoring = false
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	if (owner_hostile):
		set_collision_layer_value(4, true)
	else:
		set_collision_layer_value(5, true)

func _recieve_hit(_damage: int, _rage: int):
	if _damage > 0 && owner.health > 0:
		SFX.pitch_scale = randf_range(0.5, 1.1)
		SFX.volume_db = -50 + Global.SFX_Volume * (-8+50)
		SFX.play()
		owner.health -= _damage
		owner.modulate = "ff0000"
		await get_tree().create_timer(0.1).timeout
		owner.modulate = "ffffff"
		pauseController.freeze_frame(.08)
	if !owner_hostile:
		owner.rage += _rage
