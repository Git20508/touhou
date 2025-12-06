# res://scripts/entities/enemies/TestEnemy.gd
extends BaseEnemy

@export var config: EnemyConfig

func _init_entity() -> void:
	# --- 关键修复：调用父类初始化 ---
	# 这行代码会执行 BaseEnemy 里的 add_to_group("enemies")
	super._init_entity() 
	# -----------------------------
# --- 新增：加载攻击控制器 ---
	if config.attack_script:
		var atk_controller = config.attack_script.new()
		# 挂载到架构中 (key 取名为 "attack")
		add_controller("attack", atk_controller)
	
	queue_redraw()
	if not config:
		push_error("[TestEnemy] 缺少配置文件！")
		return

	# 从配置覆盖数据
	max_hp = config.max_hp
	current_hp = max_hp # 这一步很重要，因为父类初始化时可能用的是旧的 max_hp
	hitbox_radius = config.hitbox_radius
	
	# 加载贴图
	if config.texture and has_node("Sprite2D"):
		$Sprite2D.texture = config.texture
	
	# 加载控制器
	if config.movement_script:
		var move_controller = config.movement_script.new()
		add_controller("movement", move_controller)
	
	# 强制刷新调试绘图
	queue_redraw()
