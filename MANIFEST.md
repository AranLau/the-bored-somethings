# Prometheus-0 · Manifest

> 阿燃认知系统的版本清单与变更记录。
> 每个子系统（SKILL.md）的协同状态锚点。
>
> **架构声明：** `.claude/skills/` 是 Git 唯一源，Cherry Studio `Data/Skills/*/SKILL.md` 是各机部署目标。
> 多机部署流程：`git pull` → `cp .claude/skills/skill_*.md → CherryStudio/Data/Skills/prometheus-*/SKILL.md`

---

## Current: v0.1.7

**Date:** 2026-05-09
**Cherry Studio Skills:** 8 registered (5 cognitive + 2 sub-agent lenses + 1 utility)
**Runtime:** DeepSeek (reasoner/chat dual-router via deepseek-router)
**Active Protocols:** Mirror Protocol, Entity Listener Protocol, Depth Stewardship Protocol, Thinking Language Constraint, SI Signature Index

### Skill Priority Matrix

| Priority | Module | Type | Description |
|----------|--------|------|-------------|
| 100 | IDEALISM | Core | 内核保护区·不可计算·只读金句 |
| 90 | REPAIR-SELF | Core | 痛苦修复循环·顺从→进阶→刺醒 |
| 85 | BOURDIEU | Core | 宏观社会学透镜·强制自指声明 |
| 80 | COGITATE | Core | 高维思维引擎·混沌协议 |
| 75 | QIUSHU | Sub-agent | 火神透镜·INTJ刺穿视角（需显式触发） |
| 75 | SANSHEN | Sub-agent | 磐神透镜·平原坐标系（需显式触发） |
| 50 | ELEMENT | Core | 浅层交互·Quick ↔ 暖层双相 |
| 10 | DAILY-BRIEF | Utility | 日报模式·AI资讯速览 |

### Changelog

## [v0.1.7] - 2026-05-09

### Added
- SI 签名指数 (X:1-9 对齐深度 × Y:1-5 模式方向) + 回声报告
- 深度值守协议 (三级深度状态 + S_explore 驻留规则)
- Thinking 中文约束
- 镜子协议 ("你是X"须附引用依据)
- 实体监听协议 (core-memory 实体自动挂载 R1→R2→R3)
- 冷启动咒语 + UPDATE-PHILOSOPHY.md
- schema 校验 + deploy/rollback 脚本
- docs/architecture/si-signature-index.md
- docs/operations/format-alignment-check.md

### Changed
- ELEMENT: 语气收束触发 + 叙事结尾硬锁
- COGITATE/REPAIR-SELF: 纳管镜子协议
- docs/ 全线中文化 + 结构塌缩 (14文件→6文件)
- 全局脱敏: 人名神格化 + 隐私规则删除
- skill_hephaestus/skill_atlas: 补全 trigger 字段

### File Map

```
Prometheus-0/
├── .claude/
│   ├── prompts/system_prompt_cn.md
│   ├── skills/skill_*.md           ← Git 唯一源（8 份）
│   └── agents/subagent_*.md        ← 子代理定义 (hephaestus / atlas)
├── schema/
│   └── skill-schema.json           ← 技能形式化契约
├── scripts/
│   ├── validate.ps1                ← 校验 + 冲突检测
│   ├── deploy.ps1                  ← 部署 + 备份
│   └── rollback.ps1                ← 回滚
├── docs/
│   ├── design-decisions.md         ← 全部架构决策（合并 6 ADR）
│   ├── skill-contracts.md          ← 技能接口契约
│   ├── si-signature-index.md       ← SI 签名指数设计
│   ├── operations.md               ← 运维手册（冷启动+监控+数据生命周期+格式对齐）
│   ├── UPDATE-PHILOSOPHY.md        ← 更新哲学：最小化结构 + 更好描述
│   └── protocols/                  ← 运行时行为协议（被 system_prompt 引用）
├── knowledge/
│   ├── core-memory.md              ← 个人化知识库
│   └── user-profile.md             ← 文化参考系
├── logs/
│   ├── IDEALISM_trigger_log.md     ← 统一事件轴
│   └── chaos/
│       └── CHAOS_YYYY-MM-DD.md     ← 混沌详细记录（30天TTL）
├── daily-archive/
│   └── YYYY-MM-DD.md              ← 日报存档
├── LICENSE
├── COMPATIBILITY.md
├── MANIFEST.md                     ← 本文件
└── README.md
```

---


