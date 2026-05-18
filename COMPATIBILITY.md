# Compatibility Matrix

> Prometheus-0 runtime dependency versions and tested configurations.

## Runtime Platform

| Component | Tested Version | Notes |
|-----------|---------------|-------|
| **Cherry Studio** | (current stable) | Skills registered via `Data/Skills/<name>/SKILL.md` |
| **DeepSeek API** | deepseek-chat / deepseek-reasoner | Dual-router via deepseek-router |
| **OS** | Windows 10/11 (x64) | PowerShell 5.1+ required for scripts |
| **Shell** | PowerShell 5.1 | All automation scripts (`scripts/*.ps1`) target PowerShell |
| **Git** | 2.x | Required for version control; must be in PATH |

## Skill Format Compatibility

| Feature | Schema Version | Min Cherry Studio | Notes |
|---------|---------------|-------------------|-------|
| YAML frontmatter (`name`, `priority`, `description`, `trigger`) | v1.0 | (current) | All 8 skills conform to `schema/skill-schema.json` |
| `priority` field | v1.0 | (current) | Used for skill routing precedence |
| `trigger` comma-separated keywords | v1.0 | (current) | Case-insensitive matching |

## API Compatibility

| Component | Endpoint / Model | Authentication | Notes |
|-----------|-----------------|----------------|-------|
| DeepSeek Chat | `api.deepseek.com/v1/chat/completions` | API Key (`sk-...`) | Primary runtime |
| DeepSeek Reasoner | `api.deepseek.com/v1/chat/completions` | API Key (`sk-...`) | Deep reasoning mode |
| deepseek-router | `.claude/skills/deepseek-dual-router` | (inherited) | Routes between chat/reasoner based on task complexity |

## Network Dependencies (DAILY-BRIEF module)

| Source | URL | Reachability | Fallback |
|--------|-----|-------------|----------|
| NYT Tech RSS | `rss.nytimes.com/services/xml/rss/nyt/Technology.xml` | Requires VPN (CN) | Tier 2 fallback |
| 36kr | `36kr.com` | Direct (CN) | Tier 1 primary |
| Hacker News | `news.ycombinator.com` | Requires VPN (CN) | Tier 3 fallback |

## Breaking Changes

| Version | Date | Change | Migration |
|---------|------|--------|-----------|
| v0.1.3 | 2026-05-07 | Log paths Chinese → English; unified Trigger Log | Rename directories, regenerate logs |
| v0.1.2 | 2026-05-06 | Initial registration | N/A |

## Deprecation Timeline

No deprecated features at this time (v0.1.7).

## Upgrade Guide

### From v0.1.2 to v0.1.3
1. Rename any Chinese-named log directories to English (`logs/`, `daily-archive/`)
2. Run `scripts/validate.ps1` to verify all 8 skills conform to v0.2 schema
3. Run `scripts/deploy.ps1` to update Cherry Studio skills
4. Restart Cherry Studio
5. Send `日报` to verify DAILY-BRIEF works with new archive paths
