extends CanvasLayer

## HUD — displays score, title screen, and game over.

signal start_game

@onready var score_label: Label = $ScoreLabel
@onready var title_panel: VBoxContainer = $TitlePanel
@onready var game_over_panel: VBoxContainer = $GameOverPanel
@onready var final_score_label: Label = $GameOverPanel/FinalScoreLabel
@onready var high_score_label: Label = $GameOverPanel/HighScoreLabel


func _ready() -> void:
	game_over_panel.visible = false
	score_label.visible = false


func show_title() -> void:
	title_panel.visible = true
	game_over_panel.visible = false
	score_label.visible = false


func show_game() -> void:
	title_panel.visible = false
	game_over_panel.visible = false
	score_label.visible = true


func show_game_over(score: int, high_score: int) -> void:
	title_panel.visible = false
	game_over_panel.visible = true
	final_score_label.text = "KILLS: %d" % score
	high_score_label.text = "RECORD: %d" % high_score


func update_score(score: int) -> void:
	score_label.text = str(score)


func _on_start_button_pressed() -> void:
	start_game.emit()


func _on_restart_button_pressed() -> void:
	start_game.emit()
