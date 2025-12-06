class_name EnemyConfig extends Resource

# 基础数值
@export_group("Base Stats")
@export var max_hp: int = 10
@export var score_value: int = 100
@export var hitbox_radius: float = 12.0

# 资源路径 (解耦的关键：只存路径，用到时再加载)
@export_group("Assets")
@export var texture: Texture2D
@export var movement_script: Script # 指定用哪个移动逻辑
@export var attack_script: Script   # 指定用哪个攻击逻辑
@export var bullet_type: PackedScene # 发射什么子弹

# 掉落配置 (预留)
@export_group("Drops")
@export var drop_power: int = 0
@export var drop_point: int = 0
