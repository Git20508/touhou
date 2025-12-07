class_name BaseEnemy extends BaseEntity

var max_hp: int = 10
var current_hp: int
var drops: Dictionary = {} 

func _init_entity() -> void:
	add_to_group("enemies")
	current_hp = max_hp

func take_damage(damage: int) -> void:
	if not is_alive: return
	
	current_hp -= damage
	
	# 受击闪白
	modulate = Color(10, 10, 10)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	if current_hp <= 0:
		print("💀 [BaseEnemy] 血量归零，触发死亡流程！")
		_on_death()

func _on_death() -> void:
	change_state(State.DESTROYED)
	_spawn_drops() # 调用掉落逻辑
	queue_free()   # 销毁自己

func _spawn_drops() -> void:
	print("📦 [BaseEnemy] 尝试生成掉落物... 当前 drops 数据: ", drops)
	
	if drops.is_empty(): 
		print("⚠️ [BaseEnemy] 掉落列表为空，不生成任何物品。")
		return

	# 尝试加载道具场景
	var item_scene = load("res://scenes/entities/items/BaseItem.tscn")
	if not item_scene:
		print("❌ [BaseEnemy] 致命错误：找不到 BaseItem.tscn 文件！请检查路径！")
		return

	# 开始生成
	var total_count = 0
	for type in drops:
		var count = drops[type]
		for i in range(count):
			var item = item_scene.instantiate()
			# 安全检查：确保 BaseItem 脚本里有 type 变量
			if "type" in item:
				item.type = type
			else:
				print("❌ [BaseEnemy] BaseItem.gd 脚本似乎没写好，找不到 type 属性")
			
			# 随机位置
			item.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
			
			# 添加到场景根节点 (最稳妥的方式)
			get_tree().current_scene.call_deferred("add_child", item)
			total_count += 1
			
	print("✅ [BaseEnemy] 成功生成了 ", total_count, " 个掉落物！")
