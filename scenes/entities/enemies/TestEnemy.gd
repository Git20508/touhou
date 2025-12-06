# res://scripts/entities/enemies/TestEnemy.gd
extends BaseEnemy

# 唯一需要的对外接口：配置文件
@export var config: EnemyConfig

func _init_entity() -> void:
	# 1. 必须先检查配置是否存在
	if not config:
		push_error("TestEnemy: 缺少配置文件！")
		return

	# 2. 从配置加载基础数值
	max_hp = config.max_hp
	current_hp = max_hp
	hitbox_radius = config.hitbox_radius
	
	# 3. 从配置加载贴图
	if config.texture:
		# 假设场景里有个叫 Sprite2D 的节点
		if has_node("Sprite2D"):
			$Sprite2D.texture = config.texture
			# 根据配置自动调整判定圈可视化 (可选)
	
	# 4. 核心：从配置加载控制器
	# 这是一个“动态注入”的过程
	if config.movement_script:
		# 实例化脚本
		var move_controller = config.movement_script.new()
		# 挂载到架构中 (key 取名为 "movement")
		add_controller("movement", move_controller)
