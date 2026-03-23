extends Control

@export var Owner: CharacterBody2D
@export var Ragebar: TextureProgressBar
@export var Damagebar: TextureProgressBar
@export var damageTimer: Timer

func _ready():
	Ragebar.max_value = Owner.maxRage
	Damagebar.max_value = Owner.maxRage
	Ragebar.value = Owner.rage
	Damagebar.value = Owner.rage

func _rage_bar_change() -> void:
	Ragebar.value = Owner.rage
	damageTimer.start()

func _on_rage_timer_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property(Damagebar, "value", Ragebar.value, 1.0)
