class_name BaseEntity 
extends Node2D

# 实体状态
enum State { IDLE, ACTIVE, HIT, DESTROYED }
var current_state: State = State.IDLE

# 核心属性
@export var hitbox_radius: float = 4.0 
@export var is_alive: bool = true

# --- 补上了这两个信号 ---
signal state_changed(new_state)
signal destroyed() # <--- 之前漏了这个，导致报错

func _ready() -> void:
	_init_entity()

# 子类初始化接口
func _init_entity() -> void:
	pass

# --- 补上了物理更新循环 ---
# 这样子类只需要重写 _physics_update 就能动了
func _physics_process(delta: float) -> void:
	if is_alive:
		_physics_update(delta)

# 子类重写这个来移动
func _physics_update(_delta: float) -> void:
	pass

# 逻辑更新接口
func _logic_update(_delta: float) -> void:
	pass

# 状态切换
func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	state_changed.emit(new_state)
	
	# 如果是销毁状态，且没有被子类（如子弹）拦截处理，默认直接销毁
	if new_state == State.DESTROYED:
		# 注意：BaseBullet 会重写这里来实现“回收”而不是“删除”
		# 普通敌人可能直接在这里处理
		pass

# 碰撞检测
func check_collision(other_entity: BaseEntity) -> bool:
	if not is_alive or not other_entity.is_alive:
		return false
	var dist_sq = global_position.distance_squared_to(other_entity.global_position)
	var radius_sum = hitbox_radius + other_entity.hitbox_radius
	return dist_sq <= radius_sum * radius_sum
