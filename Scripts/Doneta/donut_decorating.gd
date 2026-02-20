extends Control

signal decorating_finished

@onready var donut_base: Sprite2D = $DonutBase
@onready var icing: Sprite2D = $Icing
@onready var sprinkles: Sprite2D = $Sprinkles

@onready var donut_hitbox: Area2D = $DonutBase/Hitbox
@onready var icing_hitbox: Area2D = $Icing/Hitbox

@onready var left_arrow: TextureButton = $LeftArrow
@onready var right_arrow: TextureButton = $RightArrow
@onready var done_button: TextureButton = $DoneButton

var donut_textures := [
	preload("res://Sprites/Doneta/Donuts/BlueDonut.png"),
	preload("res://Sprites/Doneta/Donuts/ChocoDonut.png"),
	preload("res://Sprites/Doneta/Donuts/PinkDonut.png"),
	preload("res://Sprites/Doneta/Donuts/WhiteDonut.png"),
]

var icing_textures := [
	preload("res://Sprites/Doneta/Donuts/BlueIcing.png"),
	preload("res://Sprites/Doneta/Donuts/GreenIcing.png"),
	preload("res://Sprites/Doneta/Donuts/IndigoIcing.png"),
	preload("res://Sprites/Doneta/Donuts/OrangeIcing.png"),
	preload("res://Sprites/Doneta/Donuts/PinkFrosting.png"),
	preload("res://Sprites/Doneta/Donuts/PurpleIcing.png"),
	preload("res://Sprites/Doneta/Donuts/RedIcing.png"),
]

var sprinkle_textures := [
	preload("res://Sprites/Doneta/Donuts/PinkHeartSprinkles.png"),
	preload("res://Sprites/Doneta/Donuts/RainbowSprinkles.png"),
	preload("res://Sprites/Doneta/Donuts/WhiteHeartSprinkles.png"),
	preload("res://Sprites/Doneta/Donuts/WhiteSprinkles.png"),
]

var donut_index := 0
var icing_index := 0
var sprinkle_index := 0

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	_update_all()

	donut_hitbox.input_event.connect(_on_donut_clicked)
	icing_hitbox.input_event.connect(_on_icing_clicked)

	left_arrow.pressed.connect(_on_left_arrow_pressed)
	right_arrow.pressed.connect(_on_right_arrow_pressed)
	done_button.pressed.connect(_on_done_pressed)

func _on_donut_clicked(_viewport, event: InputEvent, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		donut_index = (donut_index + 1) % donut_textures.size()
		donut_base.texture = donut_textures[donut_index]

func _on_icing_clicked(_viewport, event: InputEvent, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		icing_index = (icing_index + 1) % icing_textures.size()
		icing.texture = icing_textures[icing_index]

func _on_left_arrow_pressed():
	sprinkle_index = (sprinkle_index - 1 + sprinkle_textures.size()) % sprinkle_textures.size()
	sprinkles.texture = sprinkle_textures[sprinkle_index]

func _on_right_arrow_pressed():
	sprinkle_index = (sprinkle_index + 1) % sprinkle_textures.size()
	sprinkles.texture = sprinkle_textures[sprinkle_index]

func _on_done_pressed():
	decorating_finished.emit()
	hide()

func _update_all():
	donut_base.texture = donut_textures[donut_index]
	icing.texture = icing_textures[icing_index]
	sprinkles.texture = sprinkle_textures[sprinkle_index]
