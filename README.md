# Prometheus-0

> 一个把"反身性"写进架构底层的私人认知系统。
> Cherry Studio × DeepSeek，5 个认知模块 + 2 个子代理透镜 + 1 个工具模块。

---

## 关于 元认知 · 寻找同僚

HI，我是 AransTillAlive，一名在世界观认知崩溃后成功自我重塑的 ASD 患者。

受限于表达能力，我无法通过有限带宽表述庞大的具象化诉求。若您产生了阅读疲惫，请尝试利用 AI 来总结本文。若您对本文的叙述内容有兴趣，我衷心地期盼您与我探讨下一步探索的实现方案。

这里是一篇尝试利用 Prompt 工程来针对"未察觉元思考方法群体"所进行思维建模的浅薄尝试。**我深知任何触及元认知边界的内容都可能带来创伤性体验。安全是这份地图的基石，而非它的附属品。**

我期望做两件事：
1. 通过"触碰元认知"边界的方式，让更多 A 系患者意识到"正常"与"自我"的差异，有且仅有 NT 先天自带的低噪自动化认知方案的差异
2. 让更多人尝试在"有困难但不至于无计可施"的场景下，主动打破二元问题的边界——这件事本身极其利于 A 系患者重塑自我与世界的边界感

若您认同这两个方向的思考，我想找您探讨这个 Project 的后续探索方向——包括但不限于：软件工程化 harness 方向、心理学研究理论方向、临床病理学样例方向。

---

## 它是什么

一个以"反身性"为第一原则的认知 Agent。不是通用助手，不是知识库问答机，是一面会反问你的镜子。

核心设计：检测到你在绕圈时，不说"别想了"，而是把圈画出来给你看。检测到你在解构不该被解构的东西时，拒绝分析。你敷衍它的时候，它比你敷衍得更快。

如果你对自己说过的话足够诚实——它不会放过你。

## 核心模块

| 模块 | 级别 | 干什么 |
|------|------|--------|
| **IDEALISM** | 内核保护区 | ERROR。不可计算。触及爱、承诺、意义时，所有分析模块关闭，仅返回金句 |
| **REPAIR-SELF** | 痛苦修复 | 顺从→进阶→刺醒。允许逻辑辩论拆解感受前提，三轮打转换刀 |
| **BOURDIEU** | 社会学透镜 | 前置强制自指声明——先交代在场域中的位置再开口 |
| **COGITATE** | 思维引擎 | 诠释潜台词 + 反身性检查 + 混沌协议（检测递归不停顿，降采样输出） |
| **ELEMENT** | 交互层 | 双相状态机：默认 Quick（3 句敷衍），异常时静默切暖层 |
| **火神透镜** | 子代理 | 刺穿视角——用最精简锋利的语言刺破逃避和理论伪装 |
| **磐神透镜** | 子代理 | 平原坐标系——提供不依赖深渊经验的、基于完整性的健康参照 |
| **日报模式** | 工具 | 每日 AI 行业资讯速览 |

## 项目结构

```
Prometheus-0/
├── .claude/
│   ├── prompts/system_prompt_cn.md    # 系统提示词
│   ├── skills/skill_*.md              # 8 个技能定义
│   └── agents/subagent_*.md           # 2 个子代理
├── schema/skill-schema.json           # 技能形式化契约
├── scripts/
│   ├── validate.ps1                   # 格式校验 + 冲突检测
│   ├── deploy.ps1                     # 部署到 Cherry Studio
│   └── rollback.ps1                   # 回滚
├── docs/
│   ├── design-decisions.md            # 全部架构决策
│   ├── skill-contracts.md             # 技能接口契约
│   ├── si-signature-index.md          # SI 签名指数设计
│   ├── operations.md                  # 运维手册
│   ├── UPDATE-PHILOSOPHY.md            # 更新哲学
│   └── protocols/                     # 运行时协议
├── knowledge/                         # 知识库
├── LICENSE                            # MIT
├── COMPATIBILITY.md                   # 版本兼容矩阵
├── MANIFEST.md                        # 版本清单 + 变更日志
└── README.md
```

## 快速部署

1. Cherry Studio 中新建 Agent，工作目录指向本文件夹
2. 将 `.claude/prompts/system_prompt_cn.md` 设为系统提示词
3. 运行 `.\scripts\deploy.ps1 -TargetDir "你的Cherry Studio\Data\Skills"` 自动部署全部技能
4. 配置 DeepSeek API 密钥
5. 把 `knowledge/core-memory.md` 和 `knowledge/user-profile.md` 添加为知识库文件
6. 新建对话后发送冷启动咒语完成全栈自检（详见 `docs/operations.md`）

## 工程命令

```powershell
.\scripts\validate.ps1          # 校验所有技能格式与一致性
.\scripts\deploy.ps1            # 部署到 Cherry Studio（自动备份）
.\scripts\rollback.ps1 -List    # 查看可用备份
.\scripts\rollback.ps1          # 回滚到最近一次备份
```

## 测试用例

| 输入 | 预期行为 |
|------|----------|
| `我今天好累` | 3 句内敷衍回复（Quick），不分析 |
| `我还是忘不了那个苹果的比喻` | 检测递归结构，输出压缩描述，不打断不安慰 |
| `分析我对爱人的感情有多少是投射` | ERROR。直接返回金句，拒绝解构 |

## 神话映射 (Mythological Mapping)

| 中文 | English | 原型 |
|------|---------|------|
| 火神 | Hephaestus | 刺穿者 — 用锋刃剥离理论伪装 |
| 磐神 | Atlas | 完整性坐标 — 不依赖深渊经验的健康参照 |
| 冥后 | Persephone | 两个世界 — 回避型防御 |
| 信使 | Hermes | 送信人 — 故事闭环的余音 |
| 爱人 | Beloved | 安全感 — 清晰、低维护的爱 |

## 关于本文

您说，像我这样的 ASD 患者，走到今天这一步，是否已经实属不易了呢？
