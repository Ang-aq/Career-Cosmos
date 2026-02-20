extends Node2D

signal whisking_completed
signal progress_requested(amount: float)

@onready var bowl: AnimatedSprite2D = $BowlImage
@onready var bowl_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var whisk: Node2D = $"../Whisk"
@onready var spiral: Sprite2D = $Spiral

var poured := {"sugar": false, "milk": false, "egg": false, "butter": false}
var ingredients_poured: int = 0
var whisking_time := false
var whisk_done := false
var whisk_held := false

var last_angle: float = 0.0
var whisk_quality: float = 0.0
var local_progress: float = 0.0
var mixing_locked := true

# Motion tracking for smooth spiral
var angular_velocity := 0.0
var spiral_rotation_speed := 0.0
var target_spiral_speed := 0.0
var spin_direction := 1.0

const INGREDIENT_PROGRESS := 5.0
const BASE_PROGRESS := 0.0
const WHISK_MAX_PROGRESS := 25.0

const WHISK_GAIN_SPEED := 16.0
const WHISK_DECAY_SPEED := 3.0

const SPIRAL_SMOOTH := 8.0  # Smooth lerp factor for spiral while whisking
const SPIRAL_DECAY := 3.0   # Slowdown factor when stopping

func _ready() -> void:
	whisk.hide()
	spiral.hide()
	bowl.play("bowl")

# --------------------------------------------------
# MAIN LOOP
# --------------------------------------------------
func _process(delta: float) -> void:
	if not whisking_time or whisk_done:
		return
	if mixing_locked:
		return

	var old_progress := local_progress

	if whisk_held:
		update_whisk_quality(delta)
		update_progress(delta)
		_update_spiral(true, delta)
	else:
		local_progress = max(local_progress - WHISK_DECAY_SPEED * delta, BASE_PROGRESS)
		_update_spiral(false, delta)

	var delta_progress := local_progress - old_progress
	if delta_progress != 0.0:
		emit_signal("progress_requested", delta_progress)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		whisk_held = event.pressed

# --------------------------------------------------
# WHISK MOTION SYSTEM
# --------------------------------------------------
func update_whisk_quality(delta: float) -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	var center := bowl.global_position
	var vec := mouse_pos - center

	var shape := bowl_shape.shape
	if not shape is CircleShape2D:
		return

	var circle := shape as CircleShape2D
	var radius := vec.length()
	var max_radius := circle.radius

	# Outside bowl → decay
	if radius > max_radius:
		whisk_quality = move_toward(whisk_quality, 0.0, delta * 4.0)
		target_spiral_speed = 0.0
		return

	var angle := vec.angle()
	if last_angle == 0.0:
		last_angle = angle
		return

	var delta_angle := wrapf(angle - last_angle, -PI, PI)
	last_angle = angle

	# Compute angular velocity
	angular_velocity = delta_angle / delta

	# Too slow → decay
	if abs(angular_velocity) < 0.5:
		whisk_quality = move_toward(whisk_quality, 0.0, delta * 3.0)
		target_spiral_speed = 0.0
		return

	# Detect spin direction
	spin_direction = sign(angular_velocity)

	# Explicitly typed scores to satisfy GDScript
	var radius_score: float = clamp(radius / max_radius, 0.4, 1.0)
	var speed_score: float = clamp(abs(angular_velocity) / 8.0, 0.3, 1.0)

	var target_quality: float = radius_score * speed_score

	whisk_quality = lerp(whisk_quality, target_quality, 6.0 * delta)

	# Smooth spiral speed target
	target_spiral_speed = angular_velocity * 0.6

# --------------------------------------------------
# PROGRESS SYSTEM
# --------------------------------------------------
func update_progress(delta: float) -> void:
	if whisk_quality > 0.05:
		local_progress = clamp(
			local_progress + WHISK_GAIN_SPEED * whisk_quality * delta,
			BASE_PROGRESS,
			WHISK_MAX_PROGRESS
		)
	else:
		local_progress = max(local_progress - WHISK_DECAY_SPEED * delta, BASE_PROGRESS)

	if local_progress >= WHISK_MAX_PROGRESS and not whisk_done:
		whisk_done = true
		emit_signal("whisking_completed")

# --------------------------------------------------
# SPIRAL VISUAL FEEDBACK (SMOOTH)
# --------------------------------------------------
func _update_spiral(active: bool, delta: float) -> void:
	if active:
		if not spiral.visible:
			spiral.show()
		spiral_rotation_speed = lerp(spiral_rotation_speed, target_spiral_speed, SPIRAL_SMOOTH * delta)
	else:
		target_spiral_speed = 0.0
		spiral_rotation_speed = lerp(spiral_rotation_speed, target_spiral_speed, SPIRAL_DECAY * delta)

	spiral.rotation += spiral_rotation_speed * delta

# --------------------------------------------------
# INGREDIENT POURING
# --------------------------------------------------
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

	var target_pos := bowl.global_position + Vector2(0, -60)

	var tween := create_tween()
	tween.tween_property(
		ingredient,
		"global_position",
		target_pos,
		0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.finished.connect(func():
		sprite.play("pouring")
		ingredient.emit_signal("used", group_name)
		ingredient.hide()

		ingredients_poured += 1
		emit_signal("progress_requested", INGREDIENT_PROGRESS)

		if ingredients_poured == poured.size():
			mixing_locked = true
			get_parent()._on_all_ingredients_added()
	)

# --------------------------------------------------
# START WHISKING
# --------------------------------------------------
func start_whisking() -> void:
	mixing_locked = false
	whisking_time = true
	whisk.show()
	spiral.show()

	last_angle = 0.0
	whisk_quality = 0.0

	bowl.play("mix")

# --------------------------------------------------
# BOWL DETECTION
# --------------------------------------------------
func _on_area_2d_area_entered(area: Area2D) -> void:
	var ingredient := area.get_parent()

	if ingredient.is_in_group("sugar"):
		pour_ingredient(ingredient, "sugar")
	elif ingredient.is_in_group("milk"):
		pour_ingredient(ingredient, "milk")
	elif ingredient.is_in_group("egg"):
		pour_ingredient(ingredient, "egg")
	elif ingredient.is_in_group("butter"):
		pour_ingredient(ingredient, "butter")
