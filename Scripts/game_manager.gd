extends Node



var game_on:bool

@onready var option_menu:=preload("res://Prefabs/option_window.tscn")

@onready var game_scene:=preload("res://Scenes/test_scene.tscn")
@onready var start_screen:=preload("res://Scenes/Start_Screen.tscn")

@onready var up_sfx = "res://Audio/SFX/up_select.ogg"
@onready var down_sfx = "res://Audio/SFX/down_selesct.ogg"

var spawned_enemies:Array[CharacterBody3D]


enum PickupItems {
	POTION,
	SPEED
}


#music options
var sound_on:=true
var music_volume:float=.3
var sfx_volume:float=.3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_sound()




func setup_sound()->void:
	if sound_on:
		AudioServer.set_bus_volume_linear(1,music_volume)
		AudioServer.set_bus_volume_linear(2,sfx_volume)
	else:
		AudioServer.set_bus_mute(0,true)

func change_to_scene(change_scene:PackedScene,go_to_credits:bool = false):
	#get_tree().change_scene_to_packed(change_scene)
	#print("going to scene: ", change_scene)
	var root = get_parent()
	root.get_child(1).queue_free()
	var next_scene = change_scene.instantiate()
	root.add_child(next_scene)
	
	if go_to_credits:
		next_scene.display_screen(next_scene.credits_screen)
		next_scene.thank_you.visible = true
