extends CharacterBody2D

@export_category("Reference Nodes")
@export var EnemySprite: AnimatedSprite2D
@export var CooldownTimer: Timer
@export var RoamTimer: Timer
@export var HitboxSpawn: Node2D
@export var ledgeCast: RayCast2D
@export var searchCast: RayCast2D
@export var chaseDetect: Area2D

@export_category("Attacks")
@export var attackHitbox: Shape2D
@export var attackDamage: int = 1
@export var attackRange: int
@export var hitboxDelay: float
@export var hitboxLifetime: float

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

#State Handler
enum State {ROAM, CHASE, SEARCH, ATTACK, DEAD}
var currentState = State.ROAM
var substate : String

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if health <= 0:
		currentState = State.DEAD
	
	match currentState:
		State.ROAM:
			if RoamTimer.is_stopped():
				RoamTimer.start()
			_flip_check()
			_move()
		State.CHASE:
			if (global_position.distance_to(player.global_position) < attackRange):
				currentState = State.ATTACK
			elif global_position.distance_to(player.global_position) > chaseRange:
				currentState = State.SEARCH
			elif moveTo-global_position.x > 0:
				moveTo = player.global_position.x - attackRange + 8
			else:
				moveTo = player.global_position.x + attackRange - 8
			_flip_check()
			_move()
		State.SEARCH:
			searchCast.target_position = player.global_position - global_position
			if !searchCast.is_colliding():
				moveTo = player.global_position.x
			else:
				currentState = State.ROAM
			_flip_check()
			_move()
		State.DEAD:
			EnemySprite.play("Death")
			await get_tree().create_timer(2).timeout 
			queue_free()
	_check_animation()

func _move() -> void:
	if ledgeCast.is_colliding():
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
				
				#Hitbox Generation
				await get_tree().create_timer(hitboxDelay).timeout
				var hitbox = Hitbox.new(attackDamage, rage, hitboxLifetime, attackHitbox, true)
				HitboxSpawn.add_child(hitbox)
				var hitbox2 = Hitbox.new(0, rage, hitboxLifetime, attackHitbox, true)
				hitbox2.scale *= 2
				HitboxSpawn.add_child(hitbox2)
				
				CooldownTimer.start()
		#"OTHER ATTACK":
			#if EnemySprite.animation != substate:
				#EnemySprite.play(substate)
				
				# ^ Same Hitbox Generation as above, but with new stats, etc...

func _flip_check() -> void:
	if (moveTo-global_position.x > 0):
		EnemySprite.flip_h = false
		ledgeCast.position.x = 20
		chaseDetect.position.x = 48
	elif (moveTo-global_position.x < 0):
		EnemySprite.flip_h = true
		ledgeCast.position.x = -20
		chaseDetect.position.x = -48

func _on_chase_area_body_entered(body):
	currentState = State.CHASE

func _on_slime_sprite_animation_finished():
	if currentState == State.ATTACK:
		EnemySprite.play("Idle")
		currentState = State.CHASE

func _on_roam_timeout():
	if currentState == State.ROAM:
		moveTo = randi_range(leftlimitX, rightLimitX)
