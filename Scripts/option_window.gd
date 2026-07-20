extends Panel
@onready var back: Button = $Back
@onready var window: Button = $OptionContainer/RightContainer/MarginContainer/Window
@onready var sound: Button = $OptionContainer/RightContainer/MarginContainer4/Sound
@onready var music_slider: HSlider = $"OptionContainer/RightContainer/MarginContainer2/music slider"
@onready var sfx_slider: HSlider = $"OptionContainer/RightContainer/MarginContainer3/sfx slider"

@onready var music_label: Label = $"OptionContainer/LeftContainer/music label"
@onready var sfx_label: Label = $"OptionContainer/LeftContainer/sfx label"
@onready var music_slider_margin: MarginContainer = $OptionContainer/RightContainer/MarginContainer2
@onready var sfx_slider_margin: MarginContainer = $OptionContainer/RightContainer/MarginContainer3

var current_window_setting:String="WINDOWED"

var game_manager = GameManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_display_options()
	sound.button_down.connect(toggle_sound)
	window.button_down.connect(window_cycler)
	capture_mouse(false)
	



func setup_display_options():
	sound.text = "ON" if game_manager.sound_on else "OFF"
	window.text = current_window_setting
	music_slider.value = game_manager.music_volume
	sfx_slider.value = game_manager.sfx_volume
	display_volume_sliders()
	


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
