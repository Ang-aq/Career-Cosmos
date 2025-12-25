extends Node2D

@onready var progress: ProgressBar = $ProgressBar
@onready var whisk_scene: Node2D = $MixingBowl
@onready var ing_selection: Node2D = $IngSelection
@onready var whisk: Node2D = $Whisk

const WHISK_MAX := 40
const DOUGH_MAX := 100

var phase := "whisking"

func _ready():
	progress.min_value = 0
	progress.max_value = DOUGH_MAX
	progress.value = 0

	whisk_scene.progress_requested.connect(_on_progress_requested)
	whisk_scene.whisking_completed.connect(_on_whisking_completed)

func _on_progress_requested(amount: float):
	progress.value = clamp(progress.value + amount, 0, progress.max_value)

func _on_whisking_completed():
	phase = "kneading"
	whisk_scene.hide()
	ing_selection.hide()
	whisk.hide()
	start_kneading()

func start_kneading():
	var knead_scene := $Dough  
	knead_scene.progress_requested.connect(_on_progress_requested)
	knead_scene.kneading_completed.connect(func():
		progress.value = progress.max_value
		print("Minigame complete!")
	)
	knead_scene.show()
