# 🏴‍☠️ 奶豆的宝藏库 — 完整系统备份

> 静渊的全部AI基础设施，一键备份在此。
> 位置：`/root/.openclaw/workspace/treasure/`

## 目录结构

```
treasure/
├── TREASURY.md              ← 寻宝索引
├── openclaw.json             ← OpenClaw完整配置
├── MEMORY.md                 ← 长期记忆
│
├── skills-backup/            ← 所有33个技能
│   ├── 三道壕沟法/           ← 静渊自创方法论
│   ├── 静渊内容管线/         ← 内容生产工作流
│   ├── 保险培训工具构建/     ← 燃气险培训
│   ├── pm-*/                 ← 产品管理技能集
│   ├── memory-hygiene/       ← 记忆管理
│   └── ...
│
├── memory-backup/            ← 每日日记（memory/）
├── scripts-backup/           ← 工具脚本（TTS生成等）
│
├── agent-reach/              ← 🌟 已装·互联网搜索工具
├── headroom/                 ← 🌟 已装·Token压缩利器
├── open-notebook/            ← 📌 开源NotebookLM
├── mempalace/                ← 📌 开源AI记忆系统
├── copilotkit/               ← 📌 AI前端框架
└── paddleocr/                ← 📌 OCR识别
```

## 已安装的工具

| 工具 | 安装方式 | 用途 |
|------|----------|------|
| Ollama + nomic-embed-text | snap | 本地向量模型 |
| memory-lancedb-pro | git clone + npm | 长期记忆插件 |
| headroom | pip | 省Token压缩 |
| Agent-Reach | pip | 多平台搜索 |
| PowerMem | pip（留用） | 备用记忆系统 |

## 关键节点

- **服务器**: 101.34.82.153（腾讯云轻量）
- **静态文件**: /root/.openclaw/workspace/
- **nginx**: 80/8080端口
- **COS桶**: naidou-audio99-1434426321（广州）
- **隧道**: Cloudflare Tunnel ID: 1e8da7f9-01e6-46cc-813a-effb46b815e9
