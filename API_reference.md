好的，这是一份专业化的项目文档。这两份文档旨在帮助新加入的团队成员快速理解项目现状、架构逻辑以及代码使用规范。

你可以将以下内容分别保存为 markdown 文件（如 `PROJECT_STATUS.md` 和 `API_REFERENCE.md`），或者直接发布在团队的 Wiki/协作文档中。

---

# 文件一：项目进度与架构总览 (PROJECT_STATUS.md)

**项目名称**：东方地灵殿重置计划 (Touhou Project Remake)
**引擎版本**：Godot 4.x
**最后更新时间**：2023-XX-XX
**当前阶段**：核心架构原型验证完成 (Alpha - Phase 6)

## 1. 项目概况
本项目旨在基于 Godot 4 引擎构建一个高扩展性、高性能的东方Project风格弹幕射击游戏框架。当前已完成核心底层架构搭建，实现了数据驱动的实体生成系统、模块化行为控制系统以及基础的生存战斗循环。

## 2. 核心架构设计 (Architecture)

为了应对STG游戏海量的敌人类型和复杂的弹幕逻辑，本项目采用了 **"组合优于继承"** 和 **"数据驱动"** 的核心设计理念。

*   **实体系统 (Entity System)**：
    *   所有游戏对象（玩家、敌人、子弹）均继承自 `BaseEntity`。
    *   统一管理 状态机 (State Machine)、生命周期、自定义圆形碰撞检测。
*   **控制器系统 (Controller System)**：
    *   逻辑与数据分离。敌人的"移动方式"和"攻击方式"被剥离为独立的 `BaseController` 组件。
    *   支持运行时动态挂载/卸载控制器，实现复杂的阶段转换。
*   **配置驱动 (Config Driven)**：
    *   使用 Godot `Resource` (.tres) 定义敌人和弹幕数据。
    *   策划无需修改代码，通过编辑器面板即可组合出全新的敌人（如：调整HP、更换贴图、指定移动脚本）。
*   **性能优化 (Performance)**：
    *   **对象池 (Object Pooling)**：内置 `BulletPoolManager`，支持高并发弹幕场景（1000+ 同屏）的流畅运行。
    *   **自定义物理**：抛弃 Godot 原生 PhysicsServer，采用纯数学计算的圆形碰撞检测，大幅降低开销。

## 3. 已完成模块 (Completed Modules)

### A. 核心系统
*   [x] **全局状态管理 (`GameManager`)**：管理残机、炸弹、游戏状态流转。
*   [x] **弹幕对象池 (`BulletPoolManager`)**：支持自动扩容、自动回收、屏幕外剔除。
*   [x] **调试系统**：编辑器模式下可视化显示判定圈 (Hitbox)，杜绝判定欺诈。

### B. 玩家机体 (Player)
*   [x] **基础操作**：高速/低速移动切换、射击。
*   [x] **生存机制**：
    *   **无敌系统**：重生无敌、炸弹无敌。
    *   **决死结界 (Deathbomb)**：中弹后 0.2秒 内按雷可反杀。
    *   **炸弹系统 (Spell Card)**：主动释放炸弹、消耗逻辑。
    *   **死亡流程**：受击判定 -> 决死判定 -> 死亡特效 -> 移出场外 -> 复活。

### C. 敌人系统 (Enemy)
*   [x] **通用敌人基类**：支持血量管理、受击闪白反馈、自动销毁。
*   [x] **模块化组装**：通过 Config 资源自动加载贴图、数值和控制器。
*   [x] **AI 控制器**：
    *   `SineMoveController`：正弦波/蛇形移动逻辑。
    *   `AimedAttackController`：自机狙（瞄准玩家）发射逻辑。

## 4. 待开发计划 (Roadmap)

*   **Phase 7: UI 系统** (优先级: High)
    *   实现血条、残机数、炸弹数、得分的 HUD 显示。
*   **Phase 8: BOSS 战架构** (优先级: High)
    *   实现多阶段血条（非符/符卡切换）。
    *   实现 TimeLine 时间轴控制。
*   **Phase 9: 关卡流程**
    *   实现敌人编队生成器 (Spawner)。

---

# 文件二：核心 API 参考文档 (API_REFERENCE.md)

**适用对象**：Gameplay 程序员、技术策划
**说明**：编写新敌人、新弹幕或新玩法逻辑时，请严格查阅以下接口。

## 1. 全局单例 (Global Singletons)

### `GameManager`
管理游戏全局状态，任何脚本均可通过 `GameManager` 直接访问。

