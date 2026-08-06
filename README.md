# VibeCoding 实战总结 · Web PPT

面向部门内部交流的 AI Coding / VibeCoding 实战经验总结与研发范式演进演示文稿。

在线预览：[vibecoding.wanghuanlab.com](https://vibecoding.wanghuanlab.com/)

## 项目说明

这是一个基于 Reveal.js 的单页 Web PPT。核心内容位于 `index.html`，无需任何构建编译步骤；图片与图形资源位于 `assets/`。

- **视觉风格**：复古奶油纸张底色、高对比度硬朗黑描边卡片与现代矢量图标
- **交互体验**：集成图片全屏点击放大（Lightbox Modal）、全景插画、键盘导航与演讲者视图
- **设计适配**：适合 16:9 投影、全屏演讲及移动端高保真浏览

## 课程/演讲 8 大章节结构

1. **01. VibeCoding 是什么**
   - 概念定义与传统编程范式的深刻对比
2. **02. 发展历程与行业大势**
   - 2021–2026 技术演进（Copilot、ChatGPT、Cursor、Agent、MCP 与 Agent Skills）
   - AI 开发工具行业快照（CNNIC、信通院 AI4SE 报告、JetBrains AI Pulse 数据）
3. **03. 环境安装与基础配置**
   - IDE (Cursor/Claude Code) 选型、推荐插件与系统环境初始化
4. **04. 概念演进与实用方法**
   - Prompt 黄金公式、Meta-Prompting 提示词自动重构、上下文管理、Token 指南与 10 大 VibeCoding 黄金法则
5. **05. 项目实战经验**
   - 标杆案例：长江电力新一代生产经营管理系统（https://prototype.wanghuanlab.com 多人协作构建 600+ 页面超大型管理系统）
   - 产品组/非技术团队 Git 3-Skill 规范化工作流（可全屏放大架构图）
   - 异构团队 500+ 页面风格统一：[UI Style Pilot (USP)](https://github.com/wanghuanlab/ui-style-pilot) 治理体系 (MD + SKILLs)
   - 项目级 AI 生成规范：`AGENTS.md` / `CLAUDE.md` 实践拆解（Skill 路由、`Ds*` 组件基线、8 大红线禁令与业务守恒）
   - 真实研发质效量化对比：传统 650 人天 → VibeCoding 176 人天（周期压缩 73%，3.7 倍级生产力跃迁；88.3% 业务页面公共组件覆盖率；从需求直接生成代码级页面范式收益）
6. **06. VibeCoding 未来展望**
   - AI 普及 2 大壁垒（硬件算力成本与顶尖模型闭源受限）与历史必然规律（类似电话/PC 诞生）
   - 模型迭代加速与研发流程步骤被动坍缩（7步 -> 5步）、Daily 10k-Star 生态碰撞与“祝碳基生物好运”
7. **07. AI 安全性与隐私保护**
   - 绝对红线（4 大严禁上传暴露敏感内容）与“外包同事”安全心态
   - 开发者实战规范：硬编码零容忍、`.claudeignore` 屏蔽、Git 扫描门禁、数据 Mock 脱敏、AI 推荐包供应链审计 (`npm audit`)
   - 团队合规选型（Cursor Business, Copilot Ent, 本地 Ollama+DeepSeek）与 Code Review Checklist
8. **08. 总结与问答**
   - VibeCoding 时代工程师 3 大核心竞争力（架构与分解力、审查与品味、上下文与规则工程）与现场 Q&A

## 本地预览

直接双击 `index.html` 即可浏览。为避免浏览器对本地资源的限制，推荐通过静态服务器预览：

```bash
python3 -m http.server 8000
```

然后访问 <http://127.0.0.1:8000/>。

## 演示操作

| 操作 | 说明 |
| --- | --- |
| `←` / `→` | 切换横向章节 |
| `↑` / `↓` | 切换纵向子页面 |
| `F` | 全屏模式 |
| `S` | 演讲者视图 (Speaker View) |
| `Esc` / `O` | 幻灯片平铺总览 |
| `Space` | 下一步 |
| **点击图片** | 任意流程图/架构图全屏放大查看高清细节 |

## 数据口径与来源

行业数据页标注了严格的指标含义、样本和数据来源：

- GitHub 2023 / 2024 Developer Survey
- [CNNIC 第 57 次《中国互联网络发展状况统计报告》](https://www.cnnic.cn/n4/2026/0205/c326-11542.html)
- [中国信通院《AI4SE 行业现状调查报告（2026）》](https://hulianhutongshequ.cn/upload/tank/report/2026/202604/1/41c4dd2e0f59482a80e7f4625e53f565.pdf)
- JetBrains AI Pulse（2026）

## 部署

生产站点目录为 `/opt/1panel/www/sites/vibecoding.wanghuanlab.com/index/`。具备服务器权限时，可按以下方式更新：

```bash
ssh root@vibecoding.wanghuanlab.com 'mkdir -p /opt/1panel/www/sites/vibecoding.wanghuanlab.com/index/assets'
scp index.html root@vibecoding.wanghuanlab.com:/opt/1panel/www/sites/vibecoding.wanghuanlab.com/index/
scp assets/* root@vibecoding.wanghuanlab.com:/opt/1panel/www/sites/vibecoding.wanghuanlab.com/index/assets/
```

部署后访问线上地址，确认静态资源加载成功。

## 版权

© 2026 王欢｜部门交流团队。
