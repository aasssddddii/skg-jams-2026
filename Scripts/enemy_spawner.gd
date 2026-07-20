extends Node3D
const max_enemies = 20

var game_manager = GameManager
var can_spawn:=true
@onready var enemy = preload("res://Prefabs/enemy.tscn")
@onready var area_3d: Area3D = $Area3D

	
func _process(delta: float) -> void:
	if can_spawn and !area_3d.get_overlapping_bodies().any(func body_checker(checker): return checker.is_in_group("player")):
		if game_manager.spawned_enemies.size() < max_enemies:
			spawn_enemy()


func spawn_enemy():
	var next_enemy = enemy.instantiate()
	add_child(next_enemy)
	game_manager.spawned_enemies.append(next_enemy)
	can_spawn = false
	get_tree().create_timer(7).timeout.connect(func can_spawn_setter():can_spawn = true)
