extends CharacterBody3D

var speed = 4
var acceleration = 10

@onready var navigationAgent := $NavigationAgent3D
@onready var target := $"../Marker3D"

func _physics_process(delta):
	
	var direction = Vector3()
	
	navigationAgent.target_position = target.global_position
	
	direction = navigationAgent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity = velocity.lerp(direction * speed, acceleration * delta)
	
	if(navigationAgent.is_target_reached()):
		return
	
	move_and_slide()
