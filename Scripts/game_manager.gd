extends Node



var game_on:bool

@onready var option_menu:=preload("res://Prefabs/option_window.tscn")

@onready var game_scene:=preload("res://Scenes/test_scene.tscn")
@onready var start_screen:=preload("res://Scenes/Start_Screen.tscn")

@onready var scene_transitioner :=preload("res://Prefabs/scene_transitioner.tscn")

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

var debug_mode:=false

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
	var root = get_parent()
	var next_scene_transitioner = scene_transitioner.instantiate()
	root.add_child(next_scene_transitioner)
	await next_scene_transitioner.transition().animation_finished
	
	
	root.get_child(1).queue_free()
	var next_scene = change_scene.instantiate()
	root.add_child(next_scene)
	await next_scene_transitioner.transition(false).animation_finished
	
	game_on = true
	next_scene_transitioner.queue_free()
	
	if change_scene == game_scene:
		next_scene.player_node.setup_player()
		
	
	if go_to_credits:
		next_scene.display_screen(next_scene.credits_screen)
		next_scene.thank_you.visible = true
