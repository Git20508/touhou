# res://scripts/controllers/attack/AimedAttackController.gd
extends BaseController

# --- 可配置参数 ---
@export var bullet_scene: PackedScene # 发射什么子弹
@export var speed: float = 300.0      # 子弹速度
@export var cooldown: float = 1.0     # 射击间隔
@export var start_delay: float = 0.5  # 出生后延迟多久开枪

var timer: float = 0.0

func _on_setup() -> void:
	# 初始延迟，避免敌人刚刷出来就开枪，给玩家反应时间
	timer = start_delay
	
	# 如果编辑器没拖子弹，尝试从敌人的 Config 里读（如果有的话）
	# 这是一种灵活的“回退策略”
	if not bullet_scene and owner_entity.get("config") and owner_entity.config.bullet_scene:
		bullet_scene = owner_entity.config.bullet_scene

func update_logic(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		shoot()
		timer = cooldown

func shoot() -> void:
	# 1. 安全检查
	if not bullet_scene: return
	if not GameManager.player: return # 玩家死了就不射了
	
	# 2. 从对象池获取子弹
	var pool = GameManager.bullet_pool_manager
	if not pool: return
	var bullet = pool.get_bullet(bullet_scene)
	
	# 3. 设定子弹参数
	# 位置：从敌人中心发射
	bullet.global_position = owner_entity.global_position
	
	# 方向：指向玩家
	var direction = (GameManager.player.global_position - owner_entity.global_position).normalized()
	
	# 速度：方向 * 速率
	bullet.velocity = direction * speed
	
	# (可选) 旋转子弹贴图朝向
	bullet.rotation = direction.angle() + PI/2
