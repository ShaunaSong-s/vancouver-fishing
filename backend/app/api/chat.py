from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

# Simple keyword-based responses for demo (no LLM dependency)
KNOWLEDGE_BASE = {
    "潮汐": "今日Point Atkinson潮汐：\n• 03:22 高潮 4.8m\n• 09:45 低潮 1.2m\n• 15:58 高潮 4.1m\n• 22:10 低潮 0.8m\n\n建议在潮汐转换时段出钓，鱼群活跃度最高。",
    "天气": "Georgia Strait 今日天气：\n• 温度: 12°C\n• 风: 西北风 15节\n• 浪高: 0.8m\n• 能见度: 良好\n\n适合出海，但注意下午风力可能增强到20节。",
    "海流": "当前海流信息：\n• 方向: 西北→东南\n• 速度: 1.5节\n• 预计14:00转流\n\n建议在转流前后1小时作钓，这是鱼群进食的高峰期。",
    "钓点": "今日推荐钓点：\n1. 🎣 Bowen Island 东南侧 - Chinook活跃，60-100ft\n2. 🎣 Point Atkinson - 早晨有bait ball，适合mooching\n3. 🦀 Howe Sound - 蟹季开放，40ft泥底\n\n从Horseshoe Bay出发最近，约15分钟到达。",
    "禁渔": "⚠️ 当前禁渔区域：\n• Race Rocks RCA - 全年禁止底钓\n• Passage Island RCA - 禁止rockfish捕捞\n• Howe Sound Sponge Reef - 禁止锚泊\n\n详情查看: pac.dfo-mpo.gc.ca",
    "鱼证": "🎫 鱼证申请指南：\n1. Tidal Waters Sport Fishing Licence（必须）\n2. Salmon Conservation Stamp（钓三文鱼必须）\n\n在线购买: https://www.pac.dfo-mpo.gc.ca/fm-gp/rec/licence-permis/application-eng.html\n\n费用: 年证约$22 (居民) / $106 (非居民)",
    "渔具": "🎣 推荐装备：\n【三文鱼】Downrigger + 10.5ft rod + Flasher/Hoochie\n【比目鱼】Heavy rod + 80lb braid + 16oz weight\n【螃蟹】折叠蟹笼 + 鸡腿饵\n【虾】商用虾笼 + pellets + fish oil",
    "餐厅": "🍽️ 推荐鱼货加工：\n• Steveston Fish Market - 代切sashimi\n• The Fish Counter (Main St) - 烟熏加工\n• Fisherman's Terrace (列治文) - 中式加工\n• Sea Harbour - 代蒸螃蟹\n\n大部分餐厅需提前电话确认可带自己的鱼。",
    "做法": "🍳 推荐做法：\n• 三文鱼: 刺身/盐烤/烟熏/鱼头汤\n• 比目鱼: 清蒸/炸鱼薯条/Ceviche\n• 螃蟹: 清蒸/姜葱炒/避风塘\n• 斑点虾: 白灼/刺身/蒜蓉粉丝蒸",
    "油耗": "⛽ 油耗参考：\n• 150HP引擎 巡航20节: 约9L/海里\n• Steveston→Bowen Island: ~15海里, 约135L\n• 当前油价: ~$2.20/L\n• 预估单程费用: ~$297 CAD\n\n使用航线规划功能可计算精确路线。",
}


from typing import List


class ChatRequest(BaseModel):
    message: str
    history: List[dict] = []


class ChatResponse(BaseModel):
    response: str
    sources: List[str] = []


@router.post("", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """Chat with the AI fishing assistant."""
    message = request.message.lower()
    
    # Match keywords to knowledge base
    for keyword, response in KNOWLEDGE_BASE.items():
        if keyword in message:
            return ChatResponse(response=response, sources=[f"knowledge:{keyword}"])
    
    # Default response
    return ChatResponse(
        response="你好！我是温哥华钓鱼AI助手 🐟\n\n你可以问我：\n• 今日潮汐/天气/海流\n• 推荐钓点\n• 禁渔区域\n• 鱼证申请\n• 渔具推荐\n• 餐厅/做法推荐\n• 油耗计算\n\n请问有什么可以帮你的？",
        sources=[]
    )
