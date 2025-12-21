extends Node2D
@onready var PlanetImage: AnimatedSprite2D = $PlanetImage
var currentPlanet = 1
var finalPlanet = 2

func ready():
	pass

func _process(delta):
	PlanetImage.play("%d" % currentPlanet)
	KeyHandler.up.connect(next_planet)
	KeyHandler.down.connect(previous_planet)
	KeyHandler.enter.connect(select_planet)

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
	KeyHandler.up.disconnect(next_planet)
	KeyHandler.down.disconnect(previous_planet)
	KeyHandler.enter.disconnect(select_planet)
	if currentPlanet == 1:
		get_tree().change_scene_to_file("res://Scenes/Landings/DonetaLanding.tscn")
	if currentPlanet == 2:
		get_tree().change_scene_to_file("res://Scenes/Landings/ArtecaLanding.tscn")
