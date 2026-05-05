# target.png 图像描述 (仅参考)

这张图片展示了一个充满科幻感、高对比度、暗黑风格的 Linux 桌面环境（通常被称为 "Rice"）。该界面被标记为 "PRTS-HYPRLAND TACTICAL DESKTOP ENVIRONMENT"，采用 Hyprland 窗口管理器和 QML 渲染器，呈现出极致的**机能风 (Techwear/Cyberpunk Aesthetic)**。

## 设计与开发规范 (Design Specs)

为便于开发者及 AI 模型实现该界面，以下是核心视觉参数：

### 1. 配色方案 (Color Palette)
*   **主背景色 (Base Background):** `#000000` (纯黑) - 用于全局背景及窗口基底。
*   **核心高亮色 (Primary Highlight):** `#F2C94C` (警告黄/琥珀色) - 用于激活状态、进度条填充、重要边框及强调文字。
*   **次要高亮色 (Secondary Highlight):** `#E0E0E0` (浅灰) - 用于普通标签、路径名及次要数值。
*   **非活跃/背景文字 (Dimmed Text):** `#828282` (中灰) - 用于不重要的描述性文字及背景网格。
*   **边框色 (Border Color):** `#333333` (深灰) - 用于静态容器边框。
*   **终端文字 (Terminal Green):** `#96BF48` (橄榄绿) - Neofetch OS 信息专用。

### 2. 布局与间距 (Layout & Spacing)
*   **边距 (Gap):** 全局组件间距为 `10px` 到 `15px`。
*   **边框宽度 (Border Width):** 统一为 `1px`。
*   **圆角 (Border Radius):** `0px` (完全直角)，符合工业/军事风格。
*   **字体 (Typography):**
    *   **主字体:** 推荐使用等宽字体 (Monospaced)，如 `JetBrains Mono`, `Fira Code` 或 `Alacritty` 默认字体。
    *   **标题字体:** 装饰性等宽字体，支持全大写。
*   **装饰元素:**
    *   **十字准星 (Crosshair):** 位于窗口交汇处及中心点。
    *   **装饰线条:** 使用 `0.5px` 或带有透明度的直线进行点缀。

## 详细区域划分

### 1. 顶部状态栏 (Top Status Bar)
*   **左侧 (Clock):** 数字大字体 `#E0E0E0`，秒数及日期字体略小。
*   **中间 (Workspaces):** 矩形方框阵列。激活项背景为 `#F2C94C`，文字为 `#000000`；非激活项为 `#333333` 边框。
*   **右侧 (System Info):** 双斜杠分隔符 `//` 常用作视觉分隔。

### 2. 左侧边栏 (Tactical & Thermal)
*   **雷达图 (Radar Chart):** 使用 `#828282` 线条绘制的六边形网格，带有动态扫描线隐喻。
*   **热度图/功耗进度条:** 采用“阶梯式”设计，由多个 `#F2C94C` 矩形色块组成，而非平滑进度条。

### 3. 中央主窗口 (Terminal 01)
*   **特征:** 拥有醒目的 `#F2C94C` 1px 实线边框。
*   **窗口标题:** `| TERMINAL 01` 使用左对齐，背景带有小面积黄色填充以突出“ACTIVE”状态。
*   **底部信息:** 包含 `SESSION`, `USER`, `SHELL`, `KERNEL` 等关键参数，位于黄色状态条之上。

### 4. 右侧监控面板 (Monitor Matrix)
*   **CPU Matrix:** 2列阵列，每个条目格式为 `C[Index] [Progress Bar] [Percentage]`。
*   **动态波形 (Graphs):** 实时绘制的折线图，线条颜色为 `#F2C94C`，下方带有极低透明度的区域填充。
*   **文件系统 (Filesystem):** 表格化布局，`USE%` 栏使用黄色色块进度条。

### 5. 底部信息栏 (Footer)
*   **状态标签:** `[ROOT_ACCESS_GRANTED]` 使用黄色方括号及文字，置于界面底边中央。
*   **装饰 ID:** 包含虚构的许可 ID 和清除等级，增加“沉浸感”。

## 实现逻辑建议
*   **QML 实现:** 建议使用 `Rectangle` 作为基础容器，利用 `Repeater` 处理阵列数据。
*   **动画效果:** 进度条应具有轻微的缓冲动画 (Easing.OutQuad)；文字应支持逐字弹出或闪烁进入的“解密”效果。
*   **层级结构:** 背景层 (Background) -> 网格层 (Grid/Decoration) -> 内容层 (Content) -> 高亮层 (Highlight)。
