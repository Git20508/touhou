# res://scripts/base/BaseItem.gd
class_name BaseItem extends BaseEntity

# --- 道具类型枚举 ---
enum ItemType { POWER, SCORE }

# --- 属性 ---
@export var type: ItemType = ItemType.POWER
var velocity: Vector2 = Vector2.ZERO

# 状态标记
var is_magnetized: bool = false # 是否被吸附
var friction: float = 0.96 # 空气阻力（让它出生时有个减速效果）
var max_fall_speed: float = 200.0

func _init_entity() -> void:
	hitbox_radius = 12.0
	add_to_group("items")
	
	# 给一个初始的向上弹跳速度 (模拟爆出来的感觉)
	# X轴随机扩散，Y轴向上冲
	velocity = Vector2(randf_range(-100, 100), randf_range(-300, -150))

func _physics_update(delta: float) -> void:
	if is_magnetized:
		_update_magnet_movement(delta)
	else:
		_update_normal_movement(delta)
	
	# 应用移动
	global_position += velocity * delta
	
	# 屏幕下方销毁
	if global_position.y > GameManager.game_viewport_rect.size.y + 50:
		change_state(State.DESTROYED)
		queue_free()

# 普通下落逻辑
func _update_normal_movement(delta: float) -> void:
	# 1. 阻力减速 (模拟出生时的爆发力逐渐消失)
	velocity.x *= friction
	
	# 2. 重力加速 (逐渐下落)
	if velocity.y < max_fall_speed:
		velocity.y += 600.0 * delta
	
	# 3. 简单的吸附检测 (距离玩家小于 100 像素)
	var player = GameManager.player
	if player and player.is_alive:
		var dist = global_position.distance_to(player.global_position)
		if dist < 100.0:
			is_magnetized = true # 切换状态

# 被吸附逻辑
func _update_magnet_movement(_delta: float) -> void:
	var player = GameManager.player
	if not player or not player.is_alive:
		is_magnetized = false
		return
		
	# 直接飞向玩家
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * 600.0 # 高速飞行
	
	# 距离极近时被吃掉
	if global_position.distance_to(player.global_position) < 20.0:
		_collect()

# 被收集
func _collect() -> void:
	# 简单的加分逻辑
	if type == ItemType.POWER:
		GameManager.add_power(1)
		print("获得P点！")
	
	change_state(State.DESTROYED)
	queue_free()
