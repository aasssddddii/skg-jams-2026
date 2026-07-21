extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func transition(fade_out:bool = true)->AnimationPlayer:
	if fade_out:
		animation_player.play("fade_out")
	else:
		animation_player.play("fade_in")
	return animation_player
