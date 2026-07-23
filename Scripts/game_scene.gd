extends Node3D


@export var player_node:CharacterBody3D
@export var studder_preloader:Node3D


func _ready() -> void:
	await get_tree().process_frame
	studder_preloader.global_position = Vector3(100,100,0)
