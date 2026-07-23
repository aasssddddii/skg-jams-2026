extends GPUParticles3D

var player_inside := false
const max_damage_timer:= 25
var damage_timer := max_damage_timer
var current_player
@onready var fire_damage_area: Area3D = $"../Area3D"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fire_damage_area.body_entered.connect(body_entered)
	fire_damage_area.body_exited.connect(body_exited)



func _physics_process(delta):
	if player_inside:
		damage_timer -= delta

		if damage_timer <= 0.0:
			if current_player:
				current_player.manage_health()
				damage_timer = max_damage_timer

func body_entered(body):
	if body.is_in_group("player") and emitting:
		player_inside = true
		current_player = body


func body_exited(body):
	if body.is_in_group("player"):
		player_inside = false
		current_player = null
