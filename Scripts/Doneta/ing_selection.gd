extends Node2D

@onready var container := $SlotContainer
@onready var left_btn := $LeftButton
@onready var right_btn := $RightButton

const SLOT_SPACING := 120
const VISIBLE_SLOTS := 5
const SLIDE_TIME := 0.25

var ingredients: Array[Node2D] = []
var start_index := 0
var tween: Tween

func _ready() -> void:
	ingredients.clear()
	for child in container.get_children():
		if child is Node2D:
			ingredients.append(child)
	
	layout(true)
	
	left_btn.pressed.connect(scroll_left)
	right_btn.pressed.connect(scroll_right)
	
	for ing in ingredients:
		ing.used.connect(_on_ingredient_used)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		scroll_right()
	elif event.is_action_pressed("ui_left"):
		scroll_left()

func layout(instant := false) -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel()
	
	for i in range(ingredients.size()):
		var ing := ingredients[i]
		if i < start_index or i >= start_index + VISIBLE_SLOTS:
			ing.hide()
		else:
			ing.show()
			var target_pos := Vector2(
				(i - start_index) * SLOT_SPACING,
				0
			)
			
			ing.home_position = target_pos
			
			if instant:
				ing.position = target_pos
			else:
				tween.tween_property(
					ing,
					"position",
					target_pos,
					SLIDE_TIME
				).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func scroll_right() -> void:
	if start_index + VISIBLE_SLOTS < ingredients.size():
		start_index += 1
		layout()

func scroll_left() -> void:
	if start_index > 0:
		start_index -= 1
		layout()

func _on_ingredient_used(ingredient_name: String) -> void:
	for ing in ingredients:
		if ing.ingredient_name == ingredient_name:
			ingredients.erase(ing)
			ing.queue_free()
			start_index = clamp(
				start_index,
				0,
				max(0, ingredients.size() - VISIBLE_SLOTS)
			)
			layout()
			break
