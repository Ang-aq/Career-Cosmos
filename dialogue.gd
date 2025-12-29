extends Node2D

signal dialogue_finished

@onready var text_box: AnimatedSprite2D = $TextBox
@onready var text_label: Label = $Text
@onready var name_tag: Label = $Name

var dialogue_queue: Array = []
var current_index: int = 0
var active: bool = false
var typing: bool = false

const TYPE_SPEED := 0.035   # seconds per character

func _ready() -> void:
	# ensure the box is hidden at start
	text_box.hide()
	text_label.text = ""
	name_tag.text = ""

func _input(event: InputEvent) -> void:
	if not active:
		return

	if event.is_action_pressed("ui_accept"):
		if typing:
			finish_typing()
		else:
			advance_dialogue()

# Show an array of dialogue entries:
# [{ "name":"Chef", "text":"Short line." }, ...]
func show_dialogue(dialogues: Array) -> void:
	if dialogues.is_empty():
		# Nothing to show -> immediately emit finished
		emit_signal("dialogue_finished")
		return

	# Replace the queue with new dialogues (you could append instead if desired)
	dialogue_queue = dialogues.duplicate()
	current_index = 0
	active = true

	# Show box (play appear animation if present) then start first line
	text_box.show()
	text_box.play("appear")
	await text_box.animation_finished
	# if no animation, just show immediately
	_show_current_dialogue()

func _show_current_dialogue() -> void:
	if current_index >= dialogue_queue.size():
		end_dialogue()
		return

	var entry = dialogue_queue[current_index]
	name_tag.text = str(entry.get("name", ""))
	start_typing(str(entry.get("text", "")))

func start_typing(full_text: String) -> void:
	typing = true
	text_label.text = ""

	for i in full_text.length():
		if not typing:
			break
		text_label.text += full_text[i]
		await get_tree().create_timer(TYPE_SPEED).timeout

	typing = false

func finish_typing() -> void:
	typing = false
	if current_index < dialogue_queue.size():
		text_label.text = str(dialogue_queue[current_index].get("text", ""))

func advance_dialogue() -> void:
	current_index += 1
	if current_index >= dialogue_queue.size():
		end_dialogue()
	else:
		_show_current_dialogue()

func end_dialogue() -> void:
	# mark inactive and play disappear (if exists), then emit finished
	active = false
	typing = false

	if text_box.has_animation("disappear"):
		text_box.play("disappear")
		await text_box.animation_finished

	text_box.hide()
	text_label.text = ""
	name_tag.text = ""
	dialogue_queue.clear()

	emit_signal("dialogue_finished")
