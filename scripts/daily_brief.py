import requests
import json
from datetime import datetime
import os
import xml.etree.ElementTree as ET

def fetch_github_trending():
    """获取 GitHub Trending 项目"""
    url = "https://github-trending-api.vercel.app/repositories"
    try:
        resp = requests.get(url, timeout=15)
        return resp.json()[:10]
    except Exception as e:
        print(f"⚠️ GitHub Trending 获取失败: {e}")
        return []

def fetch_tech_news():
    """获取科技新闻（36氪 RSS）"""
    url = "https://rsshub.app/36kr/news"
    try:
        resp = requests.get(url, timeout=15)
        root = ET.fromstring(resp.text)
        items = []
        for item in root.findall(".//item")[:8]:
            title = item.find("title").text if item.find("title") is not None else ""
            link = item.find("link").text if item.find("link") is not None else ""
            items.append({"title": title, "link": link})
        return items
    except Exception as e:
        print(f"⚠️ 科技新闻获取失败: {e}")
        return []

def generate_brief():
    date_str = datetime.now().strftime("%Y-%m-%d")
    
    print("🚀 开始采集数据...")
    
    github_projects = fetch_github_trending()
    tech_news = fetch_tech_news()
    
    md = f"""# 📊 每日科技简报 - {date_str}

> 自动采集自 GitHub Trending + 36氪科技新闻

---

## 🚀 GitHub 热门项目

"""
    for i, repo in enumerate(github_projects[:5], 1):
        name = repo.get('name', '')
        url = repo.get('url', '#')
        desc = repo.get('description', '')[:100]
        stars = repo.get('stars', 0)
        forks = repo.get('forks', 0)
        language = repo.get('language', '')
        md += f"""
### {i}. [{name}]({url})
> {desc}
⭐ {stars} | 🍴 {forks} | 🏷️ {language}

"""

    md += f"""
## 📰 科技头条

"""
    for news in tech_news[:5]:
        title = news.get('title', '')
        link = news.get('link', '#')
        md += f"- [{title}]({link})\n"

    md += f"""

---

*📅 生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*
*🤖 由 GitHub Actions 自动生成*
"""
    
    os.makedirs("briefs", exist_ok=True)
    with open(f"briefs/{date_str}.md", "w", encoding="utf-8") as f:
        f.write(md)
    
    print(f"✅ 简报已生成: briefs/{date_str}.md")
    return md

if __name__ == "__main__":
    generate_brief()