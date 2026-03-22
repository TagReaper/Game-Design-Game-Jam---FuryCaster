class_name PlatformerController2D extends CharacterBody2D

@export_category("Reference Nodes")
@export var PlayerSprite: AnimatedSprite2D
@export var CooldownTimer: Timer
@export var OverflowTimer: Timer
@export var HitboxSpawn: Node2D
@export var DashCast: RayCast2D
@export var SFX: AudioStreamPlayer2D
@export var hurtbox: Hurtbox
@export var rageTimer: Timer

@export_category("Attacks")
@export var slashHitbox: Shape2D
@export var slashDamage: int = 1

@export_category("Movement Stats")
@export var speed: float = 10
@export var jumpPower: float = 10
@export var maxJumps: int = 2
@export var terminalVelocity: float = 400
@export var maxDashes: int = 2
@export_range(0,1) var friction: float = 1

@export_category("Stats")
@export var maxHealth: int = 100
@export var maxRage: float = 100

#Intenal Variables
var health: int = maxHealth
var rage: float = 0
var jumps: int = 0
var dashes: int = 0
var dashPositionX: int
var speedMultiplier: int = 30
var jumpMultiplier: int = -30
var deathSFX = preload("res://Audio/SFX/Player Death SFX.mp3")
var attackSFX = preload("res://Audio/SFX/Player Slash.mp3")
var dashSFX = preload("res://Audio/SFX/Dash.mp3")
var jumpSFX = preload("res://Audio/SFX/Jump.mp3")
var overflowSFX = preload("res://Audio/SFX/Overflow.mp3")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var volumeMax: float = SFX.volume_db
 
#State Handler
enum State {IDLE, WALK, JUMP, FALL, DASH, ATTACK, OVERFLOW, DEAD}
var currentState = State.IDLE

#Allowances
var canMove: bool = true
var canJump: bool = true
var canAttack: bool = true
var canDash: bool = true

func _physics_process(delta):
	#Able Checks
	if (is_on_floor()):
		jumps = 0
		dashes = 0
	
		#MAYBE MOVE Able checks for NEXT physics process
	if (currentState != State.OVERFLOW and currentState != State.DASH and currentState != State.DEAD):
		if (currentState != State.ATTACK):
			canAttack = CooldownTimer.is_stopped()
			canJump = is_on_floor() or jumps < maxJumps
			canDash = dashes < maxDashes
		else:
			canAttack = false
			canJump = false
			canDash = false
		canMove = true
	else:
		canAttack = false
		canJump = false
		canDash = false
		canMove = false
	
	#Gravity
	if ((not is_on_floor()) and (velocity.y < terminalVelocity) and (currentState != State.DASH)):
		velocity.y += gravity * delta
	elif(currentState == State.DASH):
		velocity.y = 0
	
	#Jump
	if (Input.is_action_just_pressed("jump") and canJump):
		SFX.stream = jumpSFX
		SFX.pitch_scale = randf_range(1.95, 2.05)
		SFX.volume_db = -50 + Global.SFX_Volume * (-22+50)
		SFX.play()
		jumps += 1
		velocity.y = jumpPower * jumpMultiplier
	
	#Horizontal Movement
	var direction = Input.get_axis("moveLeft", "moveRight")
	if (direction and canMove):
		currentState = State.WALK
		velocity.x = direction * speed * speedMultiplier
	elif (currentState != State.DASH):
		currentState = State.IDLE
		velocity.x = move_toward(velocity.x, 0, speed * speedMultiplier * friction)
	else:
		global_position.x = move_toward(global_position.x, dashPositionX, 5)
	
	#Dash
	if (Input.is_action_just_pressed("dash") and canDash):
		#Animation + Colliders + Increment
		PlayerSprite.play("Dash")
		SFX.stream = dashSFX
		SFX.pitch_scale = randf_range(0.95, 1.05)
		SFX.volume_db = -50 + Global.SFX_Volume * (-18+50)
		SFX.play()
		velocity.x = 0
		dashes += 1
		
		#Dash Point Calculation
		if DashCast.is_colliding():
			dashPositionX = DashCast.get_collision_point().x-DashCast.target_position.x/8
		else:
			dashPositionX = global_position.x + DashCast.target_position.x*7/8
		
		hurtbox.monitorable = false
	
	#Attack
	if (Input.is_action_just_pressed("attack") and canAttack):
		#Animation + Cooldown
		PlayerSprite.play("Attack")
		SFX.stream = attackSFX
		SFX.pitch_scale = randf_range(0.9, 1.1)
		SFX.volume_db = -50 + Global.SFX_Volume * (2+50)
		SFX.play()
		CooldownTimer.start()
		
		#Hitbox Generation
		var hitbox = Hitbox.new(slashDamage, 0, 0.25, slashHitbox, false)
		HitboxSpawn.add_child(hitbox)
	
	#Cast Spell
	if (Input.is_action_just_pressed("castSpell") and canAttack):
		pass
	
	#Overflow Check
	if (rage >= maxRage && currentState != State.DEAD):
		if PlayerSprite.animation != "Overflow":
			SFX.stream = overflowSFX
			SFX.pitch_scale = randf_range(0.9, 1.1)
			SFX.volume_db = -50 + Global.SFX_Volume * (2+50)
			SFX.play()
			OverflowTimer.start()
			rageTimer.paused = true
			health *= 0.5
			$"UI+Options/UI/Healthbar"._health_bar_change()
		currentState = State.OVERFLOW
	else:
		#Extra State Checks in order of priority
		if (!is_on_floor() and canMove):
			if(velocity.y < 0):
				currentState = State.JUMP
			else:
				currentState = State.FALL
	
	if (health <= 0):
		if PlayerSprite.animation != "Death":
			SFX.stream = deathSFX
			SFX.volume_db = -50 + Global.SFX_Volume * (-10+50)
			SFX.play()
			PlayerSprite.play("Death")
	
	match PlayerSprite.animation:
		"Attack":
			currentState = State.ATTACK
		"Dash":
			currentState = State.DASH
		"Death":
			currentState = State.DEAD
	
	if rage > 0 && rageTimer.is_stopped():
		rage -= 0.1
		$"UI+Options/UI/Ragebar"._rage_bar_change()
	
	#flips the character
	_check_flip()
	
	#Animation State
	_check_animation()
	
	#Moving
	move_and_slide()

