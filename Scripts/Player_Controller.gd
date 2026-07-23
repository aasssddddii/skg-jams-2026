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
@onready var player_hitbox: Area3D = $blockbench_export/Dragon_armature_PC/Skeleton3D/Dragon_armature_PC/player_hitbox

@onready var targeting_arrow: MeshInstance3D = $RayCast3D/ray_targeting
@onready var combo_label: Label3D = $Combo_Label

@onready var playe_flap_sfx_path = "res://Audio/SFX/DragonWing_Flap.ogg"

@export var animation_player:AnimationPlayer

const fps:=24
const glide_frame:= 105
const dash_start:=0.211
const dash_end:=0.68




var grapple_refresh:=.01
var current_grapple:float=1.0
var can_grapple:= true

var current_dash:float =1.0
var current_health:int =5
var can_dash:= true

var dashing:=false





var hold_flap_cooldown:=.4
var can_hold_flap:=true

var speed_boost:bool

var invincibility_on:=false
var urf_mode:=false




func setup_player() -> void:
	player_cam.capture_mouse()
	#speed_boost_timer.timeout.connect(func speed_boost_resetter(): speed_boost=false)
	

func _physics_process(delta: float) -> void:
	if game_manager.game_on:
		
		bound_checker()
		
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
			
			
		if Input.is_action_just_pressed("flap") or (can_hold_flap and Input.is_action_pressed("flap")):
			var flap_cooldown = hold_flap_cooldown
			var changed_max_speed = max_speed
			
			if !speed_boost:
				velocity.y += JUMP_VELOCITY
				animation_player.speed_scale = 1
				animation_player.play("Flying Idle",-1,4)
			else:
				flap_cooldown /= 4
				velocity.y += JUMP_VELOCITY + 30
				changed_max_speed * 2
			can_hold_flap = false
			get_tree().create_timer(flap_cooldown).timeout.connect(func flap_resetter():can_hold_flap = true)
			
			if abs(velocity.y) > changed_max_speed:
				velocity.y = changed_max_speed if velocity.y > 0 else -changed_max_speed
		elif Input.is_action_just_released("flap"):
			animation_player.seek(float(glide_frame/24),true)
			animation_player.pause()
		var input_dir :float= Input.get_axis("left", "right") if Input.get_axis("left", "right") else Input.get_axis("pc_left", "pc_right")
		#changed_max_speed = max_speed
		#rotate_player()
			
		if input_dir and !dashing:
			var changed_max_speed = max_speed
			if !speed_boost:
				velocity.x += input_dir * speed
			else:
				changed_max_speed += 1.6
				velocity.x += input_dir * (speed +1)
				
			if abs(velocity.x) > changed_max_speed:
				velocity.x = changed_max_speed if velocity.x > 0 else -changed_max_speed
		else:
			velocity.x = move_toward(velocity.x, 0, slow_down)
		#print("velocity speed: ",velocity.x)
		#if !grapple_cast.grappling:
		if Input.is_action_just_pressed("dash") and can_dash:
			player_cam.play_sfx(load(playe_flap_sfx_path))
			var mouse_direction :Vector3= player_cam.project_ray_normal(get_viewport().get_mouse_position())
			if mouse_direction.length_squared() > 0.001:
				mouse_direction = mouse_direction.normalized()
			var looking_direction:Vector2= Input.get_vector("left", "right", "down", "up") if Input.get_vector("left", "right", "down", "up") else Vector2(mouse_direction.x,mouse_direction.y).normalized()
			print("sanity check play dash once")
			animation_player.play_section("Dash",dash_start,dash_end,-1,4)
			dashing = true
			current_dash = 0
			can_dash = false
			if urf_mode:
				can_dash = true
				current_dash = 1
			var direction = Vector3(looking_direction.x,looking_direction.y,0)
			
			if !speed_boost:
				velocity = direction * speed * 3
			else:
				velocity = direction * speed * 5
			#print("player looking to dash at vector: ", looking_direction, "new velocity, ", velocity)
			get_tree().create_timer(.3).timeout.connect(func dash_reseter(): dashing = false)
			
		if !dashing and !can_hold_flap and(Input.is_action_just_pressed("down")or Input.is_action_just_pressed("pc_down")):
			velocity.y -= JUMP_VELOCITY
			if abs(velocity.y) > max_speed:
				velocity.y = max_speed if velocity.y > 0 else -max_speed
			
		if dashing:
			for body in dash_hitbox.get_overlapping_bodies():
				if body.is_in_group("enemy"):
					body.queue_free()
					player_cam.play_sfx(player_cam.ENEMY_DEATH)
					player_cam.play_sfx(player_cam.player_sfxs.pick_random())
					game_manager.spawned_enemies.remove_at(game_manager.spawned_enemies.find(body))
					player_cam.manage_combo(true)
					player_cam.add_points(1,player_cam.multiplyer)
					if double_points:
						player_cam.add_points(1,player_cam.multiplyer)
			for body in player_hitbox.get_overlapping_bodies():
				if body.is_in_group("enemy"):
					body.queue_free()
					player_cam.play_sfx(player_cam.ENEMY_DEATH)
					player_cam.play_sfx(player_cam.player_sfxs.pick_random())
					game_manager.spawned_enemies.remove_at(game_manager.spawned_enemies.find(body))
					player_cam.manage_combo(true)
					player_cam.add_points(1,player_cam.multiplyer)
					if double_points:
						player_cam.add_points(1,player_cam.multiplyer)
					
		dash_hitbox.visible = dashing
		if velocity:
			if velocity.x >0:
				rotate_player()
			elif velocity.x <0:
				rotate_player(false) 
			if velocity.y > 0:
				turn_up_player()
			else:
				turn_up_player(false)
		#targeting_arrow.visible = !dashing
		
		move_and_slide()
		player_cam.update_ui(current_grapple,current_dash,current_health)
		player_cam.manage_combo()
	
