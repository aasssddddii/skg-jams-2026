extends CharacterBody3D


@export var speed = 1
@export var slow_down = .03
@export var max_speed = 1
@export var JUMP_VELOCITY = 1.0
@export var gravity = 2.0
@onready var grapple_cast: RayCast3D = $RayCast3D
@onready var circle_slash_hitbox: Area3D = $Circle_slash_Hitbox
@export var slash_bump :float=2.0

#func _ready() -> void:
	#print("Gravity Syntax: ", get_gravity())

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += Vector3(0,-gravity,0) * delta
		if abs(velocity.y) > max_speed:
			velocity.y = max_speed if velocity.y > 0 else -max_speed
			
			

	if Input.is_action_just_pressed("flap"):
		velocity.y += JUMP_VELOCITY
		if abs(velocity.y) > max_speed:
			velocity.y = max_speed if velocity.y > 0 else -max_speed
	var input_dir := Input.get_axis("left", "right")
	if input_dir:
		velocity.x = input_dir * speed
	else:
		velocity.x = move_toward(velocity.x, 0, slow_down)
	#print("velocity speed: ",velocity.x)
	#if !grapple_cast.grappling:
	if Input.is_action_just_pressed("slash"):
		if circle_slash_hitbox.get_overlapping_bodies().size() > 0:
			print("Body in range of slashing")
			for body in circle_slash_hitbox.get_overlapping_bodies():
				if body.is_in_group("enemy"):
					var vector_to_enemy = global_position.direction_to(body.global_position)
					velocity -= vector_to_enemy * slash_bump
					body.queue_free()
	move_and_slide()
