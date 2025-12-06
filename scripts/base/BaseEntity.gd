# res://scripts/base/BaseEntity.gd
class_name BaseEntity extends Node2D

# --- 状态定义 ---
enum State { IDLE, ACTIVE, HIT, DESTROYED }
var current_state: State = State.IDLE

# --- 核心属性 ---
# 注意：以后这些属性尽量从 Config 里读，但为了兼容，保留默认值
@export var hitbox_radius: float = 4.0 
@export var is_alive: bool = true
@export var is_invincible: bool = false
# --- 架构核心：控制器容器 ---
# 存储所有挂载的控制器，key=名字(如"movement"), value=控制器实例
var controllers: Dictionary = {}

# --- 信号 ---
signal state_changed(new_state)
signal destroyed()

func _ready() -> void:
	_init_entity()

# 子类必须实现的初始化
func _init_entity() -> void:
	pass

# --- 控制器管理系统 (新增) ---

# 挂载一个控制器
func add_controller(key: String, controller: BaseController) -> void:
	# 如果已有同名控制器，先清理旧的
	if controllers.has(key):
		controllers[key].queue_free()
	
	controllers[key] = controller
	add_child(controller) # 把控制器作为子节点挂载
	controller.setup(self) # 注入依赖

# 获取控制器
func get_controller(key: String) -> BaseController:
	return controllers.get(key)

# 移除控制器
func remove_controller(key: String) -> void:
	if controllers.has(key):
		controllers[key].queue_free()
		controllers.erase(key)

# --- 主循环 (核心修改) ---
func _physics_process(delta: float) -> void:
	if not is_alive: 
		return
	
	# 1. 执行基类/子类自身的物理更新 (兼容旧代码)
	_physics_update(delta)
	
	# 2. 驱动所有挂载的控制器 (新架构)
	# 遍历字典的值，让每个控制器执行自己的逻辑
	for controller in controllers.values():
		controller.update_logic(delta)

func _process(delta: float) -> void:
	if not is_alive: return
	_logic_update(delta)

# --- 子类钩子 ---
func _physics_update(_delta: float) -> void:
	pass

func _logic_update(_delta: float) -> void:
	pass

# --- 通用功能 (保持不变) ---
func change_state(new_state: State) -> void:
	if current_state == new_state: return
	current_state = new_state
	state_changed.emit(new_state)

func check_collision(other: BaseEntity) -> bool:
	if not is_alive or not other.is_alive: return false
	var r = hitbox_radius + other.hitbox_radius
	return global_position.distance_squared_to(other.global_position) <= r * r

# 调试绘图
func _draw() -> void:
	if OS.has_feature("editor"):
		draw_circle(Vector2.ZERO, hitbox_radius, Color(1, 0, 0, 0.5))
		draw_circle(Vector2.ZERO, 1.0, Color.WHITE)
