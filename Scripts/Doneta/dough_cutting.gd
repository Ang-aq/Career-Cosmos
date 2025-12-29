extends Control

signal donut_cutting_finished

@onready var dough: Sprite2D = $Dough
@onready var cut_container: Node2D = $CutContainer
@onready var cut_preview: Sprite2D = $CutPreview
@onready var instruction: Label = $UI/InstructionLabel
@onready var check_button: TextureButton = $UI/CheckButton
@onready var reset_button: TextureButton = $UI/ResetButton
@onready var error_flash: TextureRect = $UI/ErrorFlash

const REQUIRED_CUTS := 8
const CUT_RADIUS := 36.0
const OVERLAP_PADDING := 6.0

var cuts: Array[Vector2] = []
var active := false   # 🔑 IMPORTANT

# -------------------------
# READY
# -------------------------
func _ready():
	instruction.text = "Cut 8 donuts"
	cut_preview.visible = false
	error_flash.visible = false

	check_button.pressed.connect(_on_check_pressed)
	reset_button.pressed.connect(reset_cuts)

	set_process_unhandled_input(false)

# -------------------------
# ACTIVATE / RESET
# -------------------------
func reset_and_activate():
	reset_cuts()
	active = true
	set_process_unhandled_input(true)

func deactivate():
	active = false
	set_process_unhandled_input(false)

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
			try_place_cut(event.position)

# -------------------------
# PREVIEW
# -------------------------
func _update_preview(mouse_pos: Vector2):
	if not _mouse_over_dough(mouse_pos):
		cut_preview.visible = false
		return

	cut_preview.visible = true
	cut_preview.global_position = mouse_pos

# -------------------------
# PLACE CUT
# -------------------------
func try_place_cut(mouse_pos: Vector2):
	if not _mouse_over_dough(mouse_pos):
		return

	if cuts.size() >= REQUIRED_CUTS:
		return

	for existing_pos in cuts:
		if mouse_pos.distance_to(existing_pos) < CUT_RADIUS * 2 + OVERLAP_PADDING:
			_flash_error()
			return

	_place_cut(mouse_pos)

func _place_cut(pos: Vector2):
	var cut := Sprite2D.new()
	cut.texture = cut_preview.texture
	cut.global_position = pos
	cut_container.add_child(cut)
	cuts.append(pos)

# -------------------------
# CHECK / RESET
# -------------------------
func _on_check_pressed():
	if cuts.size() == REQUIRED_CUTS:
		deactivate()
		emit_signal("donut_cutting_finished")
		queue_free()
	else:
		reset_cuts()

func reset_cuts():
	for child in cut_container.get_children():
		child.queue_free()
	cuts.clear()

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
