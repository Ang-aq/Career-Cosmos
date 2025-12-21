extends Node2D
@onready var handle: CollisionShape2D = $WhiskImage/Handle
@onready var whiskImage: Sprite2D = $WhiskImage
@onready var handNode: Node2D = $"../Hand"
var selected
var mouse_offset = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if selected:
		followMouse()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		global_position = get_global_mouse_position() 
	pass
		

func followMouse():
	global_position = get_global_mouse_position() + mouse_offset
	
	
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event == InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mouse_offset = get_global_mouse_position() - position
			selected = true
		else:
			selected = false

	pass # Replace with function body.

func _on_whisk_area_area_entered(area: Area2D) -> void:
	
	pass # Replace with function body.
