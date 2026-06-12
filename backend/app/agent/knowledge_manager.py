import os
import uuid
from typing import Optional

import chromadb
from chromadb.config import Settings


class KnowledgeManager:
    """Manages the RAG knowledge base using ChromaDB vector database.
    
    Professional fishermen can add knowledge through:
    1. Admin API endpoints
    2. Uploading documents
    3. Adding Q&A pairs
    """

    def __init__(self):
        # Use persistent storage
        persist_dir = os.path.join(os.path.dirname(__file__), "../../data/chromadb")
        self.client = chromadb.Client(Settings(
            chroma_db_impl="duckdb+parquet",
            persist_directory=persist_dir,
            anonymized_telemetry=False,
        ))
        self.collection = self.client.get_or_create_collection(
            name="fishing_knowledge",
            metadata={"description": "Vancouver fishing professional knowledge base"}
        )
        
        # Load default knowledge if empty
        if self.collection.count() == 0:
            self._load_default_knowledge()

    def add_document(self, title: str, content: str, category: str, tags: list[str]) -> str:
        """Add a document to the knowledge base."""
        doc_id = str(uuid.uuid4())
        self.collection.add(
            documents=[content],
            metadatas=[{
                "title": title,
                "category": category,
                "tags": ",".join(tags),
            }],
            ids=[doc_id],
        )
        return doc_id

    def search(self, query: str, top_k: int = 5) -> list[dict]:
        """Search the knowledge base for relevant content."""
        if self.collection.count() == 0:
            return []
        
        results = self.collection.query(
            query_texts=[query],
            n_results=min(top_k, self.collection.count()),
        )
        
        docs = []
        if results and results["documents"]:
            for i, doc in enumerate(results["documents"][0]):
                metadata = results["metadatas"][0][i] if results["metadatas"] else {}
                docs.append({
                    "content": doc,
                    "title": metadata.get("title", ""),
                    "category": metadata.get("category", ""),
                    "distance": results["distances"][0][i] if results["distances"] else 0,
                })
        return docs

    def list_documents(self, category: Optional[str] = None) -> list[dict]:
        """List all documents, optionally filtered by category."""
        result = self.collection.get()
        docs = []
        for i, doc_id in enumerate(result["ids"]):
            metadata = result["metadatas"][i] if result["metadatas"] else {}
            if category and metadata.get("category") != category:
                continue
            docs.append({
                "id": doc_id,
                "title": metadata.get("title", ""),
                "category": metadata.get("category", ""),
                "tags": metadata.get("tags", "").split(","),
            })
        return docs

    def delete_document(self, doc_id: str):
        """Delete a document from the knowledge base."""
        self.collection.delete(ids=[doc_id])

    def _load_default_knowledge(self):
        """Load default fishing knowledge for Georgia Strait."""
        default_docs = [
            {
                "title": "Georgia Strait Chinook Salmon钓法",
                "category": "fishing_tips",
                "content": """Chinook Salmon (大鳞三文鱼) 钓法指南：
                - 最佳深度：40-120英尺，使用downrigger
                - 常用饵料：cut plug herring, whole herring, hoochie + flasher
                - 热门颜色：绿色、蓝色、紫色flasher
                - 最佳时间：清晨日出前后，潮汐转换期间
                - 速度：1.5-2.5 knots trolling speed
                - Area 28 Bowen Island 附近全年有Winter Chinook
                - 夏季7-8月Point Atkinson和Sand Heads有大量Chinook"""
            },
            {
                "title": "Dungeness Crab抓蟹指南",
                "category": "fishing_tips",
                "content": """Dungeness Crab (珍宝蟹) 抓蟹指南：
                - 最佳深度：30-80英尺，泥沙底质
                - 蟹笼饵料：鸡腿、鱼头、猫粮
                - 最佳时间：退潮时下笼，等待2-4小时
                - 最小尺寸：165mm (carapace width)，只能保留公蟹
                - 每人限额：4只/天
                - 热门区域：Howe Sound, Indian Arm, Burrard Inlet
                - 注意：部分区域有seasonal closure，查看DFO公告"""
            },
            {
                "title": "Spot Prawn抓虾指南",
                "category": "fishing_tips",
                "content": """Spot Prawn (斑点虾) 抓虾指南：
                - 季节：通常5月中到6月中（每年DFO公布具体日期）
                - 深度：200-500英尺
                - 虾笼饵料：commercial pellets + fish oil最佳
                - 每人限额：125只/天 (trap limit varies)
                - 热门区域：Indian Arm, Howe Sound deep areas
                - 注意事项：需要prawn trap licence
                - 技巧：下笼后等待至少2小时，清晨下笼效果最好"""
            },
            {
                "title": "DFO禁渔区规则",
                "category": "regulations",
                "content": """DFO Pacific Region 重要规则：
                - Rockfish Conservation Areas (RCA): 禁止使用底层钓具
                - Sponge Reef closures: Howe Sound部分区域
                - Seasonal closures: 每年不同，必须查看最新DFO公告
                - 鱼证要求：Tidal Waters Sport Fishing Licence (必须)
                - 钓三文鱼额外需要：Salmon Conservation Stamp
                - 每日限额因区域和季节不同
                - Area 28/29 常见限额：Chinook 2/day, Halibut 1/day
                - 所有岩鱼（Rockfish）多数区域限额 1/day 或完全禁止
                - 出海前务必查看：https://www.pac.dfo-mpo.gc.ca/fm-gp/rec/index-eng.html"""
            },
            {
                "title": "温哥华出海安全须知",
                "category": "safety",
                "content": """出海安全须知：
                - 查看天气：VHF Channel 21B (Continuous Marine Broadcast)
                - 风速>20节：小船(< 20ft)不建议出海
                - 风速>30节：所有休闲船只不建议出海
                - 必备安全设备：救生衣、哨子、手电、VHF电台、信号弹
                - Georgia Strait海流可达3-4节，注意漂流
                - Howe Sound有强烈的outflow wind（冬季）
                - 始终告知家人出海计划和预计返回时间
                - 手机信号：大部分Georgia Strait有覆盖，但Indian Arm深处可能无信号"""
            },
            {
                "title": "温哥华船坞和码头信息",
                "category": "locations",
                "content": """主要船坞/码头：
                - Steveston (列治文)：最大公共码头，靠近Fraser River口，方便前往Sand Heads和Gulf Islands
                - Horseshoe Bay (西温)：靠近Howe Sound，方便前往Bowen Island
                - Deep Cove (北温)：进入Indian Arm的门户，适合抓虾和蟹
                - Belcarra (高贵林港)：另一个进入Indian Arm的选择
                - Tsawwassen (三角洲)：南部出发点，靠近美国边境
                - White Rock (白石)：适合岸钓和小船出海
                - 油价参考：marina diesel约$2.0-2.5/L"""
            },
            {
                "title": "渔具推荐清单",
                "category": "gear",
                "content": """温哥华海钓基本装备：
                【三文鱼Trolling】
                - Rod: 10.5ft medium-heavy downrigger rod
                - Reel: Level wind reel (如 Okuma Convector)
                - Line: 20-30lb monofilament or braided
                - Flasher: Gibbs Delta, Silver Horde (绿色/蓝色)
                - Lure: Hoochie, Spoon, Cut plug herring
                - Downrigger: Scotty或Cannon电动downrigger
                
                【Halibut底钓】
                - Rod: 6ft heavy action
                - Reel: Large conventional (如 Penn Squall)
                - Line: 80-100lb braided
                - Weight: 16-32oz lead
                - Bait: Herring, octopus, salmon belly
                
                【螃蟹/虾】
                - Crab trap: 折叠式不锈钢蟹笼
                - Prawn trap: 商用虾笼 + float + 500ft rope
                - Bait: 鸡腿（蟹）、pellets+fish oil（虾）"""
            },
            {
                "title": "温哥华鱼货加工餐厅",
                "category": "restaurants",
                "content": """鱼货加工/海鲜餐厅推荐：
                - Steveston Fish Market (列治文): 可代加工刚钓的鱼，sashimi切片
                - The Fish Counter (Main St): 专业切片和烟熏
                - Fisherman's Terrace (列治文): 中式海鲜加工，可以带自己的海鲜
                - Sea Harbour (列治文): 代加工螃蟹和鱼
                - Neptune Seafood Restaurant: 代煮螃蟹
                - 部分日本料理店: 可代做sashimi（需提前沟通）
                
                自己加工建议：
                - 三文鱼：刺身、烤、烟熏、腌制
                - 比目鱼：刺身、清蒸、油炸
                - 螃蟹：清蒸、姜葱炒、避风塘
                - 斑点虾：白灼、刺身、盐焗"""
            },
        ]

        for doc in default_docs:
            self.add_document(
                title=doc["title"],
                content=doc["content"],
                category=doc["category"],
                tags=[],
            )
