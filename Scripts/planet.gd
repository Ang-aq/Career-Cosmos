extends Node2D

@onready var PlanetImage: AnimatedSprite2D = $PlanetImage
@onready var PlanetInfo: TextEdit = $"Planet Info"

var currentPlanet: int = 1
var finalPlanet: int = 2

# -------------------------
# Planet info data
# -------------------------
var planet_infos := {
	1: "NAME: Doneta\n-----------------\nPROFESSION: Chef\n\nINFO: Donetians love\ndesserts and candy!\n\nDIFFICULTY: Easy",
	2: "NAME: Arteca\n-----------------\nPROFESSION: Architect\n\nINFO: A planet packed\nwith skyscrapers!\n\nDIFFICULTY: Medium"
}

# Typewriter effect variables
var typing_speed: float = 0.05 # seconds per character
var typing_task: Timer = null
var blinking_task: Timer = null

# -------------------------
# READY
# -------------------------
func _ready():
	PlanetImage.play("%d" % currentPlanet)
	PlanetImage.modulate.a = 1.0  # fully visible
	_show_planet_info(currentPlanet)

# -------------------------
# Planet Buttons
# -------------------------
func _on_blue_button_pressed() -> void:
	if currentPlanet <= 1:
		return

	var previous := currentPlanet
	currentPlanet -= 1
	print("current planet %d" % currentPlanet)
	_play_planet_transition(previous, currentPlanet)

func _on_red_button_pressed() -> void:
	if currentPlanet >= finalPlanet:
		return

	var previous := currentPlanet
	currentPlanet += 1
	print("current planet %d" % currentPlanet)
	_play_planet_transition(previous, currentPlanet)

# -------------------------
# Planet Fade Transition
# -------------------------
func _play_planet_transition(oldPlanet: int, newPlanet: int) -> void:
	# Create a temporary sprite for the old planet
	var old_sprite := PlanetImage.duplicate() as AnimatedSprite2D
	add_child(old_sprite)
	old_sprite.play("%d" % oldPlanet)
	old_sprite.position = PlanetImage.position
	old_sprite.z_index = PlanetImage.z_index + 1
	old_sprite.modulate.a = 1.0

	# Set new planet behind old one
	PlanetImage.play("%d" % newPlanet)
	PlanetImage.modulate.a = 0.0
	PlanetImage.z_index = 0

	# Tween fade out old planet and fade in new planet
	var tween := create_tween()
	tween.tween_property(old_sprite, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): old_sprite.queue_free())
	tween.tween_property(PlanetImage, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Update planet info with typewriter effect
	_show_planet_info(newPlanet)

# -------------------------
# Typewriter Effect for Planet Info
# -------------------------
func _show_planet_info(planet_id: int) -> void:
	# Stop any previous typing/blinking tasks
	if typing_task != null and typing_task.is_inside_tree():
		typing_task.stop()
		typing_task.queue_free()
		typing_task = null
	if blinking_task != null and blinking_task.is_inside_tree():
		blinking_task.stop()
		blinking_task.queue_free()
		blinking_task = null

	# Clear text immediately
	PlanetInfo.text = ""

	# Start typing effect
	_start_typing_effect(planet_infos[planet_id])

# -------------------------
# Typing effect using Timer and await
# -------------------------
func _start_typing_effect(full_text: String) -> void:
	typing_task = Timer.new()
	typing_task.wait_time = typing_speed
	typing_task.one_shot = true
	add_child(typing_task)

	for i in full_text.length():
		PlanetInfo.text = full_text.substr(0, i + 1) + "_"
		typing_task.start()
		await typing_task.timeout

	# After typing finished, start blinking cursor
	_start_blinking_cursor(full_text)
	typing_task.queue_free()
	typing_task = null

# -------------------------
# Blinking cursor
# -------------------------
func _start_blinking_cursor(full_text: String) -> void:
	var show_underscore := true
	blinking_task = Timer.new()
	blinking_task.wait_time = 0.5
	blinking_task.one_shot = false
	add_child(blinking_task)
	blinking_task.start()

	blinking_task.timeout.connect(func():
		if show_underscore:
			PlanetInfo.text = full_text + "_"
		else:
			PlanetInfo.text = full_text
		show_underscore = !show_underscore
	)
