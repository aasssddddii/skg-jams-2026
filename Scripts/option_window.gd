extends Panel
@onready var back: Button = $Back
@onready var sound: Button = $OptionContainer/RightContainer/MarginContainer/Sound
@onready var music_slider: HSlider = $"OptionContainer/RightContainer/MarginContainer2/music slider"
@onready var sfx_slider: HSlider = $"OptionContainer/RightContainer/MarginContainer3/sfx slider"

@onready var music_label: Label = $"OptionContainer/LeftContainer/music label"
@onready var sfx_label: Label = $"OptionContainer/LeftContainer/sfx label"
@onready var music_slider_margin: MarginContainer = $OptionContainer/RightContainer/MarginContainer2
@onready var sfx_slider_margin: MarginContainer = $OptionContainer/RightContainer/MarginContainer3

var game_manager = GameManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_display_options()
	sound.button_down.connect(toggle_sound)
	



func setup_display_options():
	sound.text = "ON" if game_manager.sound_on else "OFF"
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
