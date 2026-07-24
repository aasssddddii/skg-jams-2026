extends Node3D

const play_area_bounds:=8.25
const item_cooldown:=8
@onready var space_checker: Area3D = $space_checker
@export var item_layer:Node3D

var can_spawn:= true
var item_limit:=10

@onready var template_item = preload("res://Prefabs/pickup_template.tscn")




func _process(delta: float) -> void:
	if can_spawn:
		find_new_spawn_loaction()
	else:
		#print("waiting to spawn item")
		pass


func find_new_spawn_loaction():
	#print("item spawner at: ", global_position, " overlapping bodies: ", space_checker.get_overlapping_bodies())
	await get_tree().physics_frame
	var overlapping_bodies = space_checker.get_overlapping_areas()
	print("item at: ", global_position," overlapping relevant areas: ", overlapping_bodies)
	if  overlapping_bodies.filter(func area_checker(checker): return checker.is_in_group("environment") or checker.is_in_group("item")).size() > 0 or item_layer.get_child_count() >= item_limit:
		print("finding new location!! bodies in checker: ", overlapping_bodies.filter(func area_checker(checker): return checker.is_in_group("environment")))
		global_position = Vector3(randi_range(-play_area_bounds,play_area_bounds),randi_range(-play_area_bounds,play_area_bounds),0)
	else:
		#Spawn item
		var next_item = template_item.instantiate()
		item_layer.add_child(next_item)
		next_item.global_position = global_position
		next_item.starting_position = global_position
		can_spawn = false
		get_tree().create_timer(item_cooldown).timeout.connect(func spawn_resetter():can_spawn = true)
		#print("spawning item")
	
