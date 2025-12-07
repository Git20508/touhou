# res://scripts/core/GameManager.gd
extends Node

# --- 全局引用 ---
var player: BaseEntity
var bullet_pool_manager: Node

# 游戏边界
var game_viewport_rect: Rect2

# --- 残机系统 ---
var default_lives: int = 2
var current_lives: int = 0

# --- 炸弹系统 (之前缺失的部分) ---
var default_bombs: int = 3
var current_bombs: int = 0

# --- 信号 ---
signal player_life_changed(new_lives)
signal bomb_count_changed(new_count)
signal game_over()

func _ready() -> void:
	game_viewport_rect = get_viewport().get_visible_rect()
	# 延迟一帧初始化，确保其他节点都 ready 了
	call_deferred("_init_game")

func _init_game() -> void:
	# 初始化残机
	current_lives = default_lives
	player_life_changed.emit(current_lives)
	
	# 初始化炸弹
	current_bombs = default_bombs
	bomb_count_changed.emit(current_bombs)

# --- 核心：尝试消耗炸弹 ---
# BasePlayer 调用的就是这个函数！
func try_use_bomb() -> bool:
	if current_bombs > 0:
		current_bombs -= 1
		bomb_count_changed.emit(current_bombs)
		return true
	return false

# --- 核心：玩家死亡处理 ---
func on_player_died() -> void:
	current_lives -= 1
	player_life_changed.emit(current_lives)
	
	if current_lives < 0:
		print("【GAME OVER】 胜败乃兵家常事")
		game_over.emit()
	else:
		print("【PICHU~N】 玩家中弹！剩余残机:", current_lives)
		
		# 死后重置炸弹 (东方传统：死后B补满)
		current_bombs = default_bombs
		bomb_count_changed.emit(current_bombs)
		
		# 通知玩家复活
		if player and player.has_method("respawn"):
			player.respawn()

# --- 经济系统接口 ---
func add_power(value: int) -> void:
	# 这里以后会写 Power 变量增加的逻辑，现在先打印
	print("【系统】 灵力增加: ", value)

func add_score(value: int) -> void:
	print("【系统】 得分增加: ", value)
