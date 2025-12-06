# res://scripts/base/BaseController.gd
class_name BaseController extends Node

# 控制器归属的实体 (弱引用)
var owner_entity: BaseEntity

# --- 核心接口 ---

# 1. 初始化 (当控制器被挂载到实体时调用)
func setup(entity: BaseEntity) -> void:
	owner_entity = entity
	_on_setup()

# 子类重写：初始化逻辑 (获取配置、初始化变量)
func _on_setup() -> void:
	pass

# 2. 逻辑更新 (每一帧由 BaseEntity 驱动)
# 类似于 _process 或 _physics_process
func update_logic(delta: float) -> void:
	pass
