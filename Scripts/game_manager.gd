extends Node



var game_on:bool
var navigation_box_limit:=9
@onready var option_menu:=preload("res://Prefabs/option_window.tscn")

@onready var game_scene:=preload("res://Scenes/test_scene.tscn")
@onready var start_screen:=preload("res://Scenes/Start_Screen.tscn")

@onready var scene_transitioner :=preload("res://Prefabs/scene_transitioner.tscn")

@onready var up_sfx = "res://Audio/SFX/up_select.ogg"
@onready var down_sfx = "res://Audio/SFX/down_selesct.ogg"
const start_game_sfx = preload("uid://barrtg03rkcu4")
const BUTTON_CLICK = preload("uid://b8o6f6q7ltm8n")

@onready var highscore_path:String =  OS.get_executable_path().get_base_dir() + "/Saves/highscores.tres"
@onready var highscore_lib = load("res://Resources/Highscore_Library.tres").duplicate(true)



var spawned_enemies:Array[CharacterBody3D]


enum PickupItems {
	POTION,
	SPEED,
	DOUBLE,
	URF,
	INVINCIBLE
}
@onready var potion_pickup:=preload("res://Prefabs/potion_bottle_WithWiggles.tscn")
@onready var speed_pickup:=preload("res://Prefabs/speed_pickup_prefab.tscn")
@onready var double_pickup:=preload("res://Prefabs/double_points_pickup.tscn")
const invincibility_pickup = preload("uid://b64qd4r2gc857")
const urf_pickup = preload("uid://d2s4iq41uhvvy")


#music options
var sound_on:=true
var music_volume:float=.3
var sfx_volume:float=.3

var debug_mode:=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_sound()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
		#print("using loaded Highscores: ", highscore_lib.highscores)




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
	
	if go_to_credits:
		next_scene.display_screen(next_scene.credits_screen)
		next_scene.thank_you.visible = true
	await next_scene_transitioner.transition(false).animation_finished
	
	next_scene_transitioner.queue_free()
	
	if change_scene == game_scene:
		game_on = true
		next_scene.player_node.setup_player()
		
	get_tree().paused = false


func sort_descending(a, b):
	if a.values()[0] > b.values()[0]:
		return true
	return false

func save_highscore(highscore_data:Dictionary):
	highscore_lib.highscores.append(highscore_data)
	
	highscore_lib.highscores.sort_custom(sort_descending)
	print("higsores path: ",highscore_path)
	
	
	
	var result = ResourceSaver.save(highscore_lib,highscore_path)
	if result == OK:
		print("Highscore saved!")
	else:
		print("Failed to save resource: ", result)
	
	
func load_highscore():
	#if OS.has_feature("standalone"):
	#highscore_path =  "user://Saves/highscores.tres"  
	#else:
	#	highscore_path =  "res://Saves/highscores.tres"
	print("sanity check highscore path: ", highscore_path)
	if FileAccess.file_exists(highscore_path):
		highscore_lib =  ResourceLoader.load(highscore_path)
	
func remove_highscore():
	if FileAccess.file_exists(highscore_path):
		var error := DirAccess.remove_absolute(highscore_path)
		print("higsores path: ",highscore_path)
		if error == OK:
			print("Save deleted successfully")
			highscore_lib = ResourceLoader.load("res://Resources/Highscore_Library.tres")
		else:
			push_error("Failed to delete save: " + str(error))
	else:
		print("Save file does not exist")
	
