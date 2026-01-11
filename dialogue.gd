extends Node2D

signal dialogue_finished

@onready var text_box: Sprite2D = $TextBox
@onready var text_label: Label = $Text
@onready var name_tag: Label = $Name
@onready var Dialogue: Node2D = $"."

var dialogue_queue: Array = []
var current_index: int = 0
var active: bool = false
var typing: bool = false

const TYPE_SPEED := 0.035   # seconds per character

# -------------------------
# READY
# -------------------------
func _ready() -> void:
	text_label.text = ""
	name_tag.text = ""
	Dialogue.hide()

# -------------------------
# TAP / CLICK INPUT
# -------------------------
func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return

	if event is InputEventMouseButton and event.pressed:
		if typing:
			finish_typing()
		else:
			advance_dialogue()

# -------------------------
# PUBLIC ENTRY POINT
# dialogues = [{ "name":"Chef", "text":"Hello." }, ...]
# -------------------------
func show_dialogue(dialogues: Array) -> void:
	if dialogues.is_empty():
		dialogue_finished.emit()
		return

	dialogue_queue = dialogues.duplicate()
	current_index = 0
	active = true

	Dialogue.show()
	_show_current_dialogue()

# -------------------------
# DIALOGUE FLOW
# -------------------------
func _show_current_dialogue() -> void:
	if current_index >= dialogue_queue.size():
		end_dialogue()
		return

	var entry = dialogue_queue[current_index]
	name_tag.text = str(entry.get("name", ""))
	start_typing(str(entry.get("text", "")))

func start_typing(full_text: String) -> void:
	typing = true
	text_label.text = full_text
	text_label.visible_ratio = 0.0

	var tween := create_tween()
	tween.tween_property(
		text_label,
		"visible_ratio",
		1.0,
		full_text.length() * TYPE_SPEED
	)

	await tween.finished
	typing = false

func finish_typing() -> void:
	typing = false
	text_label.visible_ratio = 1.0

func advance_dialogue() -> void:
	current_index += 1
	if current_index >= dialogue_queue.size():
		end_dialogue()
	else:
		_show_current_dialogue()

func end_dialogue() -> void:
	active = false
	typing = false

	Dialogue.hide()
	text_label.text = ""
	name_tag.text = ""
	dialogue_queue.clear()

	dialogue_finished.emit()
