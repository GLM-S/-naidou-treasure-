# headroom — Token 省钱神器

**链接**: https://github.com/chopratejas/headroom
**星标**: GitHub 趋势榜
**方向**: AI Agent 基础设施

## 干嘛的
压缩工具输出/日志/RAG 块/文件，省 60-95% Token，答案质量不变。

## 接入方式
- Library、Proxy、MCP Server、Agent Wrap（claude/codex/cursor）
- 可逆压缩（CCR），需要时按需检索，<1ms 恢复
- 跨 Agent 共享记忆
- 从失败会话学教训，自动更新 CLAUDE.md

## 已安装
- MCP Server: `/home/ubuntu/.openclaw/workspace/treasure/scripts/headroom-mcp.sh`
- 需测试验证
