extends Area3D

const hieght_boundry:float=.2
const move_speed:float=.006
var starting_position:Vector3

@export var pickup_mesh:MeshInstance3D

@export var item_type := GameManager.PickupItems.POTION

var go_up:= true


## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#starting_position = global_position


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
	if body.is_in_group("player"):
		print("player picked up item. ")
		body.pickup_item(item_type)
		queue_free()
