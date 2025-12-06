extends BasePlayer

# --- 变量定义区 ---
@export var high_speed: float = 400.0
@export var low_speed: float = 150.0

# 预加载子弹场景
@export var bullet_scene: PackedScene = preload("res://scenes/entities/bullets/PlayerBullet.tscn")

# 射击相关变量
var fire_timer: float = 0.0
var fire_rate: float = 0.08 # 射击间隔（秒）

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox_visual: ColorRect = $HitboxVisual

var viewport_rect: Rect2

# --- 初始化 ---
func _init_entity() -> void:
	super._init_entity() # 这一步很重要！父类里设置了 hitbox=2.0 和 group="player"
	
	viewport_rect = get_viewport_rect()
	if hitbox_visual:
		hitbox_visual.visible = false
	
	# 初始出生时也给一点无敌时间，防止骑脸死
	_start_invincibility()
# 注册自己到全局管理器
func _ready() -> void:
	super._ready() # 必须调用父类的 ready
	GameManager.player = self

# --- 核心循环 (只保留这一个！) ---
func _process(delta: float) -> void:
	if not is_alive: return
	
	# 1. 处理移动
	_handle_movement(delta)
	
	# 2. 处理动作（射击）
	_handle_actions()
	
	# 3. 更新射击冷却时间
	if fire_timer > 0:
		fire_timer -= delta

# --- 具体逻辑函数 ---
func _handle_movement(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_focused = Input.is_action_pressed("focus")
	var current_speed = low_speed if is_focused else high_speed
	
	if hitbox_visual:
		hitbox_visual.visible = is_focused
	
	if input_dir != Vector2.ZERO:
		var velocity = input_dir * current_speed * delta
		global_position += velocity
		
		# 限制边界
		var padding = 10.0
		global_position.x = clamp(global_position.x, padding, viewport_rect.size.x - padding)
		global_position.y = clamp(global_position.y, padding, viewport_rect.size.y - padding)
		
		_update_tilt_animation(input_dir.x)
	else:
		_update_tilt_animation(0)

func _handle_actions() -> void:
	if Input.is_action_pressed("shoot"):
		# 检查冷却时间
		if fire_timer <= 0:
			shoot()
			fire_timer = fire_rate

func shoot() -> void:
	# 从对象池获取子弹
	if GameManager.bullet_pool_manager:
		var bullet = GameManager.bullet_pool_manager.get_bullet(bullet_scene)
		if bullet:
			# 设置位置：从飞机头部发射
			bullet.global_position = global_position + Vector2(0, -20)
			# 设置速度：向上飞
			bullet.velocity = Vector2(0, -900)

func _update_tilt_animation(dir_x: float) -> void:
	if dir_x > 0:
		sprite.rotation_degrees = lerp(sprite.rotation_degrees, 5.0, 0.2)
	elif dir_x < 0:
		sprite.rotation_degrees = lerp(sprite.rotation_degrees, -5.0, 0.2)
	else:
		sprite.rotation_degrees = lerp(sprite.rotation_degrees, 0.0, 0.2)
