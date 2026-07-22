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
@export var thank_you: Label #= $"Camera3D/SubViewportContainer/SubViewport/CreditsScreen/Thank you"
@export var sfx_interactable:Array[Control]



@onready var back: Button = $Camera3D/SubViewportContainer/SubViewport/CreditsScreen/Back


var game_manager = GameManager
var open_options_menu:Panel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	thank_you.visible = false
	sfx_interactable[0].grab_focus()
	for interactable in sfx_interactable:
		interactable.mouse_entered.connect(func hover_player():play_sfx(load(game_manager.up_sfx)))
		#interactable.mouse_exited.connect(func remove_player():play_sfx(load(game_manager.down_sfx)))

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
	sfx_interactable[0].grab_focus()
	
	
func _on_credits_back_button_down() -> void:
	display_screen(start_screen)
	sfx_interactable[0].grab_focus()
	
	
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
