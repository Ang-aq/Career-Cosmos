extends Node2D
@onready var PlanetImage: AnimatedSprite2D = $PlanetImage
var currentPlanet = 1
var finalPlanet = 2

func ready():
	pass

func _process(delta):
	PlanetImage.play("%d" % currentPlanet)
	
	
func next_planet():
	if currentPlanet != finalPlanet:
		currentPlanet = currentPlanet + 1
		print("current planet %d" % currentPlanet)
	PlanetImage.play("%d" % currentPlanet)
	
func previous_planet():
	if currentPlanet != 1:
	
		currentPlanet = currentPlanet - 1
		print("current planet %d" % currentPlanet)
	PlanetImage.play("%d" % currentPlanet)

func select_planet():
	if currentPlanet == 1:
		get_tree().change_scene_to_file("res://Scenes/Landings/DonetaLanding.tscn")
	if currentPlanet == 2:
		get_tree().change_scene_to_file("res://Scenes/Landings/ArtecaLanding.tscn")


func _on_lever_pressed() -> void:
	select_planet()
	pass # Replace with function body.


func _on_blue_button_pressed() -> void:
	previous_planet()
	pass # Replace with function body.


func _on_red_button_pressed() -> void:
	next_planet()
	pass # Replace with function body.
