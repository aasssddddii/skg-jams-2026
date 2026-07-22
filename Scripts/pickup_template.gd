extends Area3D

const hieght_boundry:float=.2
const move_speed:float=.006
const rotation_speed:float=1
var starting_position:Vector3
var game_manager = GameManager

@export var pickup_mesh:MeshInstance3D

@onready var item_type :GameManager.PickupItems=GameManager.PickupItems.SPEED# [GameManager.PickupItems.POTION,GameManager.PickupItems.SPEED].pick_random()

var go_up:= true


func _ready() -> void:
	match item_type:
		GameManager.PickupItems.POTION:
			var visual_item = game_manager.potion_pickup.instantiate()
			add_child(visual_item)
			visual_item.scale = Vector3(.06,.06,.06)
			visual_item.position = Vector3(.051,-.11,0)
			visual_item.rotation_degrees = Vector3(0,0,30)
		GameManager.PickupItems.SPEED:
			var visual_item = game_manager.speed_pickup.instantiate()
			add_child(visual_item)

func _process(delta: float) -> void:
	#print("global y: ", global_position.y, "- starting y: ", starting_position.y, " hieght boundry: ", hieght_boundry)
	rotation_degrees.y += rotation_speed
	animate_pickup(go_up)
	flip_checker()
	
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
	print("Sanity check body: ", body)
	if body.is_in_group("player"):
		print("player picked up item. ")
		body.pickup_item(item_type)
		queue_free()
