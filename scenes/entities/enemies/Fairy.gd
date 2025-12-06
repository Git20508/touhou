# res://scripts/entities/enemies/Fairy.gd
extends BaseEnemy

@export var move_speed: float = 100.0

func _physics_update(delta: float) -> void:
	# 简单的向下移动
	global_position.y += move_speed * delta
	
	# 屏幕外自动销毁（复用 BaseEntity 的销毁逻辑）
	if global_position.y > 1000: # 假设屏幕高960
		change_state(State.DESTROYED)
