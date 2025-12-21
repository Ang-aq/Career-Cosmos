extends Node2D

@onready var Milk: AnimatedSprite2D = $AnimatedSprite2D

var selected := false
var mouse_offset := Vector2.ZERO

func _ready() -> void:
	Milk.play("milk")

func _process(delta: float) -> void:
	if selected:
		follow_mouse()

func follow_mouse():
	global_position = get_global_mouse_position() + mouse_offset

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mouse_offset = global_position - get_global_mouse_position()
			selected = true
		else:
			selected = false
