extends Node2D

@onready var Moons: AnimatedSprite2D = $MoonsEarned
@onready var Level: AnimatedSprite2D = $Level
@onready var AgainButton: TextureButton = $PlayAgain
@onready var ReturnButton: TextureButton = $Return

func _ready():
	hide()
	

func level_complete(Level: String, MoonsEarned: int):
	show()
	Moons.play("%d"+"Moon" % MoonsEarned)
	


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Minigames/Doneta/DonetaGame.tscn")
	pass # Replace with function body.


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/SpaceShip/Space.tscn")
	pass # Replace with function body.
