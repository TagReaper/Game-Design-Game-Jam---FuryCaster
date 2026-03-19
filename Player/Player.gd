class_name PlatformerController2D extends CharacterBody2D

@export_category("Reference Nodes")
@export var PlayerSprite: AnimatedSprite2D
@export var PlayerCollider: CollisionShape2D
@export var CooldownTimer: Timer

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
enum State {IDLE, WALK, JUMP, FALL, DASH, ATTACK, OVERFLOW}
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
	
	#Gravity
	if ((not is_on_floor()) and (velocity.y < terminalVelocity) and (currentState != State.DASH)):
		velocity.y += gravity * delta
	
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
		CooldownTimer.start()
	
	#Cast Spell
	if (Input.is_action_just_pressed("castSpell") and canAttack):
		pass
	
	#Extra State Checks in order of priority
	if (!is_on_floor() and canMove):
		if(velocity.y < 0):
			currentState = State.JUMP
		else:
			currentState = State.FALL
	if (rage > maxRage):
		currentState = State.OVERFLOW
	
	#Animation State
	_check_Animation()
	
	#Able checks for NEXT physics process
	if (currentState != State.OVERFLOW and currentState != State.ATTACK and currentState != State.DASH):
		canAttack = true
		canJump = is_on_floor() or jumps < maxJumps
		canDash = true
		canMove = true
	else:
		canAttack = false
		canJump = false
		canDash = false
		canMove = false
	
	#Moving
	move_and_slide()

func _check_Animation() -> void:
	match currentState:
		State.IDLE:
			print("Idling")
		State.WALK:
			print("Walking")
		State.JUMP:
			print("Jumping")
		State.FALL:
			print("Falling")
		State.ATTACK:
			print("Attacking")
		State.DASH:
			print("Dashing")
		State.OVERFLOW:
			print("Overflowing")
