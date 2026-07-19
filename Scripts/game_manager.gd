extends Node



var game_on:bool

@onready var option_menu:=preload("res://Prefabs/option_window.tscn")

@onready var game_scene:=preload("res://Scenes/test_scene.tscn")
@onready var stert_screen:=preload("res://Scenes/Start_Screen.tscn")



#music options
var sound_on:=true
var music_volume:float=.3
var sfx_volume:float=.3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_sound()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup_sound()->void:
	AudioServer.set_bus_volume_linear(1,music_volume)
	AudioServer.set_bus_volume_linear(2,sfx_volume)

func change_to_scene(change_scene:PackedScene):
	get_tree().change_scene_to_packed(change_scene)
