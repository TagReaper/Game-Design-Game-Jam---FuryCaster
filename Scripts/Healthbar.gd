extends Control

@export var Owner: CharacterBody2D
@export var Healthbar: TextureProgressBar
@export var Damagebar: TextureProgressBar
@export var damageTimer: Timer

func _ready():
	Healthbar.max_value = Owner.maxHealth
	Damagebar.max_value = Owner.maxHealth
	Healthbar.value = Owner.health
	Damagebar.value = Owner.health

func _on_damage_timer_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property(Damagebar, "value", Healthbar.value, 1.0)

func _health_bar_change() -> void:
	Healthbar.value = Owner.health
	damageTimer.start()