func _check_animation() -> void:
	match currentState:
		State.IDLE:
			if PlayerSprite.animation != "Idle":
				PlayerSprite.play("Idle")
		State.WALK:
			if PlayerSprite.animation != "Walk":
				PlayerSprite.play("Walk")
		State.JUMP:
			if PlayerSprite.animation != "Jump":
				PlayerSprite.play("Jump")
		State.FALL:
			if PlayerSprite.animation != "Fall":
				PlayerSprite.play("Fall")
		State.ATTACK:
			if PlayerSprite.animation != "Attack":
				PlayerSprite.play("Atack")
		State.DASH:
			if PlayerSprite.animation != "Dash":
				PlayerSprite.play("Dash")
		State.OVERFLOW:
			if PlayerSprite.animation != "Overflow":
				PlayerSprite.play("Overflow")
		State.DEAD:
			if PlayerSprite.animation != "Death":
				PlayerSprite.play("Death")

func _check_flip() -> void:
	if velocity.x > 0.1: #Facing Right
		PlayerSprite.flip_h = false
		HitboxSpawn.position.x = 8
		DashCast.target_position.x = 128
	elif velocity.x < -0.1: # Facing Left
		PlayerSprite.flip_h = true
		HitboxSpawn.position.x = -8
		DashCast.target_position.x = -128

func _on_player_sprite_animation_finished():
	match PlayerSprite.animation:
		"Attack":
			PlayerSprite.play("Idle")
			currentState = State.IDLE
		"Dash":
			hurtbox.monitorable = true
			PlayerSprite.play("Idle")
			currentState = State.IDLE

func _on_overflow_timeout():
	if currentState != State.DEAD:
		rage = maxRage / 3
		$"UI+Options/UI/Ragebar"._rage_bar_change()
		rageTimer.paused = false
		PlayerSprite.play("Idle")
		currentState = State.IDLE


func _on_rage_timer_timeout():
	if rage >= 5:
		rage -= 5
	else:
		rage = 0
