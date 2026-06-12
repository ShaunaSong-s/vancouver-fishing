# 知识库训练指南 (Knowledge Base Training Guide)

## 如何让专业人士训练AI

### 方法1: 通过Admin API添加知识

```bash
# 添加单条知识
curl -X POST http://localhost:8000/api/v1/admin/knowledge \
  -H "Content-Type: application/json" \
  -d '{
    "title": "冬季Chinook钓法秘诀",
    "content": "冬季Chinook通常在80-150ft深度...",
    "category": "fishing_tips",
    "tags": ["chinook", "winter", "technique"]
  }'
```

### 方法2: 上传文档文件

```bash
curl -X POST http://localhost:8000/api/v1/admin/knowledge/upload \
  -F "file=@my_fishing_notes.txt" \
  -F "category=fishing_tips"
```

### 方法3: 放置文件到 knowledge_base 目录

将 `.txt` 或 `.md` 文件放到 `backend/knowledge_base/` 目录下，重启服务后自动加载。

## 知识分类 (Categories)

| Category | 说明 | 示例 |
|----------|------|------|
| `fishing_tips` | 钓鱼技巧 | 某种鱼的钓法、深度、时间 |
| `regulations` | DFO法规 | 禁渔区、限额、季节关闭 |
| `gear` | 装备推荐 | 渔具、鱼饵、设备 |
| `locations` | 地点信息 | 码头、钓点详情 |
| `safety` | 安全信息 | 天气、急救、设备要求 |
| `recipes` | 做法推荐 | 各种鱼的烹饪方法 |
| `restaurants` | 餐厅信息 | 加工店、餐厅推荐 |
| `seasons` | 季节信息 | 各季节什么鱼可以钓 |

## 训练内容格式建议

### 好的训练内容示例：
```
标题: Area 28 冬季Chinook钓法
内容:
- 最佳区域：Bowen Island southeast side, Point Atkinson 到 Lighthouse Park
- 深度：80-150英尺
- 时间：涨潮前2小时最佳
- 饵料：Green/glow hoochie with 11" flasher
- trolling速度：1.8-2.2 knots
- 技巧：跟着bait ball走，用fishfinder找鱼群
- 注意：冬季风大，注意安全
```

### 不好的训练内容：
```
"冬天可以钓鱼" — 太模糊，没有具体信息
```

## 知识库如何工作 (RAG Architecture)

1. 专业人士添加知识 → 文本被转化为向量存入ChromaDB
2. 用户提问 → 问题被转化为向量 → 在知识库中搜索最相关的内容
3. 相关内容 + 用户问题 → 发送给LLM生成回答
4. LLM基于专业知识生成准确、实用的建议

```
用户: "今天从Steveston出发钓三文鱼去哪里好？"
    ↓
RAG搜索 → 找到: Steveston码头信息 + Chinook钓法 + 当前季节建议
    ↓
LLM综合生成: "从Steveston出发建议去Sand Heads区域，目前是Chinook季节..."
```
