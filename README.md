# 跨屏拖拽（飞屏）

> 车载多屏场景下，实现应用从一个屏幕拖拽到另一个屏幕  
> 技术方向：AMS / WMS / Input 三者联动

---

## 项目简介

在车载多屏环境（中控屏 + 副驾屏 + 后排屏）中，用户可以通过**长按 + 拖拽**手势，将应用从一个屏幕迁移到另一个屏幕。

**演示效果**：
```
[中控屏] 音乐 App          [副驾屏] 桌面
    ↓ 长按标题栏，进入拖拽
    ↓ 手指滑向副驾屏
[中控屏] 回到桌面          [副驾屏] 音乐 App
```

---

## 技术架构

```
┌─────────────────────────────────────────┐
│  Layer 1: SystemUI (Input)              │
│  ─────────────────────────────────────  │
│  • InputMonitor 监听系统级触摸事件        │
│  • 识别长按手势 (>1000ms)                │
│  • 进入拖拽模式，实时通知 WMS 位置         │
└──────────────┬──────────────────────────┘
               │ Binder
┌──────────────▼──────────────────────────┐
│  Layer 2: WMS (WindowManagerService)    │
│  ─────────────────────────────────────  │
│  • SurfaceControl 截图当前窗口            │
│  • 创建镜像窗口跟随手指                   │
│  • 松手时销毁镜像窗口                     │
└──────────────┬──────────────────────────┘
               │ 松手
┌──────────────▼──────────────────────────┐
│  Layer 3: AMS (ActivityManagerService)  │
│  ─────────────────────────────────────  │
│  • 判断目标 Display                      │
│  • 原屏幕 finish Activity               │
│  • 目标屏幕 setLaunchDisplayId 启动     │
└─────────────────────────────────────────┘
```

---

## 当前进度

| Week | 任务 | 状态 |
|---|---|---|
| Week 1 | SystemUI 中 InputMonitor 长按检测 | 🚧 进行中 |
| Week 2 | WMS SurfaceControl 镜像窗口 | ⏳ 待开始 |
| Week 3 | AMS 跨 Display 启动 | ⏳ 待开始 |

---

## 仓库结构

```
aosp-fly-screen/
├── docs/
│   └── 飞屏项目计划.md          # 完整技术方案
├── patches/                     # AOSP 源码修改 patch
│   ├── 001-input-monitor.patch
│   ├── 002-wms-drag-window.patch
│   └── 003-ams-cross-display.patch
├── scripts/
│   └── export-patches.sh        # 一键导出 patch
├── repos.txt                    # 修改过的 AOSP 仓库路径
└── README.md                    # 本文件
```

---

## 涉及 AOSP 仓库

```
frameworks/base/packages/SystemUI/
frameworks/base/services/core/java/com/android/server/wm/
frameworks/base/services/core/java/com/android/server/am/
```

---

## 快速开始

### 1. 克隆 AOSP 源码
```bash
cd ~/aosp
repo sync
repo start fly-screen --all
```

### 2. 应用 patch
```bash
cd frameworks/base
git apply ../../aosp-fly-screen/patches/001-input-monitor.patch
```

### 3. 编译
```bash
mmm frameworks/base/packages/SystemUI
```

---

## 面试话术

> "我做了一个车载跨屏拖拽（飞屏）功能。长按应用标题栏进入拖拽模式，SystemUI 通过 InputMonitor 监听系统级触摸事件，WMS 创建 SurfaceControl 镜像窗口跟随手指，松手时 AMS 通过 setLaunchDisplayId 在目标屏幕重新启动应用。
>
> Input 层我深入理解了 InputDispatcher 的事件分发机制——InputMonitor 的 server 端注册到 mMonitoringChannels，比焦点窗口优先收到事件。WMS 层负责窗口动画，AMS 层做跨屏启动。"

---

## 相关文档

- [飞屏项目计划](docs/飞屏项目计划.md) — 完整技术方案、Week 1-3 计划、深度知识点
