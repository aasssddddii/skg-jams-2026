extends Camera3D

@export var player:CharacterBody3D
const bounds_distance:float=1.5
const zoom_speed:int=2

var cam_speed:float=.017
var game_manager = GameManager
@export var center_x:bool
@export var center_y:bool
@export var sub_viewport: SubViewport 

@export var grapple_cooldown: TextureProgressBar 
@export var dash_cooldown: TextureProgressBar

@export var health_container: HBoxContainer
@export var ui_score:Label

var next_option_window
@onready var cam_mover:=get_parent()

#player score variables
var score:int
var multiplyer:=1

func _ready() -> void:
	ui_score.text = var_to_str(score)

func _process(delta: float) -> void:
	var player_position:=Vector2(player.global_position.x,player.global_position.y)
	var vec_2_pos:=Vector2(cam_mover.global_position.x,cam_mover.global_position.y)
	#print("distance to player: ", player_position.distance_to(vec_2_pos), " > bound distance: ",bounds_distance, "cam speed: ", cam_speed)
	if player_position.distance_to(vec_2_pos) > bounds_distance:
		center_x = true
		center_y = true
	
	if center_x:
		cam_mover.global_position.x = move_toward(cam_mover.global_position.x,player.global_position.x,cam_speed)
		if cam_mover.global_position.x == player.global_position.x:
			center_x = false
	if center_y:
		cam_mover.global_position.y = move_toward(cam_mover.global_position.y,player.global_position.y,cam_speed)
		if cam_mover.global_position.y == player.global_position.y:
			center_y = false
	if center_y or center_x:
		cam_speed += player_position.distance_to(vec_2_pos) * .001
	elif !center_x and !center_y:
		cam_speed = .017
			
	##DELETE FOR PRODUCTION
	if Input.is_action_just_pressed("debug_zoom_in"):
		cam_mover.global_position.z += zoom_speed
	if Input.is_action_just_pressed("debug_zoom_out"):
		cam_mover.global_position.z -= zoom_speed


func update_ui(grapple_amount:float, dash_amount:float,health:int):
	grapple_cooldown.value = grapple_amount
	dash_cooldown.value = dash_amount
	
	for i in 3:
		if i <= health:
			health_container.get_child(i).visible = true
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and !get_tree().paused:
		next_option_window = game_manager.option_menu.instantiate()
		sub_viewport.add_child(next_option_window)
		next_option_window.back.button_down.connect(option_back)
		get_tree().paused = true
	elif event.is_action_pressed("pause") and get_tree().paused:
		next_option_window.queue_free()
		get_tree().paused = false
		next_option_window = null
	
	
func option_back()->void:
		next_option_window.queue_free()
		get_tree().paused = false
		next_option_window = null

func add_points(amount:int,multi:int=1)->void:
	score += amount * multi
	ui_score.text = var_to_str(score)
	
	
	
	
