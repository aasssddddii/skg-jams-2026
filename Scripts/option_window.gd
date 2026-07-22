extends Panel
@export var back: Button# = $Back
@export var quit: Button# = $Quit
@export var window: Button# = $OptionContainer/RightContainer/MarginContainer/Window
@export var sound: Button# = $OptionContainer/RightContainer/MarginContainer4/Sound
@export var music_slider: HSlider# = $"OptionContainer/RightContainer/MarginContainer2/music slider"
@export var sfx_slider: HSlider# = $"OptionContainer/RightContainer/MarginContainer3/sfx slider"

@export var music_label: Label# = $"OptionContainer/LeftContainer/music label"
@export var sfx_label: Label# = $"OptionContainer/LeftContainer/sfx label"
@export var music_slider_margin: MarginContainer# = $OptionContainer/RightContainer/MarginContainer2
@export var sfx_slider_margin: MarginContainer# = $OptionContainer/RightContainer/MarginContainer3

@export var control_button:Button
@export var control_back_button:Button

@export var option_menu:Control
@export var control_menu:Control

const option_panel_size:=Vector2(421,466)
const option_panel_position:=Vector2(415,91)
const tutorial_panel_size:=Vector2(831,466)
const tutorial_panel_position:=Vector2(210,91)

const start_screen_back_position:=Vector2(165,389)
const game_screen_back_position:=Vector2(64,389)

var current_window_setting:String="WINDOWED"

var game_manager = GameManager
@export var sfx_interactable:Array[Control]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	toggle_tutorial_screen(false)
	setup_display_options()
	control_button.button_down.connect(toggle_tutorial_screen)
	control_back_button.button_down.connect(toggle_tutorial_screen.bind(false))
	sound.button_down.connect(toggle_sound)
	window.button_down.connect(window_cycler)
	quit.button_down.connect(quit_game)
	capture_mouse(false)
	for interactable in sfx_interactable:
		interactable.mouse_entered.connect(func hover_player():play_sfx(load(game_manager.up_sfx)))
	window.grab_focus()
	quit.visible = get_tree().paused
	if get_tree().paused:
		back.position = game_screen_back_position
	else:
		back.position = start_screen_back_position



func setup_display_options():
	sound.text = "ON" if game_manager.sound_on else "OFF"
	window.text = current_window_setting
	music_slider.value = game_manager.music_volume
	sfx_slider.value = game_manager.sfx_volume
	display_volume_sliders()
	
const pause_volume_db:=.2

func pause_audio_volume(choice:bool=true)->void:
	print("normal pause db: ", AudioServer.get_bus_volume_linear(0))
	if choice:
		AudioServer.set_bus_volume_linear(0,pause_volume_db)
	else:
		AudioServer.set_bus_volume_linear(0,1)

func toggle_sound()->void:
	game_manager.sound_on = !game_manager.sound_on
	sound.text = "ON" if game_manager.sound_on else "OFF"
	mute_sound()
	display_volume_sliders()
	
func display_volume_sliders()->void:
	music_label.visible = game_manager.sound_on
	sfx_label.visible = game_manager.sound_on
	music_slider_margin.visible = game_manager.sound_on
	sfx_slider_margin.visible = game_manager.sound_on
	
func mute_sound():
	AudioServer.set_bus_mute(0,!game_manager.sound_on)
	
func _on_music_slider_value_changed(value: float) -> void:
	game_manager.music_volume = value
	AudioServer.set_bus_volume_linear(1,value)


func _on_sfx_slider_value_changed(value: float) -> void:
	game_manager.sfx_volume = value
	AudioServer.set_bus_volume_linear(2,value)


func window_cycler()->void:
	match current_window_setting:
		"FULLSCREEN":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			current_window_setting = "WINDOWED"
		"WINDOWED":
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			current_window_setting = "BOARDERLESS"
		"BOARDERLESS":
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			current_window_setting = "FULLSCREEN"
	window.text = current_window_setting
	
	
	
func capture_mouse(choice:bool = true):
	if choice:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


@export var all_sfx_channels:Array[AudioStreamPlayer3D]

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

func quit_game():
	pause_audio_volume(false)
	game_manager.game_on = false
	game_manager.change_to_scene(game_manager.start_screen,true)
	
func toggle_tutorial_screen(choice:bool = true):
	if choice:
		option_menu.visible = false
		size = tutorial_panel_size
		position = tutorial_panel_position
		control_menu.visible = true
		control_back_button.grab_focus()
	else:
		control_menu.visible = false
		size = option_panel_size
		position = option_panel_position
		option_menu.visible = true
		window.grab_focus()
	
