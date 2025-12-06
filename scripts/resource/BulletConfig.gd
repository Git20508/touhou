# res://scripts/resources/BulletConfig.gd
class_name BulletConfig extends Resource

@export var speed: float = 300.0
@export var damage: int = 1
@export var hitbox_radius: float = 4.0
@export var lifetime: float = 5.0 # 存活时间

@export var texture: Texture2D # 子弹贴图
# 以后可以加更多，比如 颜色枚举、拖尾特效等
