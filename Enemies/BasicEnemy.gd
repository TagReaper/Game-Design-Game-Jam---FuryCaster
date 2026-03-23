extends CharacterBody2D

@export_category("Reference Nodes")
@export var EnemySprite: AnimatedSprite2D
@export var CooldownTimer: Timer
@export var RoamTimer: Timer
@export var HitboxSpawn: Node2D
@export var ledgeCast: RayCast2D
@export var searchCast: RayCast2D
@export var chaseDetect: Area2D
@export var SFX: AudioStreamPlayer2D
@export var overlapCast: RayCast2D
@export var EnemyCollision: CollisionShape2D

@export_category("Attacks")
@export var attackHitbox: Shape2D
@export var attackDamage: int = 1
@export var attackRange: int
@export var hitboxDelay: float
@export var hitboxLifetime: float
@export var hitboxOffset: Vector2

@export_category("Movement Stats")
@export var speed: float = 10
@export_range(0,1) var friction: float = 0.8
@export var leftlimitX: int
@export var rightLimitX: int
@export var chaseRange: int

@export_category("Stats")
@export var maxHealth: int = 5
@export var rage: int = 2



#Internal Variables
@onready var health = maxHealth
@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player = players[0]
var moveTo: int
var deathSFX= preload("res://Audio/SFX/Enemy Death SFX.mp3")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player_pos: Vector2
@onready var volumeMax: float = SFX.volume_db

#State Handler
enum State {ROAM, CHASE, SEARCH, ATTACK, DEAD}
var currentState = State.ROAM
var substate : String

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if player.health <= 0:
		currentState = State.ROAM
	
	if health <= 0:
		currentState = State.DEAD
		if EnemySprite.animation != "Death":
			EnemyCollision.disabled = true
			$Hurtbox.monitorable = false
			EnemySprite.play("Death")
			SFX.stream = deathSFX
			SFX.volume_db = -50 + Global.SFX_Volume * (-13+50)
			SFX.play()
			await get_tree().create_timer(2).timeout 
			queue_free()
	else:
		match currentState:
			State.ROAM:
				if RoamTimer.is_stopped():
					RoamTimer.start(randf_range(1,3))
				_flip_check()
				_move()
			State.CHASE:
				player_pos = player.global_position
				if (global_position.distance_to(player_pos) < attackRange):
					currentState = State.ATTACK
				elif global_position.distance_to(player_pos) > chaseRange:
					currentState = State.SEARCH
				elif player_pos.x-global_position.x > 0 and abs(player_pos.y-global_position.y) < 8:
					moveTo = player_pos.x - attackRange + 8
				else:
					moveTo = player_pos.x + attackRange - 8
				_flip_check()
				_move()
			State.SEARCH:
				player_pos = player.global_position
				searchCast.target_position = player_pos - global_position
				if !searchCast.is_colliding():
					moveTo = player_pos.x
				else:
					searchCast.target_position = Vector2(0,5)
					currentState = State.ROAM
				_flip_check()
				_move()
		_check_animation()

func _move() -> void:
	if ledgeCast.is_colliding() and !overlapCast.is_colliding():
		if(moveTo - global_position.x > 4):
			velocity.x = speed * 30
		elif(moveTo - global_position.x < -4):
			velocity.x = -speed * 30
		else:
			velocity.x = move_toward(velocity.x, 0, speed * 30 * friction)
	else:
			velocity.x = move_toward(velocity.x, 0, speed * 30 * friction)
	move_and_slide()

func _check_animation() -> void:
	if currentState == State.ATTACK:
		_attack()
	elif velocity.x != 0:
		if EnemySprite.animation != "Walk":
			EnemySprite.play("Walk")
	else:
		if EnemySprite.animation != "Idle":
			EnemySprite.play("Idle")

func _attack() -> void:
	#if PriorityCooldownTimer.is_stopped():
		#substate = "Attack"
	#else:
		#substate = "OTHER ATTACK"
	
	substate = "Attack"
	
	match substate:
		"Attack":
			if EnemySprite.animation != substate and CooldownTimer.is_stopped():
				EnemySprite.play(substate)
				SFX.pitch_scale = randf_range(0.9, 1.1)
				SFX.volume_db = -50 + Global.SFX_Volume * (volumeMax+50)
				SFX.play()
				
				#Hitbox Generation
				await get_tree().create_timer(hitboxDelay).timeout
				var hitbox = Hitbox.new(attackDamage, rage, hitboxLifetime, attackHitbox, true)
				HitboxSpawn.add_child(hitbox)
				var hitbox2 = Hitbox.new(0, rage, hitboxLifetime, attackHitbox, true)
				hitbox.global_position = hitbox.global_position + hitboxOffset
				hitbox2.scale *= 3
				HitboxSpawn.add_child(hitbox2)
				hitbox2.global_position = hitbox2.global_position + hitboxOffset
				
				CooldownTimer.start()
		#"OTHER ATTACK":
			#if EnemySprite.animation != substate:
				#EnemySprite.play(substate)
				
				# ^ Same Hitbox Generation as above, but with new stats, etc...

func _flip_check() -> void:
	if (moveTo-global_position.x > 0):
		if EnemySprite.flip_h:
			hitboxOffset.x = -hitboxOffset.x
		EnemySprite.flip_h = false
		ledgeCast.position.x = 16
		chaseDetect.position.x = 48
		overlapCast.position.x = 6
	elif (moveTo-global_position.x < 0):
		if !EnemySprite.flip_h:
			hitboxOffset.x = -hitboxOffset.x
		EnemySprite.flip_h = true
		ledgeCast.position.x = -16
		chaseDetect.position.x = -48
		overlapCast.position.x = -6

func _on_chase_area_body_entered(body):
	searchCast.target_position = Vector2(0,5)
	currentState = State.CHASE

func _on_slime_sprite_animation_finished():
	if currentState == State.ATTACK:
		EnemySprite.play("Idle")
		currentState = State.CHASE

func _on_roam_timeout():
	if currentState == State.ROAM:
		moveTo = randi_range(leftlimitX, rightLimitX)
