class_name BasePlayer extends BaseEntity

# --- 属性 ---
@export var invincibility_time: float = 3.0
var invincibility_timer: float = 0.0

# 决死参数
var deathbomb_window: float = 0.2
var deathbomb_timer: float = 0.0
## 玩家的擦弹半径
@export var player_graze_radius: float = 24.0 
func _init_entity() -> void:
	super._init_entity()
	hitbox_radius = 2.0 
	add_to_group("player") 
	# 确保父类里的无敌变量初始化
	is_invincible = false
	
	# 出生即活跃
	change_state(State.ACTIVE)
	
	# 出生自带无敌
	_start_invincibility()
	# 设置擦弹半径 (比判定半径2.0大很多)
	graze_radius = player_graze_radius
	# 玩家自己不能被擦
	can_be_grazed = false


func _physics_update(delta: float) -> void:
	# 1. 无敌倒计时
	if is_invincible:
		invincibility_timer -= delta
		# 闪烁效果
		visible = fmod(invincibility_timer, 0.1) > 0.05
		if invincibility_timer <= 0:
			_end_invincibility()

	# 2. 状态逻辑分流
	match current_state:
		# 主动炸弹逻辑 (在 ACTIVE 状态下)
		State.ACTIVE:
			if Input.is_action_just_pressed("bomb"):
				_attempt_manual_bomb()
			
		
		# 决死逻辑 (在 HIT 状态下)
		State.HIT:
			deathbomb_timer -= delta
			
			# 决死判定
			if Input.is_action_just_pressed("bomb"):
				_attempt_deathbomb()
			
			# 超时未按，真死
			if deathbomb_timer <= 0:
				_die_for_real()
# --- 新增：每一帧检测擦弹 ---
	_process_grazing()

# --- 受击入口 ---
func hit() -> void:
	# 只有活跃且非无敌状态才能挨打
	if current_state != State.ACTIVE or is_invincible:
		return
	
	# 进入被弹（决死）判定状态
	print("【系统】 玩家中弹！进入决死判定！")
	change_state(State.HIT)
	deathbomb_timer = deathbomb_window

# --- 主动炸弹 (Panic Bomb) ---
func _attempt_manual_bomb() -> void:
	if GameManager.try_use_bomb():
		print("【系统】 主动释放炸弹！")
		_trigger_bomb_effect()
	else:
		print("【系统】 炸弹不足！")

# --- 决死炸弹 (Deathbomb) ---
func _attempt_deathbomb() -> void:
	if GameManager.try_use_bomb():
		print("【系统】 决死结界成功发动！")
		change_state(State.ACTIVE) # 救回来了
		_trigger_bomb_effect()
	else:
		print("【系统】 没雷了，决死失败！")
		_die_for_real()

# --- 真正的死亡 ---
func _die_for_real() -> void:
	change_state(State.DESTROYED)
	GameManager.on_player_died()
	
	# 死亡特效
	var pichun = preload("res://scenes/effects/DeathEffect.tscn").instantiate()
	pichun.global_position = global_position
	get_parent().add_child(pichun)
	
	# 移到某坐标点等待复活
	visible = false
	global_position = Vector2(0, 0)

# --- 复活逻辑 (GameManager调用) ---
func respawn() -> void:
	# 重置位置
	global_position = Vector2(GameManager.game_viewport_rect.size.x / 2, GameManager.game_viewport_rect.size.y - 100)
	
	# 状态恢复
	current_state = State.ACTIVE
	change_state(State.ACTIVE)
	
	# 开启无敌
	_start_invincibility()

# --- 炸弹效果 (清屏+无敌) ---
func _trigger_bomb_effect() -> void:
	_start_invincibility()
	# TODO: 下一阶段添加清屏弹幕逻辑

# --- 辅助函数：开启无敌 ---
func _start_invincibility() -> void:
	is_invincible = true
	invincibility_timer = invincibility_time
# --- 辅助函数：结束无敌 ---
func _end_invincibility() -> void:
	is_invincible = false
	visible = true
## 擦弹检测循环-擦弹检测方法
func _process_grazing() -> void:
	# 只有在存活状态下才能擦弹
	if current_state != State.ACTIVE: return
	
	# 这里有一个性能权衡：
	# 方案A：玩家遍历所有子弹 (简单，适合Godot GDScript)
	# 方案B：使用 PhysicsServer 的 Area 检测 (更高效，但设置繁琐)
	# 考虑到我们已经有了对象池，我们从 BulletPoolManager 获取活跃子弹可能更快
	
	# 暂时使用 Group 遍历 (Godot 内部有优化，几百个子弹问题不大)
	# 注意：如果同屏子弹超过 2000，这里需要优化为空间划分算法
	var bullets = get_tree().get_nodes_in_group("bullets") # 记得把子弹加入这个组
	
	for bullet in bullets:
		# 调用子弹的 check_graze 方法，传入玩家自己
		if bullet.has_method("check_graze"):
			if bullet.check_graze(self):
				# 擦弹成功！
				_on_player_graze_success()

## 擦弹成功回调
func _on_player_graze_success() -> void:
	# 1. 加分
	# GameManager.add_score(100) # 待实现
	
	# 2. 播放音效 (这是爽感的来源)
	# AudioManager.play_se("graze") 
	
	# 3. 视觉特效 (后续添加粒子)
	print("Graze +1")
