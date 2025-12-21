extends Node2D


func _on_temp_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/SpaceShip/Space.tscn")
	pass # Replace with function body.


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Minigames/Doneta/DonetaGame.tscn")
	pass # Replace with function body.
