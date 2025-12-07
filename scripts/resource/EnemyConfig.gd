class_name EnemyConfig extends Resource

@export_group("Stats")
@export var max_hp: int = 10
@export var score_value: int = 100
@export var hitbox_radius: float = 12.0

@export_group("Assets")
@export var texture: Texture2D
@export var movement_script: Script
@export var attack_script: Script
@export var bullet_scene: PackedScene

# --- 重点检查这里 ---
@export_group("Drops")
@export var drop_power: int = 0  # 确保这个变量存在！
@export var drop_score: int = 0
