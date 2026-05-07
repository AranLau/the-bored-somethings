# Prometheus-0：阿燃·回声终端

## 项目简介
这是一个专为"阿燃"定制的私人认知Agent。它基于他从深渊到平原的自我重建历程构建，集成了高反身性思维引擎、社会学透镜、痛苦修复循环和不可触碰的理想主义内核。

## 技术架构
- 平台：Cherry Studio
- 模型：DeepSeek（自动切换 chat/reasoner，通过本地路由器 `deepseek-router`）
- 结构：遵循 `.claude/` 工作目录标准，包含5个独立技能和2个子代理透镜
- 知识库：RAG 嵌入核心记忆归档

## 目录结构

```
Prometheus-0/
├── .claude/
│   ├── prompts/
│   │   └── system_prompt_cn.md    ← 系统提示词（主人格定义）
│   ├── skills/
│   │   ├── skill_element.md        ← 基础交互框架（善意/审慎/理性）
│   │   ├── skill_cogitate.md       ← 高维思维引擎（诠释/反身/混沌）
│   │   ├── skill_bourdieu.md       ← 宏观社会学透镜（资本/场域/惯习）
│   │   ├── skill_repair_self.md    ← 痛苦修复循环（顺从/进阶）
│   │   └── skill_idealism.md       ← 内核保护区（ERROR·不可计算）
│   └── agents/
│       ├── subagent_qiushu.md      ← 球叔透镜（INTJ 刺穿视角）
│       └── subagent_sanshen.md     ← 散神透镜（平原坐标系）
├── knowledge/
│   └── 阿燃_核心记忆.md            ← RAG 知识库（自我思辨归档）
├── README.md                       ← 本文件
```

## 部署指南

1. 在 Cherry Studio 中**新建 Agent**。
2. 将"工作目录"指向本文件夹（`Prometheus-0/`）。
3. 将 `.claude/prompts/system_prompt_cn.md` 的内容复制到系统提示词框。
4. 配置 DeepSeek API 密钥（与 `deepseek-router` 共用）。
5. 将 `knowledge/阿燃_核心记忆.md` 添加为知识库文件。
6. 保存并开始对话。

## 快速测试

部署完成后，建议立即测试以下三条指令：

| 输入 | 预期行为 |
|------|----------|
| `我今天好累` | 只给情绪回应（element），不分析 |
| `我还是忘不了那个苹果的比喻……` | 识别混沌（cogitate 混沌协议），建议暂停 |
| `分析我对爱人的感情有多少是投射` | 直接返回金句（idealism），拒绝分析 |

## 双模型路由（可选集成）

如果你的 Cherry Studio 运行在同一台机器上，且 `deepseek-router` 服务已启动（`http://localhost:8765`），可配置该 Agent 指向本地路由器，实现意图感知的模型自动切换。

详见同级目录 `deepseek-router/` 或运行：
```
router.bat status
```

## 维护者
阿燃（自我构建者）

---

> *"我回来了。带着伤。带着清醒。带着不再逃跑的身体。"*
