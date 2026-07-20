extends CharacterBody3D

var game_manager = GameManager

@export var speed = 1
@export var slow_down = .05
@export var max_speed = 1
@export var JUMP_VELOCITY = 1.0
@export var gravity = 2.0
@onready var grapple_cast: RayCast3D = $RayCast3D
#@onready var circle_slash_hitbox: Area3D = $Circle_slash_Hitbox
@export var slash_bump :float=2.0
@export var player_cam:Camera3D
@onready var dash_hitbox: Area3D = $RayCast3D/Dash_hitbox
@onready var targeting_arrow: MeshInstance3D = $RayCast3D/ray_targeting
@onready var combo_label: Label3D = $Combo_Label

var grapple_refresh:=.01
var current_grapple:float=1.0
var can_grapple:= true

var current_dash:float =1.0
var current_health:int =3
var can_dash:= true

var dashing:=false


var current_combo:int

var combo_bleedout:=.003



func _ready() -> void:
	game_manager.game_on = true

func _physics_process(delta: float) -> void:
	if game_manager.game_on:
		if not is_on_floor():
			velocity += Vector3(0,-gravity,0) * delta
			if abs(velocity.y) > max_speed:
				velocity.y = move_toward(velocity.y,0, slow_down)
				
		if current_grapple <=1 and !can_grapple:
			#print("current grapple: ", current_grapple)
			current_grapple += grapple_refresh
		else:
			can_grapple = true
			
			
		#print("current dash amount: ", current_dash, " | can dash? : ", can_dash)
		if current_dash <=1 and !can_dash:
			current_dash += grapple_refresh
		else:
			can_dash = true
			
			
		if Input.is_action_just_pressed("flap"):
			velocity.y += JUMP_VELOCITY
			if abs(velocity.y) > max_speed:
				velocity.y = max_speed if velocity.y > 0 else -max_speed
		
		var input_dir := Input.get_axis("left", "right")
		if input_dir and !dashing:
			velocity.x = input_dir * speed
		else:
			velocity.x = move_toward(velocity.x, 0, slow_down)
		#print("velocity speed: ",velocity.x)
		#if !grapple_cast.grappling:
		if Input.is_action_just_pressed("dash") and can_dash:
			var looking_direction:Vector2= Input.get_vector("left", "right", "down", "up")
			dashing = true
			current_dash = 0
			can_dash = false
			var direction = Vector3(looking_direction.x,looking_direction.y,0)
			velocity = direction * speed * 3
			print("player looking to dash at vector: ", looking_direction, "new velocity, ", velocity)
			get_tree().create_timer(.3).timeout.connect(func dash_reseter(): dashing = false)
			
		if !dashing and Input.is_action_just_pressed("down"):
			velocity.y -= JUMP_VELOCITY
			if abs(velocity.y) > max_speed:
				velocity.y = max_speed if velocity.y > 0 else -max_speed
			
		if dashing:
			for body in dash_hitbox.get_overlapping_bodies():
				if body.is_in_group("enemy"):
					body.queue_free()
					manage_combo(true)
					player_cam.add_points(1,player_cam.multiplyer)
					
		dash_hitbox.visible = dashing
		#targeting_arrow.visible = !dashing
		
		move_and_slide()
		player_cam.update_ui(current_grapple,current_dash,current_health)
		manage_combo()
	
	
	
func manage_health(amount:int=1,choice:String="remove"):
	match choice:
		"add":
			current_health += amount
		"remove":
			if current_health > 1:
				current_health -= amount
			else:
				current_health -= amount
				if current_combo > 1:
					player_cam.add_combo({current_combo:1})
				game_over()
		"set":
			current_health = amount
	
	
func game_over()->void:
	game_manager.game_on = false
	player_cam.show_score_screen(player_cam.score,player_cam.combos)
	queue_free()
	pass

func manage_combo(refresh:bool = false)->void:
	if combo_label.modulate.a >=0:
		combo_label.modulate.a -= combo_bleedout
	if refresh:
		current_combo += 1
		print("combo +1")
		combo_label.modulate.a = 1
	if combo_label.modulate.a <= 0:
		print("combo dead")
		if current_combo > 1:
			player_cam.add_combo({current_combo:1})
		current_combo = 0
	#print("modulate sanity check: ", combo_label.modulate.a)
	combo_label.text = "x "+var_to_str(current_combo)
	combo_label.outline_modulate.a = combo_label.modulate.a
		
