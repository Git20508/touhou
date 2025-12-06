# res://scripts/resources/EnemyConfig.gd
class_name EnemyConfig extends Resource

# --- 基础属性 ---
@export_group("Stats")
@export var max_hp: int = 10
@export var score_value: int = 100
@export var hitbox_radius: float = 12.0

# --- 资源引用 ---
# 这里存的是路径或脚本引用，而不是实例
@export_group("Assets")
@export var texture: Texture2D # 敌人的贴图
@export var movement_script: Script # 移动逻辑脚本 (继承自 BaseController)
@export var attack_script: Script   # 攻击逻辑脚本 (继承自 BaseController)
@export var bullet_scene: PackedScene # 发射的子弹类型

# --- 掉落配置 (预留) ---
@export_group("Drops")
@export var drop_power: int = 0  # P点
@export var drop_score: int = 0  # 点数道具
