# res://scripts/ui/PauseMenu.gd
extends CanvasLayer

# 预加载标题画面场景 (路径要对！)
# 注意：我们稍后才创建 TitleScreen，现在先留个占位符，或者写字符串
const TITLE_SCENE_PATH = "res://scenes/ui/TitleScreen.tscn"

func _ready() -> void:
	# 初始隐藏
	visible = false
	
	# 连接信号 (你也可以在编辑器里连)
	$VBoxContainer/BtnResume.pressed.connect(_on_resume_pressed)
	$VBoxContainer/BtnRestart.pressed.connect(_on_restart_pressed)
	$VBoxContainer/BtnQuit.pressed.connect(_on_quit_pressed)

func _input(event: InputEvent) -> void:
	# 监听 ESC 键 (ui_cancel 是 Godot 默认绑定的 ESC)
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_resume_game()
		else:
			_pause_game()

func _pause_game() -> void:
	visible = true
	get_tree().paused = true # 冻结游戏树
	
func _resume_game() -> void:
	visible = false
	get_tree().paused = false # 解冻

# --- 按钮回调 ---

func _on_resume_pressed() -> void:
	_resume_game()

func _on_restart_pressed() -> void:
	_resume_game() # 先解冻，否则重载后还是暂停的
	get_tree().reload_current_scene() # 重载当前场景

func _on_quit_pressed() -> void:
	_resume_game() # 先解冻
	# 切换到标题画面
	get_tree().change_scene_to_file(TITLE_SCENE_PATH)
