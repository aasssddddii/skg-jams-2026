extends Camera3D

@export var player:CharacterBody3D
const bounds_distance:float=1.5
const zoom_speed:int=2

var cam_speed:float=.017
var game_manager = GameManager
@export var center_x:bool
@export var center_y:bool
@export var sub_viewport: SubViewport 

@export var player_ui:Control
@export var grapple_cooldown: TextureProgressBar 
@export var dash_cooldown: TextureProgressBar
@export var health_container: HBoxContainer
@export var ui_score:Label

@export var combo_screen:Control
@export var ui_enemies_defeated:Label
@export var combo_Label_Container:VBoxContainer
@export var combo_amount_Container:VBoxContainer

@onready var combo_label_prefab = load("res://Prefabs/combo_label.tscn")
@onready var ui_combo_prefab = load("res://Prefabs/ui_combo_amount.tscn")

var next_option_window
@onready var cam_mover:=get_parent()

#player score variables
var score:int
var multiplyer:=1
var combos:Array[Dictionary]

func _ready() -> void:
	ui_score.text = var_to_str(score)

func _process(delta: float) -> void:
	if player:
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
		health_container.get_child(i).visible = false
		if i <= health-1:
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
	
	
	
func add_combo(combo_to_add:Dictionary):
	print("trying to add combo: ", combo_to_add)
	var found_combo = combos.find_custom(func conbo_finder(checker):return checker.keys().find(combo_to_add.keys()[0]) != -1)
	if found_combo != -1:
		var combo_ref = combos[found_combo]
		combo_ref.values()[0] += 1
		pass
	else:
		combos.append(combo_to_add)
# 0:0  | combo value:Combo amount
# 2:10 | Example
#
#
func show_score_screen(enemies_defeated:int,combos:Array[Dictionary]):
	ui_enemies_defeated.text = var_to_str(enemies_defeated)
	for combo in combos:
		var next_label = combo_label_prefab.instantiate()
		next_label.text = var_to_str(combo.keys()[0]) + "x Combo(s) x"
		combo_Label_Container.add_child(next_label)
		var next_combo = ui_combo_prefab.instantiate()
		next_combo.text = var_to_str(combo.values()[0])
		combo_amount_Container.add_child(next_combo)
	player_ui.visible = false
	combo_screen.visible = true
	
	
	

#CONTINUE BUTTON FOR FINAL COMBO PAGE
func _on_button_button_down() -> void:
	game_manager.change_to_scene(game_manager.start_screen,true)
	pass # Replace with function body.
