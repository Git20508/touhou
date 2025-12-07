extends BaseEnemy

@export var config: EnemyConfig

func _init_entity() -> void:
	# 1. 必须先调用父类，把自己加入 "enemies" 组
	super._init_entity() 

	if not config:
		print("❌ [TestEnemy] 严重错误：没挂载配置文件！")
		return

	# 2. 基础数值注入
	max_hp = config.max_hp
	current_hp = max_hp
	hitbox_radius = config.hitbox_radius
	
	# 3. 视觉注入
	if config.texture and has_node("Sprite2D"):
		$Sprite2D.texture = config.texture
	
	# 4. 控制器注入
	if config.movement_script:
		add_controller("movement", config.movement_script.new())
	if config.attack_script:
		add_controller("attack", config.attack_script.new())
		
	# 5. --- 掉落配置注入 (埋点监控版) ---
	drops.clear() # 先清空
	
	print("🔍 [TestEnemy] 正在读取掉落配置... Config.drop_power = ", config.drop_power)
	
	if config.drop_power > 0:
		drops[BaseItem.ItemType.POWER] = config.drop_power
		
	if config.drop_score > 0:
		drops[BaseItem.ItemType.SCORE] = config.drop_score
	
	print("✅ [TestEnemy] 掉落列表初始化完成: ", drops)
	
	queue_redraw()
