class_name Hurtbox extends Area2D

@onready var owner_health: int = owner.health
@onready var owner_rage: int = owner.rage
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
	owner_health -= _damage
	owner_rage += _rage
