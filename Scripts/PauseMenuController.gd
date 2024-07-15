extends Node

@onready var pause_menu :=$"."




func _on_resume_game_pressed() -> void:
	get_tree().paused = false
	pause_menu.hide()


func _on_return_to_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
