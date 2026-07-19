extends CharacterBody3D
@export var speed = 1
@export var disired_target_distance:float=.2
@export var stuck_threshold:float=.016
const target_variance:int = 3
@export var navigation_box_limit:=9
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
#@export var player:CharacterBody3D
@onready var targeting_area: Area3D = $Targeting_Area
@onready var player_target: MeshInstance3D = $player_targeting
@onready var player_detector: Area3D = $player_detector
var tracked_player_node
@onready var lunge_range: Area3D = $lunge_range
var lunge_speed:float= 3

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


enum EnemyState {
	IDLE,
	TRACKING,
	LUNGE
}
var current_enemy_state:EnemyState

func  _ready() -> void:
	
	start_location = global_position
	nav_agent.target_position = start_location+Vector3(randi_range(-target_variance,target_variance),randi_range(-target_variance,target_variance),0)
	player_detector.body_entered.connect(player_detected)
	player_detector.body_exited.connect(player_escaped)
	lunge_range.body_entered.connect(player_in_lunge_range)
	lunge_range.body_exited.connect(lunge_leaver)

func _physics_process(delta: float) -> void:
	timer += delta
	if !can_lunge:
		if last_lunge + lunge_cooldown <= timer:
			can_lunge = true
	
	match current_enemy_state:
		EnemyState.IDLE:
			#if name == "Enemy":
				#print("global_position: ",global_position, "\n next path position: ", nav_agent.get_next_path_position())
			
			if global_position.distance_to(nav_agent.target_position)<disired_target_distance or global_position.distance_to(last_position)<stuck_threshold: #or (abs(velocity.x)<1 or abs(velocity.y)<1):
				set_target(global_position+Vector3(randi_range(-target_variance,target_variance),randi_range(-target_variance,target_variance),0))
			pass
		EnemyState.TRACKING:
			if tracked_player_node:
				set_target(tracked_player_node.global_position)
			pass
		EnemyState.LUNGE:
			#set_target(global_position)
			pass
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
	move_and_slide()
		
	
	
func move():
	#if global_position.distance_to(nav_agent.get_next_path_position()) < .1 and name == "Enemy":
		#print("Not stuck")
	
	
	last_position = global_position
	var current_position = global_transform.origin
	var next_position = nav_agent.get_next_path_position()
	var direction = (next_position - current_position).normalized()
	velocity = direction * speed
	
func player_detected(body):
	if body.is_in_group("player") and body.name == "Player":
		player_position = body.global_position
		tracked_player_node = body
		current_enemy_state = EnemyState.TRACKING
func player_escaped(body):
	if body.is_in_group("player") and body.name == "Player":
		set_target(global_position+Vector3(randi_range(-target_variance,target_variance),randi_range(-target_variance,target_variance),0))
		current_enemy_state = EnemyState.IDLE
	
func player_in_lunge_range(body):
	if body.is_in_group("player") and body.name == "Player":
		#print("player enter lunge")
		if can_lunge:
			#print("enemy can lunge")
			last_lunge = timer
			current_enemy_state = EnemyState.LUNGE
			var direction = body.global_position - global_position
			direction = direction.normalized()
			velocity = direction * lunge_speed
			can_lunge = false
		else:
			#print("enemy cannot lunge")
			set_target(body.global_position)
			current_enemy_state = EnemyState.TRACKING
func lunge_leaver(body):
	if body.is_in_group("player") and body.name == "Player":
		await get_tree().create_timer(.5).timeout
		player_position = body.global_position
		#tracked_player_node = body
		current_enemy_state = EnemyState.TRACKING
		#print("player leaving lunge")

func set_target(target:Vector3):
	nav_map = get_world_3d().navigation_map
	if target.x > navigation_box_limit:
		target.x = navigation_box_limit
	if target.x < -navigation_box_limit:
		target.x = -navigation_box_limit
	if target.y > navigation_box_limit:
		target.y = navigation_box_limit
	if target.y < -navigation_box_limit:
		target.y = -navigation_box_limit
	nav_agent.target_position = NavigationServer3D.map_get_closest_point(nav_map,target)


func display_player_target(choice:bool=false):
	player_target.visible = choice
	
#func get_position_outside_radius(target_position) -> Vector3:
	#var direction = global_position - target_position
	#if direction.is_zero_approx():
		#direction = Vector3.RIGHT
	#return target_position + direction.normalized() * player_radius
