extends Control

signal progress_requested(amount: float)
signal kneading_completed

@onready var bar_container: Control = $BarContainer
@onready var bar: Sprite2D = $BarContainer/BackgroundBar
@onready var slider: Sprite2D = $BarContainer/Slider
@onready var green: ColorRect = $BarContainer/GreenZone
@onready var stop_button: TextureButton = $StopButton
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
var direction := 1
var speed := BASE_SPEED
var active := true
var bar_moving := true
var local_progress := 0

# Lane bounds
var lane_left := 0.0
var lane_right := 0.0

func _ready():
	label.text = "Click STOP in the green zone!"
	stop_button.pressed.connect(_on_stop_pressed)

	_calculate_lane()
	_set_green_width(BASE_GREEN_WIDTH)
	reset_round()

func _calculate_lane():
	var bar_width = bar.texture.get_size().x * bar.scale.x

	# Because BackgroundBar is CENTERED
	lane_left = bar.position.x - bar_width / 2
	lane_right = bar.position.x + bar_width / 2

func _process(delta):
	if not active or not bar_moving:
		return

	slider.position.x += direction * speed * delta

	var slider_width = slider.texture.get_size().x * slider.scale.x
	var max_x = lane_right - slider_width

	if slider.position.x <= lane_left:
		slider.position.x = lane_left
		direction = 1
	elif slider.position.x >= max_x:
		slider.position.x = max_x
		direction = -1

func _on_stop_pressed():
	if not active or not bar_moving:
		return
	MusicManager.play_sfx("click")
	bar_moving = false
	check_hit()

func check_hit():
	var slider_width = slider.texture.get_size().x * slider.scale.x
	var slider_center = slider.position.x + slider_width / 2

	var green_start = green.position.x
	var green_end = green.position.x + green.size.x

	if slider_center >= green_start and slider_center <= green_end:
		on_success()
	else:
		on_fail()

func on_success():
	success_count += 1
	local_progress += PROGRESS_PER_SUCCESS
	emit_signal("progress_requested", PROGRESS_PER_SUCCESS)

	dough.play("knead")
	await dough.animation_finished
	dough.play("dough")

	if success_count >= TOTAL_SUCCESSES:
		emit_signal("kneading_completed")
		queue_free()
		return

	speed += SPEED_INCREASE
	_shrink_green()
	reset_round()

func on_fail():
	label.text = "Missed! Try again."
	active = false

	if local_progress > 0:
		emit_signal("progress_requested", -local_progress)
		local_progress = 0

	await get_tree().create_timer(0.6).timeout

	success_count = 0
	speed = BASE_SPEED
	_set_green_width(BASE_GREEN_WIDTH)
	active = true
	reset_round()

func reset_round():
	bar_moving = true
	slider.position.x = lane_left
	direction = 1
	randomize_green()

func randomize_green():
	var max_x = lane_right - green.size.x
	green.position.x = randf_range(lane_left, max_x)

func _shrink_green():
	var new_width = max(
		MIN_GREEN_WIDTH,
		BASE_GREEN_WIDTH - GREEN_SHRINK * success_count
	)
	_set_green_width(new_width)

func _set_green_width(width: float):
	green.size.x = width
	
func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_K:
			active = false
			bar_moving = false

			emit_signal("kneading_completed")
			queue_free()
			
