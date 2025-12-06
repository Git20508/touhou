# res://scripts/controllers/movement/SineMoveController.gd
extends BaseController

# 这些参数将来甚至可以从配置里读，现在先暴露在编辑器里方便调试
@export var vertical_speed: float = 100.0
@export var horizontal_amp: float = 200.0
@export var frequency: float = 3.0

var time: float = 0.0

# 重写基类的逻辑更新接口
func update_logic(delta: float) -> void:
	time += delta
	
	# 计算位移增量
	var dy = vertical_speed * delta
	var vx = cos(time * frequency) * horizontal_amp * frequency
	var dx = vx * delta
	
	# 直接操作宿主实体 (owner_entity 是 BaseController 自动注入的)
	if owner_entity:
		owner_entity.global_position += Vector2(dx, dy)
		
		# (可选) 屏幕外销毁检查也可以封装在这里，或者由 Entity 自己管
		if owner_entity.global_position.y > 1000:
			owner_entity.change_state(BaseEntity.State.DESTROYED)
