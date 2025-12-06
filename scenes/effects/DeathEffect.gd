# res://scripts/effects/DeathEffect.gd
extends Node2D

func _ready() -> void:
	# 简单的扩圈动画
	scale = Vector2(0.1, 0.1)
	modulate.a = 1.0
	
	var tween = create_tween()
	# 0.5秒内放大到 10倍
	tween.tween_property(self, "scale", Vector2(10, 10), 0.5)
	# 同时透明度归零
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
	
	# 动画播完销毁
	tween.tween_callback(queue_free)
