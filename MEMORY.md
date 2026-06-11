# MEMORY.md - 长期记忆

> 最后更新：2026-06-10

## 关于静渊

- **真名**：songchao（也叫宋超），自称"静渊"
- **昵称**：奶豆 / naidou
- **称呼我**：奶豆
- **时区**：Asia/Shanghai（UTC+8）
- **作息**：6:30 起床 | 23:00 睡觉 | 19:00 左右吃饭
- **地点**：山东
- **语言**：只懂中文，英文内容需要翻译
- **自我定位**：**创客/产品人**——使用 AI 工具创造改变世界的人
- **核心信条**：简单极致化，最简单的就是最实用的

## 三条产品线

**🥇 燃气险培训工具（现金牛，优先做）**
- 已有第一单 300 元
- 保险培训市场百亿级，目前没有第三方交互培训产品
- 三个独立页面：cp（产品介绍）、kh（销售话术）、al（理赔案例）
- 音频走 COS（naidou-audio99-1434426321 桶）
- COS 100G 资源包已购买（有效期至 2027-06-06）
- 带宽瓶颈已解决（HTML 走服务器，音频走 COS）
- 服务器 pm2 守护 serve 进程，端口 8080

**📖 书游时代（孵化中）**
- 框架已验证：圯桥拾履（张良故事互动体验）
- V2 版（带属性面板+卷轴UI）位于 `yiqiao-v2.html`

**🏛️ shiji-kb 知识工程（远期武器库）**
- 鲍捷的项目，57万字《史记》→ 知识图谱，全部用 Skill 不用代码

## 服务器部署

- **IP**：101.34.82.153（腾讯云）
- **系统**：Linux，Ubuntu
- **当前服务**：
  - OpenClaw 已运行（WeCom 通道）
  - 静态页面：pm2 守护 serve，端口 8080
  - Meilisearch：Docker 运行，端口 7700
  - COS 音频：naidou-audio99-1434426321
- **数据盘**：/dev/vdb（20G，ext4）
- **Cloudflare Tunnel** 已装（山东运营商拦截）
- **磁盘**：系统盘 40G

## 模型配置

- **默认模型**：deepseek/deepseek-v4-flash（已切回，Agnes 不推荐使用）
- **Agnes 副引擎**：sk-22m…XCAy（免费，但经常 503 不可用，已弃用）
- **智谱 GLM**：58e4b6…aEIO（备用）

## API Keys

- **DeepSeek API**：sk-4c7…343e
- **COS 密钥**：AKIDoY…4fGv / c2Lq8DHF5oOxPgnleNwKafZJwOfkdJn4
- **COS 音频桶**：naidou-audio99-1434426321（广州）
- **COS 冷备桶**：naidou-1434426321（广州）
- **Cos 配置**：~/.cos.conf

## 企业微信

- **Bot ID**：aib_5qXXR5a-TkbsUH1HvEUXzn-Wh5wuI1Y
- **WebSocket 模式**：已配置
- **文件传输问题**：企业微信发文件收回来是 COS 错误 JSON（965B），传不了源码
  - **解决方案**：必须直接粘贴代码文本到对话框，不能发文件

## 宝藏库（双远程备份）

- **origin (GitHub)**：git@github.com:GLM-S/-naidou-treasure-.git
- **gitcode (GitCode)**：git@gitcode.com:gcw_e7bz63KA/naidou-treasure.git
- **SSH 公钥**：ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHUR92AmxG2W+cRyF94yO+TkF9mXrUgC3c1HHavGqTdF
- **恢复脚本**：workspace/scripts/restore.sh

## 经验教训

1. **用户重复=关键信息** — 说超过2遍的内容一定重要
2. **函数签名改一处查全局** — 改参数签名后 grep 所有调用点
3. **补丁阈值=3** — 同文件超3次补丁，暂停评估是否重写
4. **不改 JS 用 sed** — 用 edit 工具
5. **镜像修复** — 修A页面bug顺手检查B/C页面
6. **交付前全流程跑一遍** — 修完走完整用户路径
7. **先教后考** — 交互问答放在内容介绍之后
8. **每页只做一件事** — 不混内容
9. **命名全称** — 正式产品名一个字不能省
10. **先拿原件再干活** — 数据以原件为准
11. **不在会话里说"我记住了"** — 立刻写文件
12. **音频原则** — 任何需要朗读的场景，用 edge-tts 生成 MP3，不要用 speechSynthesis（不可靠）
13. **企业微信发文件收不回来** — 必须直接粘贴源码文本
14. **Cos 密钥含省略号** — 可能引发编码问题，需确认

## 已安装技能

- 三道壕沟法（自定义）
- 静渊内容管线（自定义）
- 保险培训工具构建（自定义）
- html-ppt、edge-tts、tencent-cos-skill、tencentcloud-lighthouse-skill
- agent-browser、tavily 搜索、github

## 正在折腾/未完成

- ✅ COS 音频迁移完成
- ✅ GitHub 宝藏库双备份完成
- ✅ pm2 守护 serve 进程
- ❌ Dify 未装成（换 MaxKB）
- ❌ HyperFrames 未装成（网络问题）
- ⏳ 域名备案中（naidouai.cn）
- ⚠️ 2026-06-10 晚：默认模型改回 DeepSeek V4 Flash（Agnes 503 导致企微断连），企微已修复
