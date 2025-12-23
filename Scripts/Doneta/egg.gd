extends Node2D

signal used(ingredient_name)

@export var ingredient_name := "egg"
@export var quantity := 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var qty_label := $QuantityLabel

var selected := false
var mouse_offset := Vector2.ZERO
var locked := false
var home_position := Vector2.ZERO

func _ready() -> void:
	sprite.play(ingredient_name)
	update_label()
	home_position = position

func _process(delta: float) -> void:
	if selected and not locked:
		global_position = get_global_mouse_position() + mouse_offset

func _on_area_2d_input_event(viewport, event, shape_idx) -> void:
	if locked:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mouse_offset = global_position - get_global_mouse_position()
			selected = true
			z_index = 100
		else:
			selected = false
			z_index = 0
			snap_back()

func snap_back() -> void:
	var tween := create_tween()
	tween.tween_property(
		self,
		"position",
		home_position,
		0.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func consume() -> bool:
	if quantity <= 0:
		return false
	quantity -= 1
	update_label()
	return quantity > 0

func update_label() -> void:
	if qty_label:
		qty_label.text = str(quantity)
