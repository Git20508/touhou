# res://scripts/core/GameManager.gd
extends Node

# --- 现有变量 ---
var player: BaseEntity
var bullet_pool_manager: Node
var game_viewport_rect: Rect2

# --- 新增：残机系统 ---
var default_lives: int = 2 # 默认2残（即3条命）
var current_lives: int = 0
# --- 炸弹系统 ---
var default_bombs: int = 3
var current_bombs: int = 0

signal bomb_count_changed(new_count)

signal player_life_changed(new_lives)
signal game_over()

func _ready() -> void:
	game_viewport_rect = get_viewport().get_visible_rect()
	_init_game()

func _init_game() -> void:
	current_lives = default_lives
	player_life_changed.emit(current_lives)
# 初始化炸弹
	current_bombs = default_bombs
	bomb_count_changed.emit(current_bombs)

# 玩家掉残接口
func on_player_died() -> void:
	current_lives -= 1
	player_life_changed.emit(current_lives)
	
	if current_lives < 0:
		print("【GAME OVER】 胜败乃兵家常事，大侠请重新来过")
		game_over.emit()
		# 这里以后可以暂停游戏或弹出结算界面
	else:
		print("【PICHU~N】 玩家中弹！剩余残机:", current_lives)
		# 通知玩家复活（如果 Player 节点还在的话）
		if player and player.has_method("respawn"):
			player.respawn()
# ... (原有掉残逻辑) ...
	
	if current_lives >= 0:
		# 死后重置炸弹
		current_bombs = default_bombs
		bomb_count_changed.emit(current_bombs)
		
		if player and player.has_method("respawn"):
			player.respawn()
