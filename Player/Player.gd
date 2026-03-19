class_name PlatformerController2D extends CharacterBody2D

@export_category("Reference Nodes")
@export var PlayerSprite: AnimatedSprite2D
@export var PlayerCollider: CollisionShape2D
@export var CooldownTimer: Timer
@export var OverflowTimer: Timer
@export var HitboxSpawn: Node2D

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
@export var maxHealth: int = 50
@export var maxRage: int = 100

#Intenal Variables
@onready var health: int = maxHealth
var rage: int = 0
var jumps: int = 0
var dashes: int = 0
var speedMultiplier: int = 30
var jumpMultiplier: int = -30
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
 
#State Handler
enum State {IDLE, WALK, JUMP, FALL, DASH, ATTACK, OVERFLOW, DEAD}
var currentState = State.IDLE

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
			canDash = PlayerSprite.animation != "Dash"
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
		jumps += 1
		velocity.y = jumpPower * jumpMultiplier
	
	#Horizontal Movement
	var direction = Input.get_axis("moveLeft", "moveRight")
	if (direction and canMove):
		currentState = State.WALK
		velocity.x = direction * speed * speedMultiplier
	else:
		currentState = State.IDLE
		velocity.x = move_toward(velocity.x, 0, speed * speedMultiplier * friction)
	
	#Dash
	if (Input.is_action_just_pressed("dash") and canDash):
		pass
	
	#Attack
	if (Input.is_action_just_pressed("attack") and canAttack):
		#Animation + Cooldown
		PlayerSprite.play("Attack")
		CooldownTimer.start()
		
		#Hitbox Generation
		var hitbox = Hitbox.new(slashDamage, 0, 0.25, slashHitbox, false)
		HitboxSpawn.add_child(hitbox)
		
	
	#Cast Spell
	if (Input.is_action_just_pressed("castSpell") and canAttack):
		pass
	
	#Overflow Check
	if (rage > maxRage):
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
			PlayerSprite.play("Death")
	
	match PlayerSprite.animation:
		"Attack":
			currentState = State.ATTACK
		"Dash":
			currentState = State.DASH
		"Death":
			currentState = State.DEAD
	
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
	elif velocity.x < -0.1: # Facing Left
		PlayerSprite.flip_h = true
		HitboxSpawn.position.x = -8

func _on_player_sprite_animation_finished():
	match PlayerSprite.animation:
		"Attack":
			PlayerSprite.play("Idle")
			currentState = State.IDLE
		"Dash":
			PlayerSprite.play("Idle")
			currentState = State.IDLE

func _on_overflow_timeout():
	if currentState != State.DEAD:
		PlayerSprite.play("Idle")
		currentState = State.IDLE
