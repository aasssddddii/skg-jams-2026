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
@export var speed_cooldown:TextureProgressBar
@export var health_container: HBoxContainer
@export var double_cooldown:TextureProgressBar
@export var urf_cooldown:TextureProgressBar
@export var ui_score:Label

@export var combo_screen:Control
@export var ui_enemies_defeated:Label
@export var combo_Label_Container:VBoxContainer
@export var combo_amount_Container:VBoxContainer
@export var ui_rating:Label
@export var ui_message:Label

@onready var combo_label_prefab = load("res://Prefabs/combo_label.tscn")
@onready var ui_combo_prefab = load("res://Prefabs/ui_combo_amount.tscn")

var next_option_window
@onready var cam_mover:=get_parent()

#player score variables
var score:int#=12
var multiplyer:=1
var combos:Array[Dictionary] #= [{3:1}]
const PIXELATED_VFX = preload("uid://dn64ccglbu21d")

var make_rating_bigger:=true
var just_paused:bool = false

func _ready() -> void:
	ui_score.text = var_to_str(score)
	final_score.visible = false
	final_label.visible = false
	ui_rating.visible = false
	ui_message.visible = false
	#if !OS.has_feature("web"):
	#add_child(PIXELATED_VFX.instantiate())
	await get_tree().process_frame
	#play_sfx(load(player_sfx1))

func _process(delta: float) -> void:
	if player:
		cam_mover.global_position.x = player.global_position.x
		cam_mover.global_position.y = player.global_position.y
			

	
	manage_double_points()
	manage_urf()
	if final_score_is_animating:
		animate_final_score()
		
	if ui_rating.visible:
		var manip_font_size = ui_rating.get_theme_font_size("font_size")
		if manip_font_size <= 250 and make_rating_bigger:
			animate_rating()
		elif manip_font_size >= 200 and !make_rating_bigger:
			animate_rating(false)

func update_ui(grapple_amount:float, dash_amount:float,health:int):
	grapple_cooldown.value = grapple_amount
	dash_cooldown.value = dash_amount
	
	for i in 5:
		health_container.get_child(i).visible = false
		if i <= health-1:
			health_container.get_child(i).visible = true
	
	
func _input(event: InputEvent) -> void:
	if game_manager.game_on:
		if event.is_action_pressed("pause") and !get_tree().paused:
			capture_mouse(false)
			get_tree().paused = true
			just_paused = true
			next_option_window = game_manager.option_menu.instantiate()
			sub_viewport.add_child(next_option_window)
			next_option_window.back.button_down.connect(option_back)
			next_option_window.pause_audio_volume(get_tree().paused)
		elif event.is_action_pressed("pause") and get_tree().paused:
			get_tree().paused = false
			next_option_window.pause_audio_volume(get_tree().paused)
			next_option_window.queue_free()
			capture_mouse()
			get_tree().create_timer(.1).timeout.connect(func pause_buffer(): just_paused=false)
			
			next_option_window = null
		#if game_manager.debug_mode:
		#if event.is_action_pressed("debug_zoom_in"):
			#global_position.z -= zoom_speed
		#if event.is_action_pressed("debug_zoom_out"):
			#global_position.z += zoom_speed
			
	
func option_back()->void:
	get_tree().paused = false
	next_option_window.pause_audio_volume(get_tree().paused)
	next_option_window.queue_free()
	capture_mouse()
	get_tree().create_timer(.1).timeout.connect(func pause_buffer(): just_paused=false)
	next_option_window = null
		

func add_points(amount:int,multi:int=1)->void:
	score += amount * multi
	ui_score.text = var_to_str(score)
	if score >= 5:
		game_manager.max_enemies += 1
	
	
	
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
const SWORD_CLASH_SOUND_EFFECT = preload("uid://ddg2kmkeik70h")
const TICKER = preload("uid://crn2jjtla612s")
@export var final_label:Label
@export var final_score:Label
var final_score_calc:int
var final_score_is_animating:bool
@export var highscore_input:Control
@export var save_button:Button
@export var text_input:LineEdit
@onready var saved_splash: Label = $SubViewportContainer/SubViewport/end_game_screen/Panel/saved_splash


func sort_descending(a, b):
	if a.keys()[0] < b.keys()[0]:
		return true
	return false

func show_score_screen(enemies_defeated:int,combos:Array[Dictionary]):
	#add animation for score
	player_ui.visible = false
	highscore_input.visible = false
	saved_splash.visible = false
	combo_screen.visible = true
	text_input.text_changed.connect(func save_shower(text):save_button.visible = true if text != "" else false)
	
	combos.sort_custom(sort_descending)
	
	play_sfx(SWORD_CLASH_SOUND_EFFECT)
	
	ui_enemies_defeated.text = "0"
	
	for starting_number in enemies_defeated:
		ui_enemies_defeated.text = var_to_str(starting_number+1)
		play_sfx(TICKER)
		await get_tree().create_timer(.1).timeout
	
	await score_slower().timeout
	final_score_calc = score
	for combo in combos:
		var next_label = combo_label_prefab.instantiate()
		next_label.text = var_to_str(combo.keys()[0]) + "x Combo(s) x"
		combo_Label_Container.add_child(next_label)
		play_sfx(SWORD_CLASH_SOUND_EFFECT)
		
		
		var next_combo = ui_combo_prefab.instantiate()
		combo_amount_Container.add_child(next_combo)
		next_combo.text = "0"
		await score_slower().timeout
		for starting_number in  combo.values()[0]:
			next_combo.text = var_to_str(starting_number+1)
			play_sfx(TICKER)
			await get_tree().create_timer(.1).timeout
		
		final_score_calc += combo.keys()[0] * combo.values()[0] 
		
	#Flair Multiplier
	final_score_calc *= 25
	#Final score
	#var final_label = combo_label_prefab.instantiate()
	#combo_Label_Container.add_child(final_label)
	
	#var final_score = ui_combo_prefab.instantiate()
	
	final_score.visible = true
	final_score.text = "0"
	final_label.visible = true
	play_sfx(SWORD_CLASH_SOUND_EFFECT)
	await score_slower().timeout
	final_score_is_animating = true
	
	#var final_time_speed_up:float=.01
	#for number in final_score_calc:
		#final_score.text = var_to_str(number+1)
		#play_sfx(TICKER)
		#await get_tree().create_timer(final_time_speed_up).timeout
		#final_time_speed_up -= .01
		#if number > 50:
			#for i in number:
				#continue
	
	
	
