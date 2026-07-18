extends Camera3D

@export var player:CharacterBody3D
const bounds_distance:float=.6
var cam_speed:float=.017

var center_x:bool
var center_y:bool

func _process(delta: float) -> void:
		
		
	if Vector3(global_position.x,global_position.y,0).distance_to(Vector3(player.global_position.x,player.global_position.y,0)) > bounds_distance:
		center_x = true
		center_y = true
		cam_speed = .017
	
	if center_x:
		global_position.x = move_toward(global_position.x,player.global_position.x,cam_speed)
		if global_position.x == player.global_position.x:
			center_x = false
	if center_y:
		global_position.y = move_toward(global_position.y,player.global_position.y,cam_speed)
		if global_position.y == player.global_position.y:
			center_y = false
	if center_y or center_x:
		cam_speed += .00006
			
			
