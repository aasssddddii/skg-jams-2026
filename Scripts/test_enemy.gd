extends CharacterBody3D

var game_manager = GameManager

@export var speed = 1
@export var disired_target_distance:float=.2
@export var stuck_threshold:float=.016
const knockback_force: float = 2.0
const target_variance:int = 6
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
#@export var player:CharacterBody3D
@onready var targeting_area: Area3D = $Targeting_Area
@onready var player_target: MeshInstance3D = $player_targeting
@onready var player_detector: Area3D = $player_detector
var tracked_player_node
@onready var lunge_range: Area3D = $lunge_range
var lunge_speed:float= 3
var desired_lunge_distance:float=.7
@onready var enemy_hitbox: Area3D = $enemy_hitbox


@onready var enemy_bullet:=load("res://Prefabs/enemy_bullet.tscn")
@onready var bullet_layer := get_node("../../BulletLayer")
var nav_map
var start_location
var last_position:Vector3

var player_position:Vector3

#ADD LUNGE COOLDOWN
var can_lunge:bool=true
const lunge_cooldown:=4
var last_lunge:float
var timer:float
const player_radius:int =10
var lunging:bool

var player_is_in_lunge_range:bool

var sfx_played:bool

enum EnemyState {
	IDLE,
	TRACKING,
	LUNGE,
	FIRE
}
var current_enemy_state:EnemyState
var can_fire:=true
@export var debugging_enemy:bool


func  _ready() -> void:
	
	start_location = global_position
	nav_agent.target_position = start_location+Vector3(randi_range(-target_variance,target_variance),randi_range(-target_variance,target_variance),0)
	player_detector.body_entered.connect(player_detected)
	player_detector.body_exited.connect(player_escaped)
	lunge_range.body_entered.connect(player_in_lunge_range)
	lunge_range.body_exited.connect(lunge_leaver)
	enemy_hitbox.body_entered.connect(player_hitter)

func _physics_process(delta: float) -> void:
	timer += delta
	if !can_lunge:
		if last_lunge + lunge_cooldown <= timer:
			can_lunge = true
	if debugging_enemy:
		print("current enemy state =: ", current_enemy_state)
	match current_enemy_state:
		EnemyState.IDLE:
			#if name == "Enemy":
				#print("global_position: ",global_position, "\n next path position: ", nav_agent.get_next_path_position())
			sfx_played = false
			if global_position.distance_to(nav_agent.target_position)<disired_target_distance or global_position.distance_to(last_position)<stuck_threshold: #or (abs(velocity.x)<1 or abs(velocity.y)<1):
				set_target(global_position+Vector3(randi_range(-target_variance,target_variance),randi_range(-target_variance,target_variance),0))
			pass
		EnemyState.TRACKING:
			#if tracked_player_node:
				#set_target(tracked_player_node.global_position)
			#pass
			if tracked_player_node:
				if !sfx_played:
					play_sfx(enemy_sfxs.pick_random())
					sfx_played = true
				if player_is_in_lunge_range and !can_lunge:
					var direction_from_player = global_position - tracked_player_node.global_position
					
					if direction_from_player.length_squared() > 0.001:
						direction_from_player = direction_from_player.normalized()
						
						var desired_position = (tracked_player_node.global_position+ direction_from_player* desired_lunge_distance)
						
						set_target(desired_position)
				if can_fire:
					current_enemy_state = EnemyState.FIRE
				elif !can_fire:
					set_target(tracked_player_node.global_position)
		EnemyState.LUNGE:
			#set_target(global_position)
			pass
		EnemyState.FIRE:
			if can_fire and !game_manager.debug_mode:
				play_sfx(ENEMY_FIRE)
				var next_bullet = enemy_bullet.instantiate()
				bullet_layer.add_child(next_bullet)
				next_bullet.global_position = global_position
				next_bullet.linear_velocity = global_position.direction_to(tracked_player_node.global_position) * 3
				can_fire = false
				get_tree().create_timer(2).timeout.connect(func fire_setter():can_fire = true)
				get_tree().create_timer(.25).timeout.connect(func fire_winded():current_enemy_state = EnemyState.TRACKING)
			elif game_manager.debug_mode:
				can_fire = false
				get_tree().create_timer(2).timeout.connect(func fire_setter():can_fire = true)
				get_tree().create_timer(.25).timeout.connect(func fire_winded():current_enemy_state = EnemyState.TRACKING)

		_:
			print("Enemy State not Implemented")
			
			
	#player targeting check
	
	for body in targeting_area.get_overlapping_areas():
		if body.is_in_group("grapple") and body.get_node("../..").can_grapple:
			display_player_target(true)
			
			#print("player can grapple: ",  body.get_node("../..").can_grapple)
			continue
		else:
			display_player_target(false)
			
			
	if current_enemy_state != EnemyState.LUNGE:
		move()
	if current_enemy_state != EnemyState.FIRE:
		move_and_slide()
		
	
	
