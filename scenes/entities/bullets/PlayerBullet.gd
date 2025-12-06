# res://scripts/entities/bullets/PlayerBullet.gd
extends BaseBullet

func _init_entity() -> void:
	hitbox_radius = 5.0
	damage = 2
	velocity = Vector2(0, -900)
	print()

# 重写物理更新，加入碰撞检测
func _physics_update(delta: float) -> void:
	# 1. 先执行基类的移动逻辑 (BaseBullet 里写的移动)
	super._physics_update(delta)
	
	# 2. 检测碰撞
	# 获取当前场景里所有在 "enemies" 组的节点
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		# check_collision 是 BaseEntity 写好的数学计算方法
		if check_collision(enemy):
			_hit_enemy(enemy)
			break # 一颗子弹只打一个敌人，打中就跳出循环

# 击中后的处理
func _hit_enemy(enemy: BaseEntity) -> void:
	# 敌人扣血
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)
	
	# 子弹销毁（回收）
	change_state(State.DESTROYED)
	
	# (可选) 这里以后可以播放击中音效或生成小火花
