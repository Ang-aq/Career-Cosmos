extends Node2D

signal whisking_completed
signal progress_requested(amount: float)

@onready var bowl: AnimatedSprite2D = $BowlImage
@onready var bowl_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var whisk: Node2D = $"../Whisk"

var poured := {"sugar": false, "milk": false, "egg": false}
var ingredients_poured := 0
var whisking_time := false
var whisk_done := false
var whisk_held := false  # Track if player is holding the whisk

var last_angle := 0.0
var whisk_quality := 0.0
var local_progress := 0.0

const INGREDIENT_PROGRESS := 5
const BASE_PROGRESS := 0
const WHISK_MAX_PROGRESS := 25

const ROTATION_THRESHOLD := 0.03
const WHISK_GAIN_SPEED := 16.0
const WHISK_DECAY_SPEED := 3.0

func _ready():
	whisk.hide()
	bowl.play("bowl")

func _process(delta):
	if whisking_time and not whisk_done:
		var old_progress = local_progress
		if whisk_held:
			update_whisk_quality()
			update_progress(delta)
		else:
			# decay but never below BASE_PROGRESS
			local_progress = max(local_progress - WHISK_DECAY_SPEED * delta, BASE_PROGRESS)
		
		# emit the actual change in progress to the main minigame
		var delta_progress = local_progress - old_progress
		if delta_progress != 0:
			emit_signal("progress_requested", delta_progress)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			whisk_held = event.pressed

func update_whisk_quality():
	var mouse_pos = get_viewport().get_mouse_position()
	var center = bowl.global_position
	var vec = mouse_pos - center

	var shape := bowl_shape.shape
	if shape is not CircleShape2D:
		return

	var radius = vec.length()
	var max_radius = shape.radius

	if radius > max_radius:
		whisk_quality = move_toward(whisk_quality, 0.0, 0.05)
		return

	var angle = vec.angle()
	if last_angle == 0.0:
		last_angle = angle
		return

	var delta_angle = wrapf(angle - last_angle, -PI, PI)
	last_angle = angle

	if abs(delta_angle) < ROTATION_THRESHOLD:
		whisk_quality = move_toward(whisk_quality, 0.0, 0.03)
		return

	var radius_score = clamp(1.0 - radius / max_radius, 0.4, 1.0)
	var rotation_score = clamp(abs(delta_angle) / 0.2, 0.4, 1.0)

	whisk_quality = lerp(whisk_quality, (radius_score + rotation_score) * 0.5, 0.35)
	bowl.play("mix")

func update_progress(delta):
	if whisk_quality > 0.05:
		local_progress = clamp(local_progress + WHISK_GAIN_SPEED * whisk_quality * delta, BASE_PROGRESS, WHISK_MAX_PROGRESS)
	else:
		# decay but never below BASE_PROGRESS
		local_progress = max(local_progress - WHISK_DECAY_SPEED * delta, BASE_PROGRESS)

	if local_progress >= WHISK_MAX_PROGRESS and not whisk_done:
		whisk_done = true
		emit_signal("whisking_completed")

func pour_ingredient(ingredient: Node2D, group_name: String) -> void:
	if poured[group_name]:
		return
	poured[group_name] = true

	ingredient.set_process(false)
	ingredient.set_physics_process(false)
	ingredient.set_meta("locked", true)

	var sprite: AnimatedSprite2D = ingredient.get_node_or_null("AnimatedSprite2D")
	if sprite == null:
		return

	var target_pos = bowl.global_position + Vector2(0, -60)
	var tween = create_tween()
	tween.tween_property(ingredient, "global_position", target_pos, 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.finished.connect(func():
		sprite.play("pouring")
		ingredient.locked = true
		ingredient.emit_signal("used", group_name)
		ingredient.hide()
		ingredients_poured += 1
		
		# Send ingredient progress to main minigame
		emit_signal("progress_requested", INGREDIENT_PROGRESS)

		if ingredients_poured == 3:
			start_whisking()
	)

func start_whisking():
	whisking_time = true
	whisk.show()
	last_angle = 0.0
	whisk_quality = 0.0

func _on_area_2d_area_entered(area: Area2D) -> void:
	var ingredient = area.get_parent()
	if ingredient.is_in_group("sugar"):
		pour_ingredient(ingredient, "sugar")
	elif ingredient.is_in_group("milk"):
		pour_ingredient(ingredient, "milk")
	elif ingredient.is_in_group("egg"):
		pour_ingredient(ingredient, "egg")
