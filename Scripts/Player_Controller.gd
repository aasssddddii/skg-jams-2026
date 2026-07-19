extends CharacterBody3D


@export var speed = 1
@export var slow_down = .05
@export var max_speed = 1
@export var JUMP_VELOCITY = 1.0
@export var gravity = 2.0
@onready var grapple_cast: RayCast3D = $RayCast3D
#@onready var circle_slash_hitbox: Area3D = $Circle_slash_Hitbox
@export var slash_bump :float=2.0
@export var player_cam:Camera3D

var grapple_refresh:=.01
var current_grapple:float=1.0
var can_grapple:bool = true

var current_dash:float =1.0
var current_health:int =3
#func _ready() -> void:
	#print("Gravity Syntax: ", get_gravity())

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += Vector3(0,-gravity,0) * delta
		if abs(velocity.y) > max_speed:
			velocity.y = move_toward(velocity.y,0, slow_down)
			
	if current_grapple <=1 and !can_grapple:
		#print("current grapple: ", current_grapple)
		current_grapple += grapple_refresh
	else:
		can_grapple = true
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
		var looking_direction:Vector2= Input.get_vector("left", "right", "down", "up")
		print("player looking to dash at vector: ", looking_direction)
		var direction = Vector3(looking_direction.x,looking_direction.y,0)#.normalized()
		velocity = direction * speed * 3
	move_and_slide()
	player_cam.update_ui(current_grapple,current_dash,current_health)
#func update_ui():
	
	
	
	
	
	
	
	
	
