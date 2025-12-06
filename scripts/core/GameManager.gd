# res://scripts/core/GameManager.gd
extends Node

# 全局引用
var player: Node2D
var bullet_pool_manager: Node

# 游戏边界（供弹幕判断是否出屏）
var game_viewport_rect: Rect2

func _ready() -> void:
	game_viewport_rect = get_viewport().get_visible_rect()
