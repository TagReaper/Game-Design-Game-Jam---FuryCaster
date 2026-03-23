class_name Hitbox extends Area2D

@export var damage: int
@export var lifetime: float
@export var shape: Shape2D
@export var hostile: bool
@export var rage: int
#note: Hitbox logging

func _init(_damage: int, _rage: int, _lifetime: float, _shape: Shape2D, _hostile: bool) -> void:
	damage = _damage
	lifetime = _lifetime
	shape = _shape
	hostile = _hostile
	rage = _rage

func _ready() -> void:
	monitorable = false
	area_entered.connect(_on_area_entered)
	
	if(lifetime > 0.0):
		var new_timer = Timer.new()
		add_child(new_timer)
		new_timer.timeout.connect(queue_free)
		new_timer.call_deferred("start", lifetime)
	
	if (shape):
		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = shape
		add_child(collision_shape)
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	if (hostile):
		set_collision_mask_value(5, true)
	else:
		set_collision_mask_value(4, true)

func _on_area_entered(area: Area2D) -> void:
	if not area.has_method("_recieve_hit"):
		return
	if !hostile and get_parent().get_parent().name == "Player":
		get_parent().get_parent().rage += damage
		get_parent().get_parent().rageTimer.start()
		get_parent().get_parent().get_child(12).get_child(2).get_child(1)._rage_bar_change()
	area._recieve_hit(damage, rage)
