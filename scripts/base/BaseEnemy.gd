# res://scripts/base/BaseEnemy.gd
class_name BaseEnemy extends BaseEntity

# 基础属性
var max_hp: int = 10
var current_hp: int

func _init_entity() -> void:
	# 核心修复：确保所有敌人出生时自动加入 "enemies" 组
	# 这样子弹才能找到它
	add_to_group("enemies")
	
	# 初始化血量 (子类 TestEnemy 会覆盖这个，但这里要有默认值)
	current_hp = max_hp

# --- 受击核心逻辑 ---
func take_damage(damage: int) -> void:
	# 尸体不应该受击
	if not is_alive: 
		return
	
	current_hp -= damage
	
	# 1. 视觉反馈：受击闪白 (利用 Tween 动画)
	# 将自身颜色瞬间变为高亮，然后 0.1秒 变回原色
	modulate = Color(10, 10, 10) 
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	# 2. 死亡判定
	if current_hp <= 0:
		_on_death()

# --- 死亡核心逻辑 ---
func _on_death() -> void:
	change_state(State.DESTROYED)
	
	# 暂时直接销毁
	# 以后这里会加入：生成爆炸特效、掉落道具(DropItem)、加分(Score)
	queue_free()