func _process(delta: float) -> void:
	manage_speed_boost()
	if invincibility_on or damage_buffer:
		do_invincibility()
	else:
		if visual_player.visible != true:
			visual_player.visible = true
	
var damage_buffer:=false
func manage_health(amount:int=1,choice:String="remove"):
	match choice:
		"add":
			current_health += amount
		"remove":
			if !invincibility_on and !damage_buffer:
				if current_health > 1:
					current_health -= amount
					damage_buffer = true
					get_tree().create_timer(1).timeout.connect(func damage_buffer_ender():damage_buffer = false)
				else:
					current_health -= amount
					if player_cam.current_combo > 1:
						player_cam.add_combo({player_cam.current_combo:1})
					if !game_manager.debug_mode:
						game_over()
		"set":
			current_health = amount
	
	
func game_over()->void:
	game_manager.game_on = false
	player_cam.capture_mouse(false)
	player_cam.show_score_screen(player_cam.score,player_cam.combos)
	queue_free()
	pass



#@onready var speed_boost_timer: Timer = $speed_boost_timer
var double_points:=false
func pickup_item(item:GameManager.PickupItems):
	match item:
		GameManager.PickupItems.POTION:
			manage_health(1,"add")
		GameManager.PickupItems.SPEED:
			player_cam.speed_cooldown.value = 1.0
			speed_boost = true
		GameManager.PickupItems.DOUBLE:
			player_cam.double_cooldown.value = 1.0
			double_points = true
		GameManager.PickupItems.INVINCIBLE:
			invincibility_on = true
			get_tree().create_timer(5).timeout.connect(func invinciblity_resetter():invincibility_on = false)
		GameManager.PickupItems.URF:
			urf_mode = true
			player_cam.urf_cooldown.value = 1.0
			can_dash = true
			player_cam.dash_cooldown.value = 1
			
	
const speed_boost_bleed:float=.005
func manage_speed_boost():
	print("sanity check: ", speed_boost_bleed, " < speed boost bleed | current value > ", player_cam.speed_cooldown.value)
	player_cam.speed_cooldown.value -= speed_boost_bleed
	if player_cam.speed_cooldown.value > 0.001:
		pass
	else:
		speed_boost = false
	
func bound_checker():
	#print("player x at value: ", global_position.x, " > testing against: ", game_manager.navigation_box_limit+1)
	if global_position.x > game_manager.navigation_box_limit+1:
		global_position.x = -global_position.x
	elif global_position.x < -game_manager.navigation_box_limit-1:
		global_position.x = -global_position.x
		
		
		
@export var visual_player:Node3D
const turn_speed:float=20
const y_turn_speed:float=1

func rotate_player(right:bool = true):
	if right:
		if visual_player.rotation_degrees.y < 90:
			visual_player.rotation_degrees.y += turn_speed
	else:
		if visual_player.rotation_degrees.y > -90:
			visual_player.rotation_degrees.y -= turn_speed
			
func turn_up_player(up:bool=true):
	if up:
		if visual_player.rotation_degrees.x >-5:
			visual_player.rotation_degrees.x -= y_turn_speed
	else:
		if visual_player.rotation_degrees.x < 5:
			visual_player.rotation_degrees.x += y_turn_speed
	
	
func do_invincibility():
	visual_player.visible = !visual_player.visible
