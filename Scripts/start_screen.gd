extends Node3D

@export var sub_viewport: SubViewport
@export var start_screen: Control
@export var credits_screen: Control

@export var thank_you: Label


var game_manager = GameManager
var open_options_menu:Panel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	thank_you.visible = false

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


func _on_quit_button_down() -> void:
	get_tree().quit()

func _on_option_back_button_down() -> void:
	open_options_menu.queue_free()
	display_screen(start_screen)
	
	
func _on_credits_back_button_down() -> void:
	display_screen(start_screen)
