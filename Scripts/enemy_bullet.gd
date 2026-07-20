extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_colliding_bodies().size() > 0:
		for body in get_colliding_bodies():
				if !body.is_in_group("enemy"):
					if body.is_in_group("player") and !body.dashing and !body.grapple_cast.grappling:
						body.manage_health()
					queue_free()
	
	
	
