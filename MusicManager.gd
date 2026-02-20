extends Node
class_name AudioManager

var music_volume_db := -10.0
var sfx_volume_db := -8.0

var bgm_library := {
	"title": preload("res://Sound/Title.ogg"),
	"space": preload("res://Sound/Space.ogg"),
	"baking": preload("res://Sound/Baking.ogg"),
}

var sfx_library := {
	"click": preload("res://Sound/click.mp3"),
	"start": preload("res://Sound/start.mp3"),
	"scene1": preload("res://Sound/scene1.mp3"),
	"scene2": preload("res://Sound/scene2.ogg"),
	"scene3": preload("res://Sound/scene3.mp3"),
}

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE := 8


func _ready():
	# Music player
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.volume_db = music_volume_db

	# Pool for overlapping SFX
	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.volume_db = sfx_volume_db
		add_child(p)
		sfx_players.append(p)

func play_bgm(name: String, loop := true):
	if not bgm_library.has(name):
		push_warning("AudioManager: Missing BGM " + name)
		return

	var stream: AudioStream = bgm_library[name]

	if music_player.playing and music_player.stream == stream:
		return

	music_player.stop()
	music_player.stream = stream

	if stream is AudioStreamOggVorbis:
		stream.loop = loop

	music_player.play()


func stop_bgm():
	music_player.stop()

func play_sfx(name: String):
	if not sfx_library.has(name):
		push_warning("AudioManager: Missing SFX " + name)
		return

	var stream: AudioStream = sfx_library[name]

	for p in sfx_players:
		if not p.playing:
			p.stream = stream
			p.play()
			return

func set_music_volume(db: float):
	music_volume_db = db
	music_player.volume_db = db

func set_sfx_volume(db: float):
	sfx_volume_db = db
	for p in sfx_players:
		p.volume_db = db
