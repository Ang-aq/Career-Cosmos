extends Node2D

@onready var progress: ProgressBar = $ProgressBar
@onready var whisk_scene: Node2D = $MixingBowl
@onready var ing_selection: Node2D = $IngSelection
@onready var whisk: Node2D = $Whisk
@onready var dough_scene: Control = $Dough
@onready var cutting_scene: Control = $DoughCutting
@onready var decorating_scene: Control = $DonutDecorating
@onready var dialogue: Node2D = $Dialogue

const DOUGH_MAX := 100

enum Phase {
	WHISKING,
	KNEADING,
	CUTTING,
	DECORATING,
	DONE
}

var phase := Phase.WHISKING

# -------------------------
# READY
# -------------------------
func _ready():
	progress.min_value = 0
	progress.max_value = DOUGH_MAX
	progress.value = 0

	dough_scene.hide()
	cutting_scene.hide()
	decorating_scene.hide()

	whisk_scene.progress_requested.connect(_on_progress_requested)
	whisk_scene.whisking_completed.connect(_on_whisking_completed)

	_show_ingredient_dialogue()

# -------------------------
# PROGRESS
# -------------------------
func _on_progress_requested(amount: float):
	if phase == Phase.WHISKING or phase == Phase.KNEADING:
		progress.value = clamp(progress.value + amount, 0, progress.max_value)

# -------------------------
# DIALOGUE HELPERS
# -------------------------
func _show_ingredient_dialogue():
	dialogue.show_dialogue([
		{ "name": "Chef", "text": "The first step is adding the ingredients." }
	])

func _show_mix_dialogue():
	dialogue.show_dialogue([
		{ "name": "Chef", "text": "Now mix the ingredients together." }
	])

func _show_kneading_dialogue():
	dialogue.show_dialogue([
		{ "name": "Chef", "text": "Now knead the dough until it’s smooth." }
	])

func _show_cutting_dialogue():
	dialogue.show_dialogue([
		{ "name": "Chef", "text": "Time to cut the donuts carefully." }
	])

func _show_decorating_dialogue():
	dialogue.show_dialogue([
		{ "name": "Chef", "text": "Decorate your donuts however you like!" }
	])

# -------------------------
# PHASE FLOW
# -------------------------
func _on_whisking_completed():
	if phase != Phase.WHISKING:
		return

	phase = Phase.KNEADING

	_show_kneading_dialogue()
	await dialogue.dialogue_finished

	whisk_scene.hide()
	whisk.hide()

	start_kneading()

func start_kneading():
	dough_scene.show()
	dough_scene.progress_requested.connect(_on_progress_requested)
	dough_scene.kneading_completed.connect(_on_kneading_finished)

func _on_kneading_finished():
	if phase != Phase.KNEADING:
		return


	_show_cutting_dialogue()
	await dialogue.dialogue_finished
	
	phase = Phase.CUTTING
	start_cutting_donuts()

func start_cutting_donuts():
	cutting_scene.reset_and_activate()
	cutting_scene.show()
	cutting_scene.donut_cutting_finished.connect(_on_cutting_finished)

func _on_cutting_finished():
	if phase != Phase.CUTTING:
		return

	phase = Phase.DECORATING
	cutting_scene.hide()

	_show_decorating_dialogue()
	await dialogue.dialogue_finished

	start_decorating()

# -------------------------
# DECORATING
# -------------------------
func start_decorating():
	decorating_scene.show()
	decorating_scene.decorating_finished.connect(_on_decorating_finished)

func _on_decorating_finished():
	phase = Phase.DONE
	decorating_scene.hide()
	print("Donut finished! 🎉")

# -------------------------
# INGREDIENT → MIX TRANSITION
# -------------------------
func _on_all_ingredients_added():
	_show_mix_dialogue()
	await dialogue.dialogue_finished
	ing_selection.hide()
	whisk_scene.start_whisking()
