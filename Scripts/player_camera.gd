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
	#play_sfx(load(player_sfx1))

func _process(delta: float) -> void:
	if player:
		cam_mover.global_position = player.global_position
			
	##DELETE FOR PRODUCTION
	#if Input.is_action_just_pressed("debug_zoom_in"):
		#cam_mover.global_position.z += zoom_speed
	#if Input.is_action_just_pressed("debug_zoom_out"):
		#cam_mover.global_position.z -= zoom_speed


func update_ui(grapple_amount:float, dash_amount:float,health:int):
	grapple_cooldown.value = grapple_amount
	dash_cooldown.value = dash_amount
	
	for i in 3:
		health_container.get_child(i).visible = false
		if i <= health-1:
			health_container.get_child(i).visible = true
	
	
func _input(event: InputEvent) -> void:
	if game_manager.game_on:
		if event.is_action_pressed("pause") and !get_tree().paused:
			next_option_window = game_manager.option_menu.instantiate()
			sub_viewport.add_child(next_option_window)
			next_option_window.back.button_down.connect(option_back)
			capture_mouse(false)
			get_tree().paused = true
			next_option_window.pause_audio_volume(get_tree().paused)
		elif event.is_action_pressed("pause") and get_tree().paused:
			get_tree().paused = false
			next_option_window.pause_audio_volume(get_tree().paused)
			next_option_window.queue_free()
			capture_mouse()
			
			next_option_window = null
			
	
	
func option_back()->void:
	get_tree().paused = false
	next_option_window.pause_audio_volume(get_tree().paused)
	next_option_window.queue_free()
	capture_mouse()
	
	next_option_window = null
		

func add_points(amount:int,multi:int=1)->void:
	score += amount * multi
	ui_score.text = var_to_str(score)
	
	
	
func add_combo(combo_to_add:Dictionary):
	#print("trying to add combo: ", combo_to_add)
	var found_combo = combos.find_custom(func conbo_finder(checker):return checker.keys().find(combo_to_add.keys()[0]) != -1)
	if found_combo != -1:
		var combo_ref = combos[found_combo]
		combo_ref.values()[0] += 1
		pass
	else:
		combos.append(combo_to_add)
# 0:0  | combo value:Combo amount
# 2:10 | Example
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




func get_mouse_world_position() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = project_ray_origin(mouse_pos)
	var ray_direction = project_ray_normal(mouse_pos)
	var target_z = global_position.z
	if abs(ray_direction.z) < 0.0001:
		return global_position
	var distance = (target_z - ray_origin.z) / ray_direction.z

	return ray_origin + ray_direction * distance


func capture_mouse(choice:bool = true):
	if choice:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		
@export var player_sfxs :Array[AudioStreamOggVorbis]
@export var all_sfx_channels:Array[AudioStreamPlayer3D]
const ENEMY_DEATH = preload("uid://r1ecr241jsi0")

var currently_playing:Array[Dictionary]
func play_sfx(audio_stream_resource:AudioStreamOggVorbis):
	var free_sfx_player = free_sfx_finder()
	if free_sfx_player is AudioStreamPlayer3D:
		free_sfx_player.stream = audio_stream_resource
		currently_playing.append({free_sfx_player:audio_stream_resource})
		free_sfx_player.play()
		free_sfx_player.finished.connect(func playing_leaver():
			print("removing: audio sources ", currently_playing )
			if !currently_playing.is_empty():
				currently_playing.remove_at(currently_playing.find_custom(func audio_resource_finder(checker):return checker.values()[0] == audio_stream_resource)))
	else:
		print("Not enough SFX Channels")
	
func free_sfx_finder():
	for sfx_player in all_sfx_channels:
		if !sfx_player.playing:
			return sfx_player
	return false
		
		
		
		
		

	
	
	
	
	
	
	
