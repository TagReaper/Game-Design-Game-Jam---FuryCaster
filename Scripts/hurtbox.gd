class_name Hurtbox extends Area2D

@onready var owner_health: int = owner.health
@onready var owner_hostile: bool = owner.hostile

func _ready():
	monitoring = false
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	if (owner_hostile):
		set_collision_layer_value(5, true)
	else:
		set_collision_layer_value(4, true)

func _recieve_hit(_damage: int):
	owner_health -= _damage