func move():
	
	
	last_position = global_position
	var current_position = global_transform.origin
	var next_position = nav_agent.get_next_path_position()
	var direction = (next_position - current_position).normalized()
	velocity = direction * speed
	
func player_detected(body):
	if body.is_in_group("player") and body.name == "Player":
		current_enemy_state = EnemyState.TRACKING
		player_position = body.global_position
		tracked_player_node = body
		
func player_escaped(body):
	if body.is_in_group("player") and body.name == "Player":
		set_target(global_position+Vector3(randi_range(-target_variance,target_variance),randi_range(-target_variance,target_variance),0))
		current_enemy_state = EnemyState.IDLE
	
func player_in_lunge_range(body):
	if body.is_in_group("player") and body.name == "Player":
		#print("player enter lunge")
		player_is_in_lunge_range = true
		if can_lunge:
			#print("enemy can lunge")
			lunge(body)
		else:
			#print("enemy cannot lunge")
			set_target(body.global_position)
			current_enemy_state = EnemyState.TRACKING
			
			
func lunge(body):
		last_lunge = timer
		lunging = true
		get_tree().create_timer(.25).timeout.connect(func lunging_resetter(): lunging = false)
		current_enemy_state = EnemyState.LUNGE
		var direction = body.global_position - global_position
		direction = direction.normalized()
		velocity = direction * lunge_speed
		can_lunge = false
func lunge_leaver(body):
	if body.is_in_group("player") and body.name == "Player":
		if game_manager.game_on:
			player_is_in_lunge_range = false
			await get_tree().create_timer(.5).timeout
			if game_manager.game_on:
				player_position = body.global_position
				#tracked_player_node = body
				current_enemy_state = EnemyState.TRACKING
				#print("player leaving lunge")
			else:
				current_enemy_state = EnemyState.IDLE
		else:
			current_enemy_state = EnemyState.IDLE

func set_target(target:Vector3):
	nav_map = get_world_3d().navigation_map
	if target.x > game_manager.navigation_box_limit:
		target.x = game_manager.navigation_box_limit
	if target.x < -game_manager.navigation_box_limit:
		target.x = -game_manager.navigation_box_limit
	if target.y > game_manager.navigation_box_limit:
		target.y = game_manager.navigation_box_limit
	if target.y < -game_manager.navigation_box_limit:
		target.y = -game_manager.navigation_box_limit
	nav_agent.target_position = NavigationServer3D.map_get_closest_point(nav_map,target)


func display_player_target(choice:bool=false):
	player_target.visible = choice
	
	


func player_hitter(body: CharacterBody3D) -> void:
	if body.is_in_group("player") and body.name == "Player":
		if !body.dashing and !body.grapple_cast.grappling:
			body.manage_health()
			var knockback_direction :Vector3=(body.global_position - global_position)
			if knockback_direction.length_squared() > 0.001:
				knockback_direction = knockback_direction.normalized()
				body.velocity = knockback_direction * knockback_force
				body.velocity.z = 0.0
	
@export var enemy_sfxs :Array[AudioStreamOggVorbis]
@export var all_sfx_channels:Array[AudioStreamPlayer3D]
const ENEMY_FIRE = preload("uid://d26sr6xi5utyb")

var currently_playing:Array[Dictionary]
func play_sfx(audio_stream_resource:AudioStreamOggVorbis):
	var free_sfx_player = free_sfx_finder()
	if free_sfx_player is AudioStreamPlayer3D:
		free_sfx_player.stream = audio_stream_resource
		currently_playing.append({free_sfx_player:audio_stream_resource})
		free_sfx_player.play()
		free_sfx_player.finished.connect(func playing_leaver():
			#print("removing: audio sources ", currently_playing )
			if !currently_playing.is_empty():
				currently_playing.remove_at(currently_playing.find_custom(func audio_resource_finder(checker):return checker.values()[0] == audio_stream_resource)))
	else:
		print("Not enough SFX Channels")
	
func free_sfx_finder():
	for sfx_player in all_sfx_channels:
		if !sfx_player.playing:
			return sfx_player
	return false
