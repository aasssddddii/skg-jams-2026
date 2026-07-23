extends Area3D

func _ready() -> void:
	body_entered.connect(body_killer)


func body_killer(body):
	if body.is_in_group("player"):
		body.manage_health(0,"set")
		body.game_over()
		#print("Player getting killed.")
	else:
		body.queue_free()
