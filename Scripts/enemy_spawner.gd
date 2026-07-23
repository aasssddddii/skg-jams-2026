extends Node3D

const play_area_bounds:=9
var game_manager = GameManager
var can_spawn:=true
@onready var enemy = preload("res://Prefabs/enemy.tscn")
@onready var area_3d: Area3D = $Area3D
@export var space_checker:Area3D
const template_enemy = preload("uid://ysxy5gdv8xp6")
@onready var enemy_layer: Node3D = $"../enemy_layer"
var enemy_cooldown:=3
	
#func _process(delta: float) -> void:
	#if can_spawn and !area_3d.get_overlapping_bodies().any(func body_checker(checker): return checker.is_in_group("player")):
		#if game_manager.spawned_enemies.size() < game_manager.max_enemies:
			#print("current enemies: ",game_manager.spawned_enemies," size : ", game_manager.spawned_enemies.size() , " max enemies on field = ", game_manager.max_enemies )
			#spawn_enemy()
		#else:
			##print("too many enemies!")
			#pass

func spawn_enemy():
	var next_enemy = enemy.instantiate()
	add_child(next_enemy)
	game_manager.spawned_enemies.append(next_enemy)
	print("spawning enemy at : ", global_position)
	can_spawn = false
	get_tree().create_timer(7).timeout.connect(func can_spawn_setter():can_spawn = true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_spawn:
		find_new_spawn_loaction()
	else:
		#print("waiting to spawn item")
		pass


func find_new_spawn_loaction():
	#print("item spawner at: ", global_position, " overlapping bodies: ", space_checker.get_overlapping_bodies())
	if space_checker.get_overlapping_bodies().any(func body_checker(checker): return checker.is_in_group("player")) or enemy_layer.get_child_count() > game_manager.max_enemies:
		#print("finding new location!! bodies in checker: ", space_checker.get_overlapping_bodies().filter(func body_checker(checker): return !checker.is_in_group("environment")), " Items: ?", space_checker.get_overlapping_areas().filter(func area_checker(checker): return  !checker.is_in_group("item")))
		pass
	else:
		#Spawn item
		var next_enemy = template_enemy.instantiate()
		enemy_layer.add_child(next_enemy)
		next_enemy.global_position = global_position
		can_spawn = false
		get_tree().create_timer(enemy_cooldown).timeout.connect(func spawn_resetter():can_spawn = true)
		#print("spawning item")
	global_position = Vector3(randi_range(-play_area_bounds,play_area_bounds),randi_range(-play_area_bounds,play_area_bounds),0)
