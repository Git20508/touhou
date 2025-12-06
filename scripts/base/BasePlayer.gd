# res://scripts/base/BasePlayer.gd
class_name BasePlayer extends BaseEntity

# --- 属性 ---
# 东方系列经典设定：出生/复活后的无敌时间（秒）
@export var invincibility_time: float = 3.0
var invincibility_timer: float = 0.0
# --- 新增：决死相关 ---
var deathbomb_window: float = 0.2 # 决死有效时间（秒）
var deathbomb_timer: float = 0.0
# 覆盖基类属性：确保玩家判定点很小
func _init_entity() -> void:
	hitbox_radius = 2.0 
	# 玩家必须加入这个组，方便子弹查找
	add_to_group("player") 
	# 确保基类里的无敌开关是关闭的
	is_invincible = false

func _physics_update(delta: float) -> void:
	# 处理无敌时间倒计时
	if is_invincible:
		invincibility_timer -= delta
		
		# 闪烁效果（每0.1秒切换一次可见性）
		# Math.fmod 是取余数
		visible = fmod(invincibility_timer, 0.1) > 0.05
		
		if invincibility_timer <= 0:
			_end_invincibility()
#新增决死状态机
# 1. 处理无敌
	if is_invincible:
		invincibility_timer -= delta
		visible = fmod(invincibility_timer, 0.1) > 0.05
		if invincibility_timer <= 0:
			_end_invincibility()

	# 2. --- 核心：处理决死状态 ---
	if current_state == State.HIT:
		deathbomb_timer -= delta
		
		# 检测按键 (假设炸弹键是 "bomb")
		# 注意：这里我们允许在 HIT 状态下操作
		if Input.is_action_just_pressed("bomb"):
			_attempt_deathbomb()
		
		# 超时未按雷，真死了
		if deathbomb_timer <= 0:
			_die_for_real()
# --- 核心：中弹逻辑 ---
# --- 修改：中弹逻辑 ---
func hit() -> void:
	if current_state != State.ACTIVE or is_invincible:
		return
	
	# 不直接死，而是进入“被弹”状态（暂停时间感觉）
	change_state(State.HIT)
	deathbomb_timer = deathbomb_window
	print("【系统】 决死判定中... (0.2s)")
	
	# 这里可以加一个时间变慢的效果 (Engine.time_scale) 增加演出感，暂时先不用
	# 2. 状态切换
	change_state(State.DESTROYED)
	
	# 3. 通知全局管理器
	GameManager.on_player_died()

# --- 核心：复活逻辑 ---
func respawn() -> void:
	# 1. 重置位置 (通常是屏幕下方中间)
	global_position = Vector2(GameManager.game_viewport_rect.size.x / 2, GameManager.game_viewport_rect.size.y - 100)
	
	# 2. 状态恢复
	current_state = State.ACTIVE
	change_state(State.ACTIVE)
	
	# 3. 开启无敌
	_start_invincibility()
	
	# 4. (可选) 清屏弹幕：复活瞬间通常会消弹
	if GameManager.bullet_pool_manager:
		# 这里以后写，调用 bullet_pool_manager.clear_all()
		pass

# 开启无敌
func _start_invincibility() -> void:
	is_invincible = true
	invincibility_timer = invincibility_time
	print("【系统】 玩家进入无敌状态")

# 结束无敌
func _end_invincibility() -> void:
	is_invincible = false
	visible = true # 确保显示出来
	print("【系统】 玩家无敌解除")
# --- 新增：尝试决死 ---
func _attempt_deathbomb() -> void:
	# 检查是否有雷
	if GameManager.try_use_bomb():
		print("【系统】 决死结界发动！消耗炸弹！")
		
		# 恢复状态
		change_state(State.ACTIVE)
		
		# 触发炸弹效果（清屏+无敌）
		_trigger_bomb_effect()
	else:
		print("【系统】 没雷了，救不了你！")
		# 没雷就不用等时间了，直接死
		_die_for_real()

# --- 新增：真正的死亡 ---
func _die_for_real() -> void:
	change_state(State.DESTROYED)
	GameManager.on_player_died()
	
	# 生成死亡特效
	var pichun = preload("res://scenes/effects/DeathEffect.tscn").instantiate()
	pichun.global_position = global_position
	get_parent().add_child(pichun)
	
	# 隐藏玩家，等待复活（GameManager会调 respawn）
	visible = false
	global_position = Vector2(-1000, -1000) # 移出屏幕防止鞭尸

# --- 新增：炸弹效果 ---
func _trigger_bomb_effect() -> void:
	# 这里简单处理：给无敌，清空子弹
	_start_invincibility()
	if GameManager.bullet_pool_manager:
		# 后面我们要给 PoolManager 加个 clear_all 接口
		pass
