# res://scripts/base/BaseEnemy.gd
class_name BaseEnemy 
extends BaseEntity

@export var max_hp: int = 10
var current_hp: int

func _init_entity() -> void:
	current_hp = max_hp
	hitbox_radius = 12.0 # 敌人判定圈通常比玩家大
	
	# 关键：把自己加入 "enemies" 组，方便子弹查找
	add_to_group("enemies")

# 受击逻辑
func take_damage(damage: int) -> void:
	if not is_alive: return
	
	current_hp -= damage
	# 这里可以加个受击闪白效果
	modulate = Color(10, 10, 10) # 瞬间变亮
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1) # 0.1秒变回来
	
	if current_hp <= 0:
		_on_death()

# 死亡逻辑
func _on_death() -> void:
	# 以后这里会生成爆炸特效、掉落道具
	change_state(State.DESTROYED)
