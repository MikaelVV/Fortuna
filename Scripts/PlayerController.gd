class_name player

extends CharacterBody3D

signal health_updated(health)
signal killed
signal taking_damage


var paused = false

@export var amount = 10

@export var max_health = 100
@export var SPEED = 10
@export var JUMP_VELOCITY = 6

# Määritellään pelaajan health, pivot ja camera variablet.
@onready var navigationAgent := $NavigationAgent3D
@onready var health = max_health : set = _set_health
@onready var HealthBar := $Pivot/Camera3D/HealthBar
@onready var pivot := $Pivot
@onready var camera := $Pivot/Camera3D
@onready var pause_menu := $Pivot/Camera3D/PauseMenu
@onready var body := $MeshInstance3D
# Haetaan painovoima projekti asetuksista.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	HealthBar.max_value = max_health
	_set_heatlhbar()

func _process(delta):
	if(navigationAgent.is_navigation_finished()):
		return
	
	pass


func _input(event):
	if Input.is_action_just_pressed("MoveToLocation"):
		var mousePosition = get_viewport().get_mouse_position()
		var rayLength = 150
		var fromPosition = camera.project_ray_origin(mousePosition)
		var toPosition = fromPosition + camera.project_ray_normal(mousePosition) * rayLength
		var space = get_world_3d().direct_space_state
		var rayQuery = PhysicsRayQueryParameters3D.new()
		
		rayQuery.from = fromPosition
		rayQuery.to = toPosition
		
		var result = space.intersect_ray(rayQuery)
		print(result)

# Function "kuuntelee" kaikkia inputteja, joka tässä tapauksessa on hiiri.
# ja määrittelee hiiren liikkuvuuden kameran kanssa.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion: # Alla määrittellään hiiren herkkyys.
			pivot.rotate_y(-event.relative.x * 0.01)
			camera.rotate_x(-event.relative.y * 0.01)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60)) # Tässä limitoidaan pelaajan kameran rotaatiota, että pelaaja ei voi katsoa 360 astetta ympäri.
	if event.is_action_pressed("pause"): # ui_cancel tarkoittaa Esc näppäintä.
		pauseGame()
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta) -> void:
	# Määritellään pelaajan painovoima.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		damage()



#Pelaaja ottaa vahinkoa kun osuu collideriin samas layeris kun vihollinen
func _on_area_3d_body_entered(body : Node3D):
	if body.is_in_group("enemy"):
		print ("Otin vahinkoa.")
	taking_damage.emit()
	_set_health(health - amount)
	_set_heatlhbar()
	


#Määritellään pelaajan ottama damagen määrä.
func damage() -> void:
	taking_damage.emit()
	_set_health(health - amount)
	_set_heatlhbar()

#Nimensä mukainen funktio. Tässä toteutetaan kaikki logiikka, jolla pelaaja tuhotaan.
func kill_player():
	#killed.emit()
	print("Kuolit!")
	#queue_free()
	body.visible = false


# Tässä funktiossa määrittellään pelaajan nykyinen ja edellinen health value. Myös toteutetaan kill_player funktio, jos pelaajan health value on 0.
func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health:
		emit_signal("health_updated", health)
		if health == 0:
			kill_player()

# Asettaa Healthbarin värin ja määrittää sille valuen.
func _set_heatlhbar() -> void:
	HealthBar.modulate = Color.DARK_RED
	HealthBar.value = health
	

func pauseGame():
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		pause_menu.hide()
		get_tree().paused = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		pause_menu.show()
