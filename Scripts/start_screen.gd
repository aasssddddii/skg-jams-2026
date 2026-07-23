extends Node3D

#@export var sub_viewport: SubViewport
#@export var start_screen: Control
#@export var credits_screen: Control
#
#@export var thank_you: Label
#@export 
@export var sub_viewport: SubViewport #= $Camera3D/SubViewportContainer/SubViewport
@export var start_screen: Control #= $Camera3D/SubViewportContainer/SubViewport/StartScreen
@export var credits_screen: Control #= $Camera3D/SubViewportContainer/SubViewport/CreditsScreen
@export var highscore_screen:Control
@export var thank_you: Label #= $"Camera3D/SubViewportContainer/SubViewport/CreditsScreen/Thank you"
@export var sfx_interactable:Array[Control]
@export var start:Button
@export var player_animation_player:AnimationPlayer


@onready var back: Button = $Camera3D/SubViewportContainer/SubViewport/CreditsScreen/Back


var game_manager = GameManager
var open_options_menu:Panel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	thank_you.visible = false
	start.grab_focus()
	for interactable in sfx_interactable:
		interactable.mouse_entered.connect(func hover_player():play_sfx(load(game_manager.up_sfx)))
		interactable.button_down.connect(func click_player():play_sfx(game_manager.BUTTON_CLICK))
		#interactable.mouse_exited.connect(func remove_player():play_sfx(load(game_manager.down_sfx)))
	start.button_down.connect(func game_flair_sfx(): play_sfx(game_manager.start_game_sfx))
	reset_warning.visible = false
	game_manager.load_highscore()
	player_animation_player.play("Flying Idle")
	display_screen(start_screen)
	

func _process(delta: float) -> void:
	animate_player()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		play_sfx(load(game_manager.up_sfx))
	elif event.is_action_pressed("ui_down"):
		play_sfx(load(game_manager.down_sfx))

func display_screen(screen):
	#reset screens
	for child in sub_viewport.get_children():
		child.visible = false
	if screen != game_manager.option_menu:
		screen.visible = true
	else:
		var next_option_menu = screen.instantiate()
		sub_viewport.add_child(next_option_menu)
		open_options_menu = next_option_menu
		next_option_menu.back.button_down.connect(_on_option_back_button_down)
	

func _on_start_button_down() -> void:
	game_manager.change_to_scene(game_manager.game_scene)


func _on_options_button_down() -> void:
	display_screen(game_manager.option_menu)


func _on_credits_button_down() -> void:
	display_screen(credits_screen)
	back.grab_focus()


func _on_quit_button_down() -> void:
	get_tree().quit()

func _on_option_back_button_down() -> void:
	open_options_menu.queue_free()
	display_screen(start_screen)
	start.grab_focus()
	
	
func _on_credits_back_button_down() -> void:
	display_screen(start_screen)
	start.grab_focus()
	
	
@export var all_sfx_channels:Array[AudioStreamPlayer3D]

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


func _on_highscroe_back_button_down() -> void:
	display_screen(start_screen)
	open_reset_warning(false)
	start.grab_focus()


func _on_highscore_button_down() -> void:
	setup_highscore_screen()
	display_screen(highscore_screen)
	animate_highscores()

const ui_highscore = preload("uid://rq7t4gujvmwe")
const ui_username = preload("uid://bqqumdwl0jf5v")
@export var username_container: VBoxContainer# = $Camera3D/SubViewportContainer/SubViewport/HighscoreScreen/Panel/HighscoreContainer/LeftContainer
@export var highscore_container: VBoxContainer# = $Camera3D/SubViewportContainer/SubViewport/HighscoreScreen/Panel/HighscoreContainer/RightContainer

@export var reset_warning:ColorRect

#Background setup
func setup_highscore_screen():
	for index in username_container.get_children().size():
		username_container.get_child(index).queue_free()
	for index in highscore_container.get_children().size():
		highscore_container.get_child(index).queue_free()
	
	for highscore_data in game_manager.highscore_lib.highscores:
		var next_username = ui_username.instantiate()
		next_username.text = highscore_data.keys()[0] + " --- "
		username_container.add_child(next_username)
		next_username.modulate.a = 0
		var next_highscore = ui_highscore.instantiate()
		next_highscore.text = var_to_str(highscore_data.values()[0])
		highscore_container.add_child(next_highscore)
		next_highscore.modulate.a = 0

func animate_highscores():
	var label_tweener = get_tree().create_tween()
	for index in username_container.get_children().size():
		label_tweener.tween_property(username_container.get_child(index),"modulate:a",1,.3)
		label_tweener.tween_property(highscore_container.get_child(index),"modulate:a",1,.3)
		
		
		
		
		
		

func open_reset_warning(choice:bool = true):
	reset_warning.visible = choice
	#back.visible = !choice
		
func _on_reset_button_down() -> void:
	open_reset_warning()
	pass # Replace with function body.


func _on_yes_reset_button_down() -> void:
	game_manager.remove_highscore()
	open_reset_warning(false)
	setup_highscore_screen()
	animate_highscores()


func _on_no_reset_button_down() -> void:
	open_reset_warning(false)
	pass # Replace with function body.
	
@export var visual_player:Node3D
var animate_player_up:=true
const max_player_height:=-0.448
const min_player_height:=-1.389
func animate_player():
	if animate_player_up:
		visual_player.position.y += .003
		if visual_player.position.y > max_player_height:
			animate_player_up = false
	else:
		visual_player.position.y -= .003
		if visual_player.position.y < min_player_height:
			animate_player_up = true
	pass
