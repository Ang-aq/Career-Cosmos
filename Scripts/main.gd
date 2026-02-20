extends Node2D

@onready var bigstars: Sprite2D = $Big
@onready var medstars: Sprite2D = $Med
@onready var smallstars: Sprite2D = $Small
@onready var pressanybutton: Label = $Play

# Parallax speeds (adjust to taste)
var big_speed := 8.0
var med_speed := 16.0
var small_speed := 28.0

var screen_height := 0

func _ready():
	MusicManager.play_bgm("title", true)
	screen_height = get_viewport_rect().size.y
	start_glow_tween()

func _process(delta):
	move_stars(bigstars, big_speed, delta)
	move_stars(medstars, med_speed, delta)
	move_stars(smallstars, small_speed, delta)

func move_stars(stars: Sprite2D, speed: float, delta: float):
	stars.position.y += speed * delta

	# Loop when off screen
	if stars.position.y >= screen_height:
		stars.position.y = 0

func start_glow_tween():
	var tween = create_tween()
	tween.set_loops()

	tween.tween_property(
		pressanybutton,
		"modulate:a",
		0.3,
		1.2
	).set_trans(Tween.TRANS_SINE)

	tween.tween_property(
		pressanybutton,
		"modulate:a",
		1.0,
		1.2
	).set_trans(Tween.TRANS_SINE)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			MusicManager.play_sfx("start")
			get_tree().change_scene_to_file("res://Scenes/Spaceship/Backstory.tscn")
