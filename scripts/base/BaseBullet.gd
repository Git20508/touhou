# res://scripts/base/BaseBullet.gd
class_name BaseBullet 
extends BaseEntity

var velocity: Vector2 = Vector2.ZERO
var damage: int = 1

# 自动销毁边界（稍微比屏幕大一点，避免刚好在边缘消失很难看）
var despawn_margin: float = 50.0

func _init_entity() -> void:
	# 子弹默认也是圆的
	hitbox_radius = 4.0

func _physics_update(delta: float) -> void:
	# 移动
	global_position += velocity * delta
	
	# 旋转（可选，让子弹头朝向移动方向）
	if velocity != Vector2.ZERO:
		rotation = velocity.angle() + PI/2 # +PI/2 是因为Godot 0度通常指向右，而子弹贴图通常指向上

	# 屏幕外检测（核心优化）
	if not GameManager.game_viewport_rect.grow(despawn_margin).has_point(global_position):
		_on_exit_screen()

# 出屏处理
func _on_exit_screen() -> void:
	# 这里以后会改为“回收进对象池”
	change_state(State.DESTROYED)

# 覆盖基类的销毁，暂时先直接 QueueFree，下一步接对象池
func change_state(new_state: State) -> void:
	if current_state == new_state: return
	current_state = new_state
	
	if new_state == State.DESTROYED:
		# 发送销毁信号，让对象池知道
		destroyed.emit()
