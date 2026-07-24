extends Area3D

const hieght_boundry:float=.2
const move_speed:float=.006
const rotation_speed:float=1
var starting_position:Vector3
var game_manager = GameManager
@onready var space_checker: Area3D = $space_checker

#@export var pickup_mesh:MeshInstance3D

@onready var item_type :GameManager.PickupItems= [GameManager.PickupItems.POTION,GameManager.PickupItems.SPEED,GameManager.PickupItems.DOUBLE,GameManager.PickupItems.INVINCIBLE,GameManager.PickupItems.URF].pick_random()

var go_up:= true


func _ready() -> void:
	var visual_item
	match item_type:
		GameManager.PickupItems.POTION:
			visual_item = game_manager.potion_pickup.instantiate()
			visual_item.scale = Vector3(.06,.06,.06)
			visual_item.position = Vector3(.051,-.11,0)
			visual_item.rotation_degrees = Vector3(0,0,30)
		GameManager.PickupItems.SPEED:
			visual_item = game_manager.speed_pickup.instantiate()
			visual_item.scale = Vector3(.06,.06,.06)
			visual_item.position = Vector3(.051,-.11,0)
			visual_item.rotation_degrees = Vector3(0,0,30)
		GameManager.PickupItems.DOUBLE:
			visual_item = game_manager.double_pickup.instantiate()
			visual_item.rotation_degrees = Vector3(0,0,30)
		GameManager.PickupItems.INVINCIBLE:
			visual_item = game_manager.invincibility_pickup.instantiate()
			visual_item.rotation_degrees = Vector3(0,0,50)
		GameManager.PickupItems.URF:
			visual_item = game_manager.urf_pickup.instantiate()
			visual_item.rotation_degrees = Vector3(0,0,30)
			
	add_child(visual_item)

func _process(delta: float) -> void:
	#print("global y: ", global_position.y, "- starting y: ", starting_position.y, " hieght boundry: ", hieght_boundry)
	rotation_degrees.y += rotation_speed
	animate_pickup(go_up)
	flip_checker()
	if !home_found:
		find_new_spawn_loaction()
	
func animate_pickup(going_up:bool=true)->void:
	if going_up:
		global_position.y += move_speed
	else:
		global_position.y -= move_speed
	
	
func flip_checker()->void:
	if global_position.y > starting_position.y + hieght_boundry :
		go_up = false
	elif global_position.y < starting_position.y - hieght_boundry:
		go_up = true


func _on_body_entered(body: Node3D) -> void:
	#print("Sanity check body: ", body)
	if body.is_in_group("player"):
		#print("player picked up item. ")
		body.pickup_item(item_type)
		queue_free()
		
		
#func _process(delta: float) -> void:
	#if can_spawn:
		#find_new_spawn_loaction()
	#else:
		##print("waiting to spawn item")
		#pass

var home_found:=false
func find_new_spawn_loaction():
	#print("item at: ", global_position," overlapping relevant areas: ", space_checker.get_overlapping_areas().filter(func area_checker(checker): return checker.is_in_group("environment")))
	#(checker.is_in_group("item") and checker.get_parent().name == name) and !checker.is_in_group("environment")
	await get_tree().physics_frame
	if space_checker.get_overlapping_areas().filter(func area_checker(checker): return checker.is_in_group("environment") or (checker.is_in_group("item") and checker.get_parent().name == name)).size() > 0 :
		print("item: " ,var_to_str(item_type), " Changing Position!!")
		global_position = Vector3(randi_range(-6,6),randi_range(-6,6),0)
		starting_position = global_position
	else:
		#Spawn item
		home_found = true
		#print("item: " ,var_to_str(item_type), " found new home!!")
