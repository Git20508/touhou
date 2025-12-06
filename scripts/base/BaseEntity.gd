class_name BaseEntity extends Node2D

# --- 状态与信号 ---
enum State { IDLE, ACTIVE, HIT, DESTROYED }
var current_state: State = State.IDLE
signal state_changed(new_state)
signal destroyed()

# --- 核心架构升级 ---
# 1. 挂载控制器容器 (用来放各种组件)
var controllers: Dictionary = {} 

# 2. 通用属性 (现在通常由 Config 覆盖)
@export var hitbox_radius: float = 4.0 
@export var is_alive: bool = true

func _ready() -> void:
	_init_entity()

# 子类必须实现的初始化
func _init_entity() -> void:
	pass

# --- 控制器系统 ---
# 添加一个控制器 (比如：add_controller("movement", SineMove.new()))
func add_controller(key: String, controller: BaseController) -> void:
	if controllers.has(key):
		controllers[key].queue_free() # 移除旧的
	
	controllers[key] = controller
	add_child(controller)
	controller.setup(self) # 注入依赖

# 获取控制器
func get_controller(key: String) -> BaseController:
	return controllers.get(key)

# 统一驱动所有控制器
func _physics_process(delta: float) -> void:
	if not is_alive: return
	
	# 1. 基类自身的物理更新 (如果有)
	_physics_update(delta)
	
	# 2. 驱动所有挂载的控制器
	for controller in controllers.values():
		controller.update_logic(delta)

# 子类钩子
func _physics_update(_delta: float) -> void:
	pass

func _draw() -> void:
	if OS.has_feature("editor"):
		draw_circle(Vector2.ZERO, hitbox_radius, Color(1, 0, 0, 0.5))

# --- 其他通用逻辑 (check_collision, change_state) 保持不变 ---
func change_state(new_state: State) -> void:
	if current_state == new_state: return
	current_state = new_state
	state_changed.emit(new_state)

func check_collision(other: BaseEntity) -> bool:
	if not is_alive or not other.is_alive: return false
	var r = hitbox_radius + other.hitbox_radius
	return global_position.distance_squared_to(other.global_position) <= r * r
