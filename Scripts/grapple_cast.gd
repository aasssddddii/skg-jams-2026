extends RayCast3D

var game_manager = GameManager

var grappling:bool
var target:CharacterBody3D
#var collision_location:Vector3
#@export var rest_length = 2.0
#@export var stiffness = 10.0
#@export var damping = 1.0
@export var arrived_at_target_distance:=.2
@onready var ray_targeting: MeshInstance3D = $ray_targeting
@onready var grapple_area: Area3D = $grapple_range
#@onready var visual_grapple_pivot: Node3D = $visual_grapple_pivot

@onready var player = get_parent()
var grapple_tweener:Tween




#func _ready() -> void:
	#visual_grapple_pivot.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("up") or Input.is_action_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		grapple_on(true)
		var input_dir:Vector2= Input.get_vector("up","down","left","right")
		rotation.z = input_dir.angle()
		if Input.is_action_just_pressed("grapple"):
			launch()
			pass
		#print("is grappling: ", grappling)
		if grapple_area.get_overlapping_areas().size() >0:
			
			for area in grapple_area.get_overlapping_areas():
				if area.is_in_group("enemy")and get_parent().can_grapple:
					var enemy = area.get_parent()
					enemy.display_player_target(true)
			#if grapple_area.get_collider().is_in_group("enemy"):
				#var enemy = get_collider().get_parent()
				#enemy.display_player_target(true)
		#if Input.is_action_just_released("grapple"):
			#retract()
		if grappling:
			handle_grapple()
	elif(!Input.is_action_pressed("up") and !Input.is_action_pressed("down") and !Input.is_action_pressed("left") and !Input.is_action_pressed("right")):
		#print("USING Mouse at position: ", player.player_cam.project_ray_normal(get_viewport().get_mouse_position()))
		var mouse_direction :Vector3= player.player_cam.project_ray_normal(get_viewport().get_mouse_position())
		grapple_on(true)
		var input_dir:Vector2= Vector2(-mouse_direction.y,mouse_direction.x)
		rotation.z = input_dir.angle()
		if Input.is_action_just_pressed("grapple"):
			launch()
			pass
		#print("is grappling: ", grappling)
		if grapple_area.get_overlapping_areas().size() >0:
			
			for area in grapple_area.get_overlapping_areas():
				if area.is_in_group("enemy")and get_parent().can_grapple:
					var enemy = area.get_parent()
					enemy.display_player_target(true)
		if grappling:
			handle_grapple()
		
	else:
		grapple_on(false)
func launch():
	if grapple_area.get_overlapping_areas().size() >0 and get_parent().can_grapple:
		#print("all overlapping bodies: ",grapple_area.get_overlapping_bodies())
		for area in grapple_area.get_overlapping_areas():
			if area.is_in_group("enemy"):
				target = area.get_parent()
				grappling = true
				get_parent().current_grapple = 0
				get_parent().can_grapple = false
				




func grapple_on(choice:bool):
	enabled = choice
	ray_targeting.visible = choice if !player.dashing else false
	grapple_area.monitoring = choice
	grapple_area.monitorable = choice
	#visual_grapple_pivot.visible = choice
const SWORD_CLASH_SOUND_EFFECT = preload("uid://ddg2kmkeik70h")

func handle_grapple():
	#print("sanity check target: ", target)
	#convert to Grapple tweener with potition moveving not Velocity
	grapple_tweener = get_tree().create_tween()
	grapple_tweener.tween_property(player,"global_position",target.global_position,.1)
	
	print("distance left to enemy: ", player.global_position.distance_to(target.global_position))
	#visual_grapple_pivot.scale.y = player.global_position.distance_to(target.global_position)
	if player.global_position.distance_to(target.global_position) < arrived_at_target_distance:
		
		grappling = false
		player.player_cam.play_sfx(SWORD_CLASH_SOUND_EFFECT)
		target.queue_free()
		game_manager.spawned_enemies.remove_at(game_manager.spawned_enemies.find(target))
		player.player_cam.manage_combo(true)
		player.player_cam.add_points(1,player.player_cam.multiplyer)
		if player.double_points:
			player.player_cam.add_points(1,player.player_cam.multiplyer)
		target = null
		if player.urf_mode:
			player.current_grapple = 1
			player.can_grapple = true
		
	
