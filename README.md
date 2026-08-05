# VibeCoding 实战培训 PPT

> **面向部门内部开发工程师：从零基础安装到进阶实战，系统掌握 AI Coding / VibeCoding 智能开发工作流。**

🌐 **线上直接预览地址**：[https://vibecoding.wanghuanlab.com/](https://vibecoding.wanghuanlab.com/)

---

## 🖥️ 项目简介

本项目是一套完整的基于 **Reveal.js** 构建的纯前端 Web 版演示文稿（单 HTML 文件），专为团队内部 AI Coding / VibeCoding 技术培训设计。

无需任何本地构建或 Node.js 环境，所有的依赖库（Reveal.js、highlight.js、Font Awesome 6、Google Fonts）均通过 CDN 实时加载，直接在浏览器中打开 `index.html` 即可使用。

---

## 🎨 视觉设计与技术亮点

- **主色调与氛围**：深色科技感配色（`#0D1117` 主色、`#58A6FF` 科技蓝、`#3FB950` 逻辑绿、`#BC8CFF` 霓虹紫）。
- **毛玻璃 UI 卡片**：基于 CSS `backdrop-filter: blur(12px)` 实现的高质感浮动卡片。
- **动态粒子背景**：原生 HTML5 Canvas 实时计算粒子连线与渐变动效。
- **自定义组件**：纯 CSS 实现的 **演进时间轴**、**AI 代码占比柱状图**、**VS 对比盒** 及 **快捷符号表**。
- **全屏投影适配**：原生支持 1920×1080 投影分辨率及响应式缩放。

---

## 📐 10 大章节目录结构

1. **第 0 章：封面页**
   - 培训主题、副标题、讲师信息（王欢 | 2026年8月）、动态粒子背景。
2. **第 1 章：VibeCoding 是什么？**
   - 传统编码 vs VibeCoding 左右分栏对比、核心理念与流程图、主流工具全景图（CLI / GUI / IDE）、一句话定义。
3. **第 2 章：VibeCoding 发展历程**
   - 2021~2026 演进时间轴（Copilot -> ChatGPT -> Cursor -> Agent -> MCP 标准化）、GitHub AI 辅助代码占比趋势柱状图。
4. **第 3 章：VibeCoding 环境安装与配置**
   - 工具类型表格与黄金公式、Claude Code CLI 全局安装、Claude Code + DeepSeek 模型配置示例、扩展插件清单、标准 VibeCoding 工程目录。
5. **第 4 章：概念发展与实用技巧**
   - 从 Prompt 到 Loop：AI 开发能力进阶四部曲（Prompt -> Context -> Harness -> Loop Engineering）、Prompt 黄金公式与好坏对比、上下文与 Rules 文件配置、常用 Bash/Slash 命令、权限控制及 Token 防爆指南。
6. **第 5 章：心得体会与避坑指南**
   - 10 大实战黄金法则、3 个真实踩坑案例（幻觉包、上下文污染、一步到位越界）。
7. **第 6 章：项目实战演示**
   - 构建内部 API 管理平台 5 步拆解法、架构设计与模块 Prompt 示例、开发耗时提效对比数据。
8. **第 7 章：风格统一与规范化 (USP)**
   - 统一风格提示词体系（USP）、团队规范配置文件（CLAUDE.md）、团队 Prompt 库建设策略。（参考：[http://usp.wanghuanlab.com/](http://usp.wanghuanlab.com/)）
9. **第 8 章：AI 引入导致的流程坍缩**
   - 研发流程坍缩定义、UI2Code / PRD2Code / Bug2Fix 典型场景、机遇与挑战对比表。
10. **第 9 章：AI 安全性与隐私保护**
    - 企业级使用红线（严禁上传 vs 推荐做法）、主流工具安全性与数据流对比、最小权限原则。
11. **第 10 章：总结与展望**
    - 行动清单 3 件事、Q&A 互动环节、感谢与结束页。

---

## ⌨️ 快捷键操作指南

| 快捷键 | 操作说明 |
| :--- | :--- |
| **`←` / `→` (左右方向键)** | 切换横向主章节 (Previous / Next Chapter) |
| **`↑` / `↓` (上下方向键)** | 切换纵向子页面 (Previous / Next Sub-slide) |
| **`F` 键** | 切换全屏显示模式 (Toggle Fullscreen) |
| **`S` 键** | 打开演讲者视图视窗 (Open Speaker Notes Window) |
| **`ESC` / `O` 键** | 开启 / 退出幻灯片全景网格预览 (Slide Overview Grid) |
| **`Space` (空格键)** | 智能播放下一页 (Smart Next Slide) |
| **`Alt` + 鼠标左键** | 局部放大 Inspect 关注的页面元素 (Zoom into Element) |

---

## 🚀 快速使用

### 1. 本地直接打开
直接通过浏览器打开目录下的 `index.html` 即可：
```bash
open index.html
```

### 2. 本地静态服务器启动（可选）
推荐使用 `serve` 或 Python 内置 HTTP 服务：
```bash
python3 -m http.server 8000
# 访问 http://localhost:8000
```

---

## 📄 授权许可与版权信息

© 2026 王欢 | 部门研发团队. 遵循 MIT 开源许可协议。
