extends Control

signal donut_cutting_finished

@onready var dough: Sprite2D = $Dough
@onready var cut_container: Node2D = $CutContainer
@onready var instruction: Label = $UI/InstructionLabel
@onready var check_button: TextureButton = $UI/CheckButton
@onready var reset_button: TextureButton = $UI/ResetButton
@onready var error_flash: TextureRect = $UI/ErrorFlash

# -------------------------
# PRELOADED SPRITE SCENES
# -------------------------
const CUTTER_SCENE := preload("res://Scenes/Minigames/Doneta/Cutter.tscn")
const STAMP_SCENE := preload("res://Scenes/Minigames/Doneta/DonutStamp.tscn")

# -------------------------
# CONFIG
# -------------------------
const CUTS_REQUIRED := 6
const CUT_RADIUS := 70.0
const OVERLAP_PADDING := 6.0

# -------------------------
# STATE
# -------------------------
var cuts: Array[Vector2] = []
var active := false
var cut_preview: Sprite2D

# -------------------------
# READY
# -------------------------
func _ready():
	instruction.text = "Cut 6 donuts"
	error_flash.visible = false

	# Create cutter preview instance
	cut_preview = CUTTER_SCENE.instantiate()
	add_child(cut_preview)
	cut_preview.visible = false
	cut_preview.z_index = 5

	check_button.pressed.connect(_on_check_pressed)
	reset_button.pressed.connect(reset_cuts)

	set_process_unhandled_input(false)

# -------------------------
# ACTIVATE / DEACTIVATE
# -------------------------
func reset_and_activate():
	reset_cuts()
	active = true
	set_process_unhandled_input(true)

func deactivate():
	active = false
	set_process_unhandled_input(false)
	cut_preview.visible = false

# -------------------------
# INPUT
# -------------------------
func _unhandled_input(event):
	if not active:
		return

	if event is InputEventMouseMotion:
		_update_preview(event.position)

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			cut_dough(event.position)

# -------------------------
# PREVIEW (CUTTER)
# -------------------------
func _update_preview(mouse_pos: Vector2):
	if not _mouse_over_dough(mouse_pos):
		cut_preview.visible = false
		return

	cut_preview.visible = true
	cut_preview.global_position = mouse_pos

# -------------------------
# PLACE CUT (STAMP)
# -------------------------
func cut_dough(mouse_pos: Vector2):
	# Stops if the mouse is not over the dough area
	if not _mouse_over_dough(mouse_pos):
		return
	
	# Stops if the required number of cuts has already been reached
	if cuts.size() >= CUTS_REQUIRED:
		return
	
	# Checks for overlap with existing cuts
	for existing_pos in cuts:
		# Prevents cuts from being placed too close together
		if mouse_pos.distance_to(existing_pos) < CUT_RADIUS * 2 + OVERLAP_PADDING:
			_flash_error()
			return
	
	# Places a valid cut at mouse position
	_place_cut(mouse_pos)

func _place_cut(pos: Vector2):
	var cut: Sprite2D = STAMP_SCENE.instantiate()
	cut.global_position = pos
	cut.z_index = 1

	cut_container.add_child(cut)
	cuts.append(pos)

# -------------------------
# CHECK / RESET
# -------------------------
func _on_check_pressed():
	MusicManager.play_sfx("click")
	if cuts.size() == CUTS_REQUIRED:
		deactivate()
		donut_cutting_finished.emit()
		queue_free()
	else:
		reset_cuts()

func reset_cuts():
	MusicManager.play_sfx("click")
	for child in cut_container.get_children():
		child.queue_free()

	cuts.clear()
	cut_preview.visible = false

# -------------------------
# HELPERS
# -------------------------
func _mouse_over_dough(mouse_pos: Vector2) -> bool:
	var rect := dough.get_rect()
	rect.position = dough.global_position - rect.size / 2
	return rect.has_point(mouse_pos)

func _flash_error():
	error_flash.visible = true
	error_flash.modulate.a = 1.0

	var tween := create_tween()
	tween.tween_property(error_flash, "modulate:a", 0.0, 0.25)
	tween.finished.connect(func():
		error_flash.visible = false
	)
