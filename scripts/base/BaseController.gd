class_name BaseController extends Node

# 控制器归属的实体 (弱引用，防止循环引用内存泄漏)
var owner_entity: BaseEntity

# 核心接口：控制器初始化
func setup(entity: BaseEntity) -> void:
	owner_entity = entity
	_on_setup()

# 子类重写：初始化逻辑
func _on_setup() -> void:
	pass

# 核心接口：物理更新 (每一帧该怎么动)
# 返回值：Vector2 (本帧的位移增量，或者速度向量，看具体实现约定)
# 这里我们约定：直接操作 owner_entity，或者返回速度向量由 owner 处理
func update_logic(delta: float) -> void:
	pass
