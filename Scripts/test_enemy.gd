extends CharacterBody3D
@export var speed = 1
@export var disired_target_distance:float=.2
@export var stuck_threshold:float=.003
const target_variance:int = 1
@export var navigation_box_limit:=9
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
#@export var player:CharacterBody3D
@onready var targeting_area: Area3D = $Targeting_Area
@onready var player_target: MeshInstance3D = $player_targeting


var nav_map
var start_location
var last_position:Vector3

enum EnemyState {
	IDLE,
	TRACKING
}
var current_enemy_state:EnemyState

func  _ready() -> void:
	
	start_location = global_position
	nav_agent.target_position = start_location+Vector3(randi_range(-target_variance,target_variance),randi_range(-target_variance,target_variance),0)
	
	pass


func _physics_process(delta: float) -> void:

	
	match current_enemy_state:
		EnemyState.IDLE:
			if name == "Enemy":
				print("global_position: ",global_position, "\n last position: ", last_position)
			
			if global_position.distance_to(nav_agent.target_position)<disired_target_distance or global_position.distance_to(last_position)<stuck_threshold: #or (abs(velocity.x)<1 or abs(velocity.y)<1):
				set_target(start_location+Vector3(randi_range(-target_variance,target_variance),randi_range(-target_variance,target_variance),0))
			pass
		EnemyState.TRACKING:
			pass
		_:
			print("Enemy State not Implemented")
	for body in targeting_area.get_overlapping_bodies():
		if body.is_in_group("player") and body is RayCast3D:
			display_player_target(true)
		else:
			display_player_target(false)
	move()
	move_and_slide()
	pass
	
	
func move():
	last_position = global_position
	var current_position = global_transform.origin
	var next_position = nav_agent.get_next_path_position()
	var direction = (next_position - current_position).normalized()
	velocity = direction * speed
	
	
	
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
