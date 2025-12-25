extends Control

signal progress_requested(amount: float)
signal kneading_completed

@onready var bar: ColorRect = $BarContainer/BackgroundBar
@onready var slider: ColorRect = $BarContainer/Slider
@onready var green: ColorRect = $BarContainer/GreenZone
@onready var label: Label = $InstructionLabel
@onready var dough: AnimatedSprite2D = $Dough

# Configuration
const TOTAL_SUCCESSES := 5
const PROGRESS_PER_SUCCESS := 6
const BASE_SPEED := 300.0
const SPEED_INCREASE := 120.0
const BASE_GREEN_WIDTH := 160.0
const GREEN_SHRINK := 22.0
const MIN_GREEN_WIDTH := 40.0

# State
var success_count := 0
var active := true
var direction := 1
var speed := BASE_SPEED

func _ready():
	label.text = "Stop the bar in the green zone!"
	reset_round()

func _process(delta):
	if not active:
		return

	# Move the slider
	slider.position.x += direction * speed * delta

	var left_limit = bar.position.x
	var right_limit = bar.position.x + bar.size.x - slider.size.x

	if slider.position.x <= left_limit:
		slider.position.x = left_limit
		direction = 1
	elif slider.position.x >= right_limit:
		slider.position.x = right_limit
		direction = -1

func _input(event):
	if active and event.is_action_pressed("ui_accept"):
		check_hit()

func check_hit():
	var center = slider.position.x + slider.size.x / 2
	if center >= green.position.x and center <= green.position.x + green.size.x:
		on_success()
	else:
		on_fail()

func on_success():
	success_count += 1
	emit_signal("progress_requested", PROGRESS_PER_SUCCESS)

	dough.play("knead")
	await dough.animation_finished
	dough.play("dough")

	if success_count >= TOTAL_SUCCESSES:
		emit_signal("kneading_completed")
		queue_free()
		return

	# Increase speed and shrink green zone
	speed += SPEED_INCREASE
	green.size.x = max(MIN_GREEN_WIDTH, BASE_GREEN_WIDTH - GREEN_SHRINK * success_count)
	reset_round()

func on_fail():
	label.text = "Missed! Try again."
	active = false

	await get_tree().create_timer(0.5).timeout

	# Reset
	success_count = 0
	speed = BASE_SPEED
	green.size.x = BASE_GREEN_WIDTH
	active = true
	reset_round()

func reset_round():
	slider.position.x = bar.position.x
	direction = 1
	randomize_green()

func randomize_green():
	var min_x = bar.position.x
	var max_x = bar.position.x + bar.size.x - green.size.x
	green.position.x = randf_range(min_x, max_x)
