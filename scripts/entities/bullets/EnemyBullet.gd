extends BaseBullet

func _physics_update(delta: float) -> void:
	# 1. 移动
	global_position += velocity * delta
	
	# 2. 屏幕外销毁
	var rect = GameManager.game_viewport_rect.grow(50)
	if not rect.has_point(global_position):
		change_state(State.DESTROYED)
		return # 销毁了就不检测碰撞了

	# 3. --- 新增：检测是否撞到玩家 ---
	# 既然子弹多，玩家少（就1个），让子弹去检测玩家其实效率还行。
	# 或者以后可以用 Godot 的 Area2D 物理层级，但目前纯代码方案更可控。
	
	var player = GameManager.player
	if player and player.is_alive:
		# check_collision 是 BaseEntity 的方法
		if check_collision(player):
			# 只要是个 BasePlayer，就有 hit() 方法
			if player.has_method("hit"):
				player.hit()
				# 子弹打中玩家后自己要销毁
				change_state(State.DESTROYED)
