# res://scripts/core/BulletPoolManager.gd
extends Node

# 字典结构： { "场景路径": [空闲的子弹实例, ...] }
var pools: Dictionary = {}

func _ready() -> void:
	# 把自己注册给 GameManager
	GameManager.bullet_pool_manager = self

# 获取子弹（如果有空闲就复用，没有就新建）
func get_bullet(bullet_scene: PackedScene) -> BaseBullet:
	var path = bullet_scene.resource_path
	if not pools.has(path):
		pools[path] = []
	
	var bullet: BaseBullet
	if pools[path].size() > 0:
		bullet = pools[path].pop_back()
		# 重置状态
		bullet.is_alive = true
		bullet.current_state = BaseEntity.State.ACTIVE
		bullet.show()
		# 记得把所有处理设为启用
		bullet.set_process(true)
		bullet.set_physics_process(true)
	else:
		bullet = bullet_scene.instantiate()
		# 监听销毁信号，以便回收
		# 注意：这里我们用绑定把 path 传进去
		bullet.destroyed.connect(_return_to_pool.bind(bullet, path))
		add_child(bullet) # 把子弹挂在 PoolManager 下面，保持场景整洁
		
	return bullet

# 回收子弹
func _return_to_pool(bullet: BaseBullet, path: String) -> void:
	# 停止处理，隐藏
	bullet.is_alive = false
	bullet.hide()
	bullet.set_process(false)
	bullet.set_physics_process(false)
	
	# 放回池子
	if not pools.has(path):
		pools[path] = []
	pools[path].append(bullet)
