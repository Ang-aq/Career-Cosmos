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

func _ready():
	MusicManager.play_bgm("baking")
	progress.min_value = 0
	progress.max_value = DOUGH_MAX
	progress.value = 0

	dough_scene.hide()
	cutting_scene.hide()
	decorating_scene.hide()

	whisk_scene.progress_requested.connect(_on_progress_requested)
	whisk_scene.whisking_completed.connect(_on_whisking_completed)

	_show_ingredient_dialogue()

func _on_progress_requested(amount: float):
	if phase == Phase.WHISKING or phase == Phase.KNEADING:
		progress.value = clamp(progress.value + amount, 0, progress.max_value)

func _show_ingredient_dialogue():
	dialogue.show_dialogue([
		{ "name": "Chef", "text": "Hello!" },
		{ "name": "Chef", "text": "You're the new human chef, aren't you?"},
		{ "name": "Chef", "text": "You have a lot to learn to work in a bakery!"},
		{ "name": "Chef", "text": "Lets start with something simple... Donuts!"},
		{ "name": "Chef", "text": "First, you need to add ingredients into the bowl. The list is right here!"}
	])

func _show_mix_dialogue():
	dialogue.show_dialogue([
		{ "name": "Chef", "text": "You did a... PERFECT job!" },
		{ "name": "Chef", "text": "Next, mix the ingredients together. Make sure to mix in fast, circular motions!" }
	])

func _show_kneading_dialogue():
	dialogue.show_dialogue([
		{ "name": "Chef", "text": "Wow, you're a natural at this!!" },
		{ "name": "Chef", "text": "Next please knead the dough until it’s smooth." }
	])

func _show_cutting_dialogue():
	dialogue.show_dialogue([
		{ "name": "Chef", "text": "Good job!" },
		{ "name": "Chef", "text": "You can tell the dough is ready if its smooth and no longer sticky to the touch." },
		{ "name": "Chef", "text": "The next step is to cut the donuts. Please cut 6 of them into the dough!" },
	])

func _show_decorating_dialogue():
	dialogue.show_dialogue([
		{ "name": "Chef", "text": "Next is my favorite part, decorating!" },
		{ "name": "Chef", "text": "Time to show your creativity. Decorate the donuts however you'd like!"},
	])

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

func start_decorating():
	decorating_scene.show()
	decorating_scene.decorating_finished.connect(_on_decorating_finished)

func _on_decorating_finished():
	phase = Phase.DONE
	decorating_scene.hide()
	print("Donut finished!")

func _on_all_ingredients_added():
	_show_mix_dialogue()
	await dialogue.dialogue_finished
	ing_selection.hide()
	whisk_scene.start_whisking()
