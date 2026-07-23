extends Node3D

const play_area_bounds:=9
const item_cooldown:=8
@onready var space_checker: Area3D = $space_checker
@export var item_layer:Node3D

var can_spawn:= true
var item_limit:=10

@onready var template_item = preload("res://Prefabs/pickup_template.tscn")




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_spawn:
		find_new_spawn_loaction()
	else:
		#print("waiting to spawn item")
		pass


func find_new_spawn_loaction():
	#print("item spawner at: ", global_position, " overlapping bodies: ", space_checker.get_overlapping_bodies())
	if space_checker.get_overlapping_bodies().any(func body_checker(checker): return checker.is_in_group("environment")) or space_checker.get_overlapping_areas().any(func area_checker(checker): return checker.is_in_group("item")) or item_layer.get_child_count() >= item_limit:
		#print("finding new location!! bodies in checker: ", space_checker.get_overlapping_bodies().filter(func body_checker(checker): return !checker.is_in_group("environment")), " Items: ?", space_checker.get_overlapping_areas().filter(func area_checker(checker): return  !checker.is_in_group("item")))
		pass
	else:
		#Spawn item
		var next_item = template_item.instantiate()
		item_layer.add_child(next_item)
		next_item.global_position = global_position
		next_item.starting_position = global_position
		can_spawn = false
		get_tree().create_timer(item_cooldown).timeout.connect(func spawn_resetter():can_spawn = true)
		#print("spawning item")
	global_position = Vector3(randi_range(-play_area_bounds,play_area_bounds),randi_range(-play_area_bounds,play_area_bounds),0)
