extends Node2D
@onready var blink: AnimatedSprite2D = $Blink
@onready var screenblink: AnimatedSprite2D = $Blink2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_bgm("space", true)

	blink.play("blink")
	screenblink.play("blink")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
