extends Node2D

var type: String
@export var ExplosionCollision: Shape2D
@export var BoltCollision: Shape2D
@export var LightningCollision: Shape2D
@export var MagicAnimaiton: AnimatedSprite2D
@export var SFX: AudioStreamPlayer

var BoltSFX = preload("res://Audio/SFX/Magic Bolt.mp3")
var ExplosionSFX = preload("res://Audio/SFX/Magic Explosion.mp3")
var LightningSFX = preload("res://Audio/SFX/Magic Bolt.mp3")

var beenCast = false

# Called when the node enters the scene tree for the first time.
func cast() -> void:
	match type:
		"Explosion":
			MagicAnimaiton.position = Vector2(0,-12)
			MagicAnimaiton.play("Explosion")
			SFX.stream = ExplosionSFX
			SFX.play()
			await get_tree().create_timer(0.5).timeout
			var hitbox = Hitbox.new(20, 0, 0.5, ExplosionCollision, false)
			add_child(hitbox)
			hitbox.position = Vector2(0,-9)
			beenCast = true
		"Darkbolt":
			MagicAnimaiton.play("Darkbolt")
			MagicAnimaiton.position = Vector2(2,-36)
			SFX.stream = BoltSFX
			SFX.pitch_scale = randf_range(0.4, 0.5)
			SFX.volume_db = -50 + Global.SFX_Volume * (-10+50)
			SFX.play()
			await get_tree().create_timer(0.313).timeout
			var hitbox = Hitbox.new(10, 0, 0.313, BoltCollision, false)
			add_child(hitbox)
			hitbox.position = Vector2(0,-9)
			beenCast = true
		"Lightning":
			MagicAnimaiton.play("Lightning")

func _on_magic_animation_finished():
	if (beenCast):
		queue_free()
