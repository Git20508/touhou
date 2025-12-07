# res://scripts/base/BaseEntity.gd
class_name BaseEntity extends Node2D

# --- 状态定义 ---
enum State { IDLE, ACTIVE, HIT, DESTROYED }
var current_state: State = State.IDLE
# --- 扩展属性：擦弹系统 ---
## 擦弹半径 (通常比碰撞半径大得多)
@export var graze_radius: float = 12.0 
## 该实体是否可以被擦弹 (如子弹为true，玩家为false)
@export var can_be_grazed: bool = false
## 是否已经被擦过 (防止一颗子弹无限刷分)
var _has_been_grazed: bool = false
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
# --- 扩展方法：擦弹检测 ---
## 检测是否可以被目标实体擦弹
## other: 通常是玩家
func check_graze(other: BaseEntity) -> bool:
	# 基础条件检查：
	# 1. 自己必须活着
	# 2. 对方必须活着
	# 3. 自己必须允许被擦弹
	# 4. 自己还没被这轮擦过
	if not is_alive or not other.is_alive: return false
	if not can_be_grazed or _has_been_grazed: return false
	
	# 计算擦弹距离 (两者擦弹半径之和)
	var r = graze_radius + other.graze_radius
	var dist_sq = global_position.distance_squared_to(other.global_position)
	
	if dist_sq <= r * r:
		_on_grazed()
		return true
	
	return false

## 当由于被擦弹触发的回调
func _on_grazed() -> void:
	_has_been_grazed = true
	# 这里可以播放擦弹音效，或者生成擦弹特效（小白圈）
	# print("Graze!")
