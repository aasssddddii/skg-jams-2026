extends CharacterBody3D
@export var speed = 1

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
#@export var player:CharacterBody3D
@onready var targeting_area: Area3D = $Targeting_Area

enum EnemyState {
	IDLE,
	TRACKING
}

func  _ready() -> void:
	#nav_agent.target_position = player.global_position
	pass


func _physics_process(delta: float) -> void:
	#move()
	#move_and_slide()
	pass
	
	
func move():
	var current_position = global_transform.origin
	var next_position = nav_agent.get_next_path_position()
	var direction = (next_position - current_position).normalized()
	velocity = direction * speed
