extends Area3D

const hieght_boundry:float=.2
const move_speed:float=.006
var starting_position:Vector3
var game_manager = GameManager

@export var pickup_mesh:MeshInstance3D

@export var item_type := GameManager.PickupItems.POTION

var go_up:= true


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match item_type:
		GameManager.PickupItems.POTION:
			var visual_item = game_manager.potion_pickup.instantiate()
			add_child(visual_item)
			visual_item.scale = Vector3(.06,.06,.06)
			visual_item.position = Vector3(0,-.127,0)
			pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print("global y: ", global_position.y, "- starting y: ", starting_position.y, " hieght boundry: ", hieght_boundry)
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
