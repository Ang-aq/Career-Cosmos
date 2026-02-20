extends Node2D

signal comic_finished

@export var fade_duration := 0.6

var panels: Array[Sprite2D] = []
var current_index := 0
var transitioning := false

func _ready():
	MusicManager.play_sfx("scene1")
	# Collect all Sprite2D children as panels
	for child in get_children():
		if child is Sprite2D:
			panels.append(child)

	# Safety check
	if panels.is_empty():
		push_error("No comic panels found!")
		return

	# Ensure correct starting visibility
	for i in panels.size():
		panels[i].modulate.a = 1.0 if i == 0 else 0.0

	current_index = 0

func _unhandled_input(event):
	if transitioning:
		return

	if event is InputEventMouseButton and event.pressed:
		_show_next_panel()

func _show_next_panel():
	if current_index >= panels.size() - 1:
		get_tree().change_scene_to_file("res://Scenes/Spaceship/Space.tscn")
		return

	transitioning = true
	current_index += 1
	if current_index == 1:
		MusicManager.play_sfx("scene2")
	if current_index == 2:
		MusicManager.play_sfx("scene3")
	
	var panel := panels[current_index]
	panel.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, fade_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.finished.connect(func():
		transitioning = false
	)
