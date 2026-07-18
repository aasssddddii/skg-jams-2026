extends RayCast3D


var grappling:bool
var target:CharacterBody3D
var collision_location:Vector3
@export var rest_length = 2.0
@export var stiffness = 10.0
@export var damping = 1.0
@export var arrived_at_target_distance:=.2

@onready var player = get_parent()
var grapple_tweener:Tween

#func _ready() -> void:
	#

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input_dir:Vector2= Input.get_vector("up","down","left","right")
	rotation.z = input_dir.angle()
	if Input.is_action_just_pressed("grapple"):
		launch()
	print("is grappling: ", grappling)
	#if Input.is_action_just_released("grapple"):
		#retract()

	if grappling:
		handle_grapple()
func launch():
	if is_colliding():
		if get_collider().is_in_group("enemy"):
			collision_location = get_collision_point()
			target = get_collider().get_parent()
			grappling = true


#func retract():
	#grappling = false


func handle_grapple():
	print("sanity check target: ", target)
	#convert to Grapple tweener with potition moveving not Velocity
	grapple_tweener = get_tree().create_tween()
	grapple_tweener.tween_property(player,"global_position",target.global_position,.1)
	#grapple_tweener.tween_callback(func grapple_ender(): 
		#target.queue_free()
		#target = null
		#grappling = false
		#)
	
	if player.global_position.distance_to(target.global_position) < arrived_at_target_distance:
		grappling = false
		target.queue_free()
		target = null
	
	#var target_dir = player.global_position.direction_to(target)
	#var target_dist = player.global_position.distance_to(target)
#
	#var displacement = target_dist - rest_length
#
	#var force = Vector3.ZERO
#
	#if displacement > 0:
		#var spring_force_magnitude = stiffness * displacement
		#var spring_force = target_dir * spring_force_magnitude
#
		#var vel_dot = player.velocity.dot(target_dir)
		#var damping_force = -damping * vel_dot * target_dir
#
		#force = spring_force + damping_force
	#else:
		#grappling = false
#
	#player.velocity += force * delta
