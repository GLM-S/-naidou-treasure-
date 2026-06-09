---
name: 保险培训工具构建
description: "为保险产品构建三页交互式培训工具（产品宣传/销售话术/理赔案例）。含数据提取、MP3音频生成、移动端SPA部署的完整工作流。"
---

# 保险培训交互工具构建

用于保险类产品的交互式培训页面制作。输出为三个独立 HTML 页面，每页 5-10 分钟学习时长，移动端优先，npx serve 部署。

## 三部曲架构

每套培训工具由三个独立页面组成，按交付顺序：

| 页面 | 文件名 | 内容 | 交互 |
|------|--------|------|------|
| 产品宣传 | cp.html | 产品概览/保额对比/保险责任/问答 | 场景选→按钮→反馈 |
| 销售话术 | kh.html | 话术学习/常见问题/实战模拟 | 气泡展示→折叠问答→多选练习 |
| 理赔案例 | al.html | 宣传视频/真实案例/看图识灾 | 图片展示→分类判断→互动闯关 |

## 工作流程

### 第一步：数据提取（先拿原件再干活）

从源文档提取结构化数据，存入 JSON：

```json
{
  "product_name": "宜家安馨—福",        // 全称，一个字不能省
  "product_display": "宜家安馨—福 · 燃气综合险",
  "company": "华泰财产保险有限公司",
  "plans": [
    { "name": "A款", "premium": 100, "total_coverage": 252, "items": {"房屋及附属设备":50, ...} }
  ],
  "coverage_sections": ["家财险责任","民用燃气责任","火灾爆炸定义","保障范围"],
  "qa": [{"q":"燃气险保什么？","a":"..."}]
}
```

- 源文档数据是第一位，不靠记忆，不猜
- 图片用途（投保单/保险责任/事故现场）必须确认，不瞎猜
- 产品名称用全称（如"宜家安馨—福A款"，不写"A款"）

### 第二步：结构化场景 → 生成 HTML

每个页面是场景式 SPA，结构如下：

```javascript
var S = {};
S.sceneId = {
  icon: '🔥',                    // 场景图标
  title: '场景标题',
  sceneMp3: 'audio/cp_scene.mp3', // 旁白 MP3（用 edge-tts 生成）
  story: '<p>HTML内容</p>',
  audio: '语音合成备选文本',       // speechSynthesis 备选
  picks: [
    {text:'按钮文案 →', next:'nextSceneId', type:''},
    {text:'按钮文案', next:'feedback', type:'good'|'wrong'}
  ]
};
```

#### 场景类型

1. **展示场景** — 展示内容（表格/图文/案例），`picks[].next` 指向下一场景
2. **选择题** — 2-4 个选项：选对绿色标记 → 跳下一题，选错红色标记 → 可重选
3. **折叠问答** — (kh页面) 点击问题展开答案，常用于 FAQ
4. **反馈场景** — 展示正确/错误反馈，点击继续

### 第三步：edge-tts 生成 MP3（关键）

```bash
# 所有需要朗读的文本必须用 edge-tts 生成 MP3，不用 speechSynthesis
edge-tts --voice zh-CN-XiaoxiaoNeural --rate 0% --text "文本" --write-media audio/cp_scene.mp3
```

- speechSynthesis 在微信/Safari 不可靠，**只在**不需要语音的场景保留为备选
- MP3 文件命名：`audio/{pageID}_{sceneID}.mp3`（如 `audio/cp_start.mp3`）
- 音频用小体积（edge-tts 默认 48kbps 已够用）

### 第四步：包含交互检查

1. 每页末尾放 3-6 道选择题，不可跳过
2. 先教后考：内容展示完再出题，不考没教过的
3. 选错可重选，选对进入下一题或结束
4. 答错显示正确答案+简短解释

### 第五步：部署

```bash
# 服务器 IP: 101.34.82.153
# 所有文件放在 /root/.openclaw/workspace/
# 音频放在 /root/.openclaw/workspace/audio/
cd /root/.openclaw/workspace
npx serve -l 8080 .
```

## HTML 模板结构（所有三页共用）

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no">
  <title>华泰 · 产品名 · 页面类型</title>
  <style>
    /* 全局样式：浅色木纹背景/暖色卡片/圆角/阴影/入场动画 */
    *{margin:0;padding:0;box-sizing:border-box;}
    body{background:#f5f0e8;color:#2a221a;font-family:...;min-height:100vh;}
    #app{max-width:680px;width:100%;margin:0 auto;background:#fff;border-radius:16px;padding:24px 20px;}
    @keyframes fi{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:translateY(0)}}
    .fade{animation:fi 0.35s ease;}
    /* 按钮/表格/卡片等通用组件 */
  </style>
  <!-- 预加载首个场景的 MP3 -->
  <link rel="preload" href="audio/page_scene.mp3" as="audio">
</head>
<body>
  <div id="app">
    <!-- topbar: 品牌名 + BGM按钮 + 音频按钮 -->
    <!-- content: 动态渲染区 -->
    <!-- footer: 品牌信息 -->
  </div>
  <script>
    /* 引擎函数：go(id)、playMp3(src)、toggleAudio()、toggleBGM() */
    /* 场景数据：var S = {}; */
  </script>
</body>
</html>
```

## 规则和禁忌

### 必须做的
- 先拿源文档提取数据，不靠记忆
- 产品名用全称
- 每页先展示再出题（先教后考）
- 所有朗读文本用 edge-tts MP3，不用 speechSynthesis
- 每页一个焦点，不做大而全
- 图片用实拍照片/真实案例截图，不用网图

### 禁止的
- 一个页面包含所有内容（要做三个独立页面）
- 没教的内容放到考题里
- 用 speechSynthesis 朗读长文本（跳字跳行）
- 凭记忆写产品数据（必须对照原件）

## 部署检查清单

- [ ] 三个页面都部署完毕
- [ ] 所有 MP3 音频存在且路径正确
- [ ] 点击音频按钮能正常播放/暂停
- [ ] BGM 音乐能正常播放/切换
- [ ] 选择题交互（选对/选错/重选）工作正常
- [ ] 移动端视口适配（防止文字太小）
- [ ] 真实图片已替换占位图
- [ ] 页面间跳转链接工作正常
- [ ] 用 npx serve 在 8080 端口运行