| 属性/方法 | 类型 | 说明 |
| :--- | :--- | :--- |
| `player` | `BasePlayer` | 当前玩家实体引用。可能为 `null` (如死亡重置期间)。 |
| `game_viewport_rect` | `Rect2` | 游戏实际可视区域，用于判断出屏销毁。 |
| `try_use_bomb()` | `bool` | **核心方法**。尝试消耗一颗炸弹。成功返回 `true`，失败(库存不足)返回 `false`。 |
| `on_player_died()` | `void` | 触发玩家死亡流程（扣残、重置炸弹）。通常由 `BasePlayer` 调用。 |

### `BulletPoolManager`
弹幕生成工厂。**禁止直接 `instantiate` 子弹场景，必须通过此管理器获取。**

| 方法 | 说明 |
| :--- | :--- |
| `get_bullet(scene: PackedScene)` | 从池中获取一个指定类型的弹幕实例。如果池为空会自动新建。返回值为 `BaseBullet`。 |

---

## 2. 实体基类 (BaseEntity)
路径: `res://scripts/base/BaseEntity.gd`
所有可交互物体（玩家、敌人、子弹）的父类。

### 属性
*   `hitbox_radius` (float): 圆形碰撞判定半径。
*   `is_alive` (bool): 实体是否存活。`false` 时停止逻辑更新。
*   `is_invincible` (bool): 无敌状态开关。为 `true` 时 `check_collision` 永远返回 `false`。
*   `current_state` (Enum): 当前状态 (`IDLE`, `ACTIVE`, `HIT`, `DESTROYED`)。

### 核心方法
*   `add_controller(key: String, controller: BaseController)`: 挂载一个行为控制器。
    *   *示例*: `add_controller("move", SineMoveController.new())`
*   `change_state(new_state)`: 安全切换状态，会触发 `state_changed` 信号。
*   `check_collision(other: BaseEntity) -> bool`: 检测与另一个实体的碰撞。

---

## 3. 玩家类 (BasePlayer)
路径: `res://scripts/base/BasePlayer.gd`
继承自: `BaseEntity`

### 核心方法
*   `hit()`: **外部调用接口**。通知玩家中弹。
    *   若处于无敌状态：忽略。
    *   若处于活跃状态：进入 `HIT` 状态（开启决死判定倒计时）。
*   `respawn()`: 复活玩家。重置位置至屏幕下方并开启短暂无敌。

### 配置参数
*   `invincibility_time`: 复活/炸弹后的无敌持续时间（秒）。
*   `deathbomb_window`: 决死结界有效窗口期（秒），默认 0.2s。

---

## 4. 敌人系统

### `BaseEnemy`
路径: `res://scripts/base/BaseEnemy.gd`

*   `max_hp` / `current_hp`: 血量管理。
*   `take_damage(amount: int)`: **外部调用接口**。扣除血量并触发受击闪白特效。当血量 <= 0 时触发死亡。
*   `config`: 引用 `EnemyConfig` 资源。

### `EnemyConfig` (Resource)
路径: `res://scripts/resources/EnemyConfig.gd`
**技术策划主要工作界面**。用于定义新敌人数据。

| 导出属性 | 说明 |
| :--- | :--- |
| `max_hp` | 最大生命值。 |
| `hitbox_radius` | 判定半径。 |
| `texture` | 敌人的 Sprite 贴图。 |
| `movement_script` | 移动逻辑脚本 (需继承自 `BaseController`)。 |
| `attack_script` | 攻击逻辑脚本 (需继承自 `BaseController`)。 |
| `bullet_scene` | 攻击时使用的子弹预制体。 |

---

## 5. 扩展指南：如何创建新敌人？

1.  **编写逻辑 (可选)**: 如果现有的移动/攻击方式不满足需求，请在 `res://scripts/controllers/` 下新建继承自 `BaseController` 的脚本。
    *   重写 `update_logic(delta)` 实现每一帧的行为。
2.  **创建配置**: 在 Godot 文件系统右键 -> 新建 `Resource` -> 搜索 `EnemyConfig`。
3.  **填写参数**: 填入血量、贴图，并将编写好的脚本拖入 `Movement Script` 或 `Attack Script` 栏。
4.  **实装**: 将 `TestEnemy.tscn` 拖入场景，并将步骤2创建的配置资源拖入其 `Config` 属性。

## 6. 输入映射 (Input Map)
项目依赖以下输入设置（Project Settings -> Input Map）：

*   `move_up`, `move_down`, `move_left`, `move_right`: 方向控制。
*   `focus`: 低速模式 (Shift)。
*   `shoot`: 射击 (Z)。
*   `bomb`: 释放炸弹/决死 (X)。