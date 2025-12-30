extends Node2D

signal whisking_completed
signal progress_requested(amount: float)

@onready var bowl: AnimatedSprite2D = $BowlImage
@onready var bowl_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var whisk: Node2D = $"../Whisk"
@onready var spiral: Sprite2D = $Spiral
@onready var spiral_anim: AnimationPlayer = $Spiral/AnimationPlayer

var poured := {"sugar": false, "milk": false, "egg": false}
var ingredients_poured: int = 0
var whisking_time: bool = false
var whisk_done: bool = false
var whisk_held: bool = false

var last_angle: float = 0.0
var whisk_quality: float = 0.0
var local_progress: float = 0.0
var mixing_locked := true

const INGREDIENT_PROGRESS: float = 5.0
const BASE_PROGRESS: float = 0.0
const WHISK_MAX_PROGRESS: float = 25.0

const ROTATION_THRESHOLD: float = 0.03
const WHISK_GAIN_SPEED: float = 16.0
const WHISK_DECAY_SPEED: float = 3.0

func _ready() -> void:
	whisk.hide()
	spiral.hide()
	spiral_anim.stop()
	bowl.play("bowl")

func _process(delta: float) -> void:
	if not whisking_time or whisk_done:
		return
		
	if mixing_locked:
		return

	var old_progress: float = local_progress

	if whisk_held:
		update_whisk_quality()
		update_progress(delta)
		_update_spiral(true)
	else:
		local_progress = max(local_progress - WHISK_DECAY_SPEED * delta, BASE_PROGRESS)
		_update_spiral(false)

	var delta_progress: float = local_progress - old_progress
	if delta_progress != 0.0:
		emit_signal("progress_requested", delta_progress)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		whisk_held = event.pressed

func update_whisk_quality() -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var center: Vector2 = bowl.global_position
	var vec: Vector2 = mouse_pos - center

	var shape := bowl_shape.shape
	if not shape is CircleShape2D:
		return

	# 🔑 EXPLICIT CAST (THIS FIXES THE ERRORS)
	var circle: CircleShape2D = shape as CircleShape2D

	var radius: float = vec.length()
	var max_radius: float = circle.radius

	if radius > max_radius:
		whisk_quality = move_toward(whisk_quality, 0.0, 0.05)
		return

	var angle: float = vec.angle()
	if last_angle == 0.0:
		last_angle = angle
		return

	var delta_angle: float = wrapf(angle - last_angle, -PI, PI)
	last_angle = angle

	if abs(delta_angle) < ROTATION_THRESHOLD:
		whisk_quality = move_toward(whisk_quality, 0.0, 0.03)
		return

	var radius_score: float = clamp(1.0 - radius / max_radius, 0.4, 1.0)
	var rotation_score: float = clamp(abs(delta_angle) / 0.2, 0.4, 1.0)

	whisk_quality = lerp(
		whisk_quality,
		(radius_score + rotation_score) * 0.5,
		0.35
	)

func update_progress(delta: float) -> void:
	if whisk_quality > 0.05:
		local_progress = clamp(
			local_progress + WHISK_GAIN_SPEED * whisk_quality * delta,
			BASE_PROGRESS,
			WHISK_MAX_PROGRESS
		)
	else:
		local_progress = max(
			local_progress - WHISK_DECAY_SPEED * delta,
			BASE_PROGRESS
		)

	if local_progress >= WHISK_MAX_PROGRESS and not whisk_done:
		whisk_done = true
		_update_spiral(false)
		emit_signal("whisking_completed")

func _update_spiral(active: bool) -> void:
	if active:
		if not spiral.visible:
			spiral.show()

		if not spiral_anim.is_playing():
			spiral_anim.play("spin")
	else:
		if spiral_anim.is_playing():
			spiral_anim.pause()

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

	var target_pos: Vector2 = bowl.global_position + Vector2(0, -60)
	var tween: Tween = create_tween()
	tween.tween_property(
		ingredient,
		"global_position",
		target_pos,
		0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.finished.connect(func() -> void:
		sprite.play("pouring")
		ingredient.emit_signal("used", group_name)
		ingredient.hide()
		ingredients_poured += 1

		emit_signal("progress_requested", INGREDIENT_PROGRESS)

		if ingredients_poured == 3:
			mixing_locked = true
			get_parent()._on_all_ingredients_added()
	)

func start_whisking() -> void:
	mixing_locked = false
	whisking_time = true
	whisk.show()
	spiral.show()
	last_angle = 0.0
	whisk_quality = 0.0
	bowl.play("mix")

func _on_area_2d_area_entered(area: Area2D) -> void:
	var ingredient: Node2D = area.get_parent()

	if ingredient.is_in_group("sugar"):
		pour_ingredient(ingredient, "sugar")
	elif ingredient.is_in_group("milk"):
		pour_ingredient(ingredient, "milk")
	elif ingredient.is_in_group("egg"):
		pour_ingredient(ingredient, "egg")
