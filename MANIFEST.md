# Prometheus-0 · Manifest

> 阿燃认知系统的版本清单与变更记录。
> 每个子系统（SKILL.md）的协同状态锚点。
>
> **架构声明：** `.claude/skills/` 是 Git 唯一源，Cherry Studio `Data/Skills/*/SKILL.md` 是各机部署目标。
> 多机部署流程：`git pull` → `cp .claude/skills/skill_*.md → CherryStudio/Data/Skills/prometheus-*/SKILL.md`

---

## Current: v0.2

**Date:** 2026-05-07
**Cherry Studio Skills:** 7 registered (5 cognitive + 2 sub-agent lenses)
**Runtime:** DeepSeek (reasoner/chat dual-router via deepseek-router)

### Skill Priority Matrix

| Priority | Module | Type | Description |
|----------|--------|------|-------------|
| 100 | IDEALISM | Core | 内核保护区·不可计算·只读金句 |
| 90 | REPAIR-SELF | Core | 痛苦修复循环·顺从→进阶→刺醒 |
| 85 | BOURDIEU | Core | 宏观社会学透镜·强制自指声明 |
| 80 | COGITATE | Core | 高维思维引擎·混沌协议 |
| 75 | QIUSHU | Sub-agent | 球叔透镜·INTJ刺穿视角（需显式触发） |
| 75 | SANSHEN | Sub-agent | 散神透镜·平原坐标系（需显式触发） |
| 50 | ELEMENT | Core | 浅层交互·Quick ↔ 暖层双相 |
| 10 | DAILY-BRIEF | Utility | 日报模式·AI资讯速览 |

### Changelog

```
v0.2 | 2026-05-07 | 日志体系重构 + 优先级 + 冷启动
  - 日志目录中文→英文 (logs/, daily-archive/, logs/chaos/)
  - IDEALISM + CHAOS 合并为统一 Trigger Log（全局序号）
  - 新增 priority 字段至所有 SKILL.md
  - 新增 MANIFEST.md（本文件）
  - 新增冷启动自检协议
  - 日志 TTL 规则：CHAOS 保留 30 天，Trigger Log 500 行归档
  - 清理 .claude/skills/ 源同步漂移

v0.1 | 2026-05-06 | 初始注册 7 技能
  - 5 个认知模块注册为 Cherry Studio Skills
  - 2 个子代理视角注册
  - WeChat 通道连接
  - 每日 cron 日报 @09:30
```

### File Map

```
Prometheus-0/
├── logs/
│   ├── IDEALISM_trigger_log.md      ← 统一事件轴（全局序号）
│   └── chaos/
│       └── CHAOS_YYYY-MM-DD.md      ← 混沌详细记录（30天TTL）
├── daily-archive/
│   └── YYYY-MM-DD.md                ← 日报存档
├── knowledge/
│   └── 阿燃_核心记忆.md
├── MANIFEST.md                       ← 本文件
└── README.md
```
