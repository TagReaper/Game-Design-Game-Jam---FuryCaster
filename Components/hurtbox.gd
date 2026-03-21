class_name Hurtbox extends Area2D

@export var owner_hostile: bool
@export var SFX: AudioStreamPlayer2D

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
		SFX.pitch_scale = randf_range(0.7, 0.9)
		SFX.play()
		owner.health -= _damage
	if !owner_hostile:
		owner.rage += _rage
