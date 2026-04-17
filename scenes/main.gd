extends Node2D

## Main game controller — spawns pipes, manages state, tracks score.

const PIPE_SCENE := preload("res://scenes/pipe.tscn")
const PIPE_INTERVAL := 1.8
const GAP_SIZE := 160.0
const GAP_MIN_Y := 120.0

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var pipe_timer: Timer = $PipeTimer
@onready var pipe_container: Node2D = $PipeContainer
@onready var ground: StaticBody2D = $Ground
@onready var ceiling: StaticBody2D = $Ceiling

var _score := 0
var _high_score := 0
var _playing := false
var _viewport_size: Vector2


func _ready() -> void:
	_viewport_size = get_viewport_rect().size
	_high_score = _load_high_score()
	player.add_to_group("player")
	player.died.connect(_on_player_died)
	hud.start_game.connect(_on_start_game)
	pipe_timer.wait_time = PIPE_INTERVAL
	pipe_timer.timeout.connect(_spawn_pipe)
	_show_title()


func _input(event: InputEvent) -> void:
	# Allow tap/space to start from title screen
	if not _playing and event.is_action_pressed("flap"):
		if hud.title_panel.visible:
			_on_start_game()


func _show_title() -> void:
	_playing = false
	player.set_physics_process(false)
	player.global_position = Vector2(_viewport_size.x * 0.3, _viewport_size.y * 0.5)
	player.rotation = 0
	player.velocity = Vector2.ZERO
	pipe_timer.stop()
	_clear_pipes()
	hud.show_title()


func _on_start_game() -> void:
	_score = 0
	_playing = true
	_clear_pipes()
	player.reset(Vector2(_viewport_size.x * 0.3, _viewport_size.y * 0.5))
	hud.show_game()
	hud.update_score(_score)
	pipe_timer.start()


func _spawn_pipe() -> void:
	var pipe := PIPE_SCENE.instantiate()
	var gap_max_y := _viewport_size.y - GAP_MIN_Y
	var gap_y := randf_range(GAP_MIN_Y + GAP_SIZE / 2.0, gap_max_y - GAP_SIZE / 2.0)
	pipe.position.x = _viewport_size.x + 60
	pipe.setup(gap_y, GAP_SIZE, _viewport_size.y)
	pipe.scored.connect(_on_pipe_scored)
	pipe_container.add_child(pipe)


func _on_pipe_scored() -> void:
	_score += 1
	hud.update_score(_score)


func _on_player_died() -> void:
	_playing = false
	pipe_timer.stop()
	# Stop all pipes
	for pipe in pipe_container.get_children():
		if pipe.has_method("stop"):
			pipe.stop()
	if _score > _high_score:
		_high_score = _score
		_save_high_score(_high_score)
	# Brief delay before showing game over
	await get_tree().create_timer(0.8).timeout
	hud.show_game_over(_score, _high_score)


func _clear_pipes() -> void:
	for pipe in pipe_container.get_children():
		pipe.queue_free()


func _on_player_hitbox_area_entered(_area: Area2D) -> void:
	player.die()


func _on_player_hitbox_body_entered(_body: Node2D) -> void:
	player.die()


# --- Persistence ---

func _save_high_score(score: int) -> void:
	var file := FileAccess.open("user://high_score.dat", FileAccess.WRITE)
	if file:
		file.store_32(score)


func _load_high_score() -> int:
	if FileAccess.file_exists("user://high_score.dat"):
		var file := FileAccess.open("user://high_score.dat", FileAccess.READ)
		if file:
			return file.get_32()
	return 0
