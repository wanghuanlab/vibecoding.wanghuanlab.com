# VibeCoding 实战培训 · Web PPT

面向部门内部开发工程师的 AI Coding / VibeCoding 培训演示文稿。

在线预览：[vibecoding.wanghuanlab.com](https://vibecoding.wanghuanlab.com/)

## 项目说明

这是一个基于 Reveal.js 的单页 Web PPT。核心内容在 `index.html`，无需构建步骤；插画资源位于 `assets/`。

- 复古奶油纸张底色、扁平矢量插画与统一黑色描边
- 顶部轻量全景插画，不占用正文主体空间
- 目录页、章节过渡页、键盘导航、演讲者备注与页码
- 适合 16:9 投影和浏览器全屏演示

## 培训结构

1. VibeCoding 是什么
2. VibeCoding 发展历程与行业大势
   - 2021–2026 技术演进：Copilot、ChatGPT、Cursor、Agent、MCP 与 Agent Skills
   - 不同口径的 AI 开发工具采用快照；每项数据均附来源和适用范围
3. 环境安装与基础配置
4. 概念演进与核心实用技巧
5. 心得体会与避坑指南
6. 项目实战演示
7. 风格统一与规范化
8. AI 引入导致的流程坍缩
9. AI 安全性与隐私保护
10. 总结与展望

## 本地预览

直接双击 `index.html` 即可浏览。为避免浏览器对本地资源的限制，推荐通过静态服务器预览：

```bash
python3 -m http.server 8000
```

然后访问 <http://127.0.0.1:8000/>。

## 演示操作

| 操作 | 说明 |
| --- | --- |
| `←` / `→` | 切换横向章节或下一项内容 |
| `↑` / `↓` | 切换纵向子页面 |
| `F` | 全屏 |
| `S` | 演讲者视图 |
| `Esc` / `O` | 幻灯片总览 |
| `Space` | 下一步 |

## 数据口径

行业数据页刻意不把不同研究拼为一条“同比趋势线”。页面分别标注了指标含义、样本和来源：

- GitHub 2023 / 2024 Developer Survey
- [CNNIC 第 57 次《中国互联网络发展状况统计报告》](https://www.cnnic.cn/n4/2026/0205/c326-11542.html)
- [中国信通院《AI4SE 行业现状调查报告（2026）》](https://hulianhutongshequ.cn/upload/tank/report/2026/202604/1/41c4dd2e0f59482a80e7f4625e53f565.pdf)
- JetBrains AI Pulse（2026）

## 部署

生产站点目录为 `/opt/1panel/www/sites/vibecoding.wanghuanlab.com/index/`。具备服务器权限时，可按以下方式更新：

```bash
ssh root@vibecoding.wanghuanlab.com 'mkdir -p /opt/1panel/www/sites/vibecoding.wanghuanlab.com/index/assets'
scp index.html root@vibecoding.wanghuanlab.com:/opt/1panel/www/sites/vibecoding.wanghuanlab.com/index/
scp assets/vibecoding-panorama.png root@vibecoding.wanghuanlab.com:/opt/1panel/www/sites/vibecoding.wanghuanlab.com/index/assets/
```

部署后访问线上地址，并确认 `/assets/vibecoding-panorama.png` 返回成功。

## 版权

© 2026 王欢｜部门研发团队。
