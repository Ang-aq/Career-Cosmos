extends Node

signal up
signal down
signal left
signal right
signal enter
signal cancel

func _unhandled_input(event):
	if event.is_action_pressed("up"):
		emit_signal("up")
	elif event.is_action_pressed("down"):
		emit_signal("down")
	elif event.is_action_pressed("left"):
		emit_signal("left")
	elif event.is_action_pressed("right"):
		emit_signal("right")
	elif event.is_action_pressed("enter"):
		emit_signal("enter")
#	elif event.is_action_pressed("cancel"):
#		emit_signal("cancel")
