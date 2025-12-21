extends Node2D
@onready var bowl: AnimatedSprite2D = $BowlImage
@onready var whisk: Node = $"../Whisk"
@onready var whiskingProgress: ProgressBar = $ProgressBar
@onready var whiskingDelay: Timer = $Timer 
var mixing 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	whiskingProgress.value = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mixing:
		bowl.play("mix")
		print("mixing bowl..")
		await get_tree().create_timer(1.0).timeout
		whiskingDelay.start()
	else:
		bowl.play("bowl")
		print("not mixing bowl..")
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("whisk"):
		mixing = true
	pass # Replace with function body.
	
func _on_timer_timeout():
	if mixing:
		whiskingProgress.value += 5

	