#var final_score_displayed
var display_score:int
func animate_final_score():
	if display_score < final_score_calc:
		play_sfx(TICKER)
		display_score+=1
		final_score.text = var_to_str(display_score)

		if display_score > 1000:
			display_score += 1000
		elif display_score > 500:
			display_score += 500
		elif display_score > 100:
			display_score += 100
		elif display_score > 50:
			display_score += 10
	else:
		final_score_is_animating = false
		final_score.text = var_to_str(final_score_calc)
		var score_data = get_rating(final_score_calc)
		ui_rating.text = score_data["rating"]
		ui_message.text = score_data["message"]
		save_button.button_down.connect(func highscore_saver(): 
			highscore_input.visible = false
			saved_splash.visible = true
			game_manager.save_highscore({text_input.text:final_score_calc}))
			
			
		if final_score_calc > 0:
			highscore_input.visible = true
		save_button.visible = false
		ui_rating.visible = true
		ui_message.visible = true

	
func animate_rating(go_up:bool = true):
	var manip_font_size = ui_rating.get_theme_font_size("font_size")
	if go_up:
		ui_rating.add_theme_font_size_override("font_size", manip_font_size+2)
		if manip_font_size == 250:
			make_rating_bigger = false
	else:
		ui_rating.add_theme_font_size_override("font_size", manip_font_size-2)
		if manip_font_size == 200:
			make_rating_bigger = true
	#print("I can manipulate font size: ", manip_font_size)
	
func score_slower()->SceneTreeTimer:
	return get_tree().create_timer(.4)

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
	if choice and !OS.has_feature("web"):
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
		
		
		
const f_threshold:=150
const d_threshold:=300
const c_threshold:=500
const b_threshold:=700
const a_threshold:=1000
const s_threshold:=5000
const ss_threshold:=10000
const sss_threshold:=50000
		
func get_rating(score:int)->Dictionary:
	var rating_data:Dictionary = {
		"rating":"X",
		"message":"ui_message"
	}
	#print("highest combo: ", combos.back())
	var auto_b:=false
	if !combos.is_empty():
		if combos.back().keys()[0] >= 5:
			auto_b = true
	
	if score <= f_threshold and !auto_b:
		rating_data["rating"] = "F"
		rating_data["message"] = ["Get Some More Combos","More Combos = More Points"].pick_random()
	elif score <= d_threshold and !auto_b:
		rating_data["rating"] = "D"
		rating_data["message"] = ["Getting Better","Dragon Scales Are Hard"].pick_random()
	elif score <= c_threshold and !auto_b:
		rating_data["rating"] = "C"
		rating_data["message"] = ["Not Bad Scalebreaker!","The Tides of War are Turning"].pick_random()
	elif score <= b_threshold or (auto_b and score <= b_threshold ):
		rating_data["rating"] = "B"
		rating_data["message"] = ["Who you gonna call? \nScale Breakers!"].pick_random()
	elif score <= a_threshold:
		rating_data["rating"] = "A"
		rating_data["message"] = ["A+ Scalebreaking,\nGreat Job"].pick_random()
	elif score <= s_threshold:
		rating_data["rating"] = "S"
		rating_data["message"] = ["No One Will Believe You"].pick_random()
	elif score <= ss_threshold:
		rating_data["rating"] = "SS"
		rating_data["message"] = ["You're Something Else!!","You Win?"].pick_random()
	else:
		rating_data["rating"] = "SSS"
		rating_data["message"] = ["Hero Of Legends","Can anything stop these beasts"].pick_random()
	
	return rating_data
	

var combo_bleedout:=.003
var ability_bleedout:=.001
@export var combo_label: Label
@export var ui_combo: Label
var current_combo:int
	
func manage_combo(refresh:bool = false)->void:
	if combo_label.modulate.a >=0:
		combo_label.modulate.a -= combo_bleedout
		ui_combo.modulate.a -= combo_bleedout
	if refresh:
		current_combo += 1
		#print("combo +1")
		
		combo_label.modulate.a = 1
		ui_combo.modulate.a = 1
	if combo_label.modulate.a <= 0:
		#print("combo dead")
		if current_combo > 1:
			add_combo({current_combo:1})
		current_combo = 0
	#print("modulate sanity check: ", combo_label.modulate.a)
	ui_combo.text = "x "+var_to_str(current_combo)
	#combo_label.outline_modulate.a = combo_label.modulate.a
	#ui_combo.outline_modulate.a = combo_label.modulate.a
		
	
func manage_double_points():
	if double_cooldown.value > 0:
		double_cooldown.value -= ability_bleedout
	else :
		if player:
			player.double_points = false
			
			
func manage_urf():
	if urf_cooldown.value > 0:
		urf_cooldown.value -= ability_bleedout
	else :
		if player:
			player.urf_mode = false
