# res://scripts/ui/TitleScreen.gd
extends Control

# 这里指向你的主测试场景
const GAME_SCENE_PATH = "res://scenes/test/MainTest.tscn"

func _ready() -> void:
	$VBoxContainer/BtnStart.pressed.connect(_on_start_pressed)
	$VBoxContainer/BtnQuit.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	# 切换场景
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_quit_pressed() -> void:
	# 退出游戏
	get_tree().quit()
