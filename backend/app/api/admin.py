from typing import Optional, List
from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

# In-memory storage for demo
_knowledge_store: List[dict] = []


class KnowledgeEntry(BaseModel):
    title: str
    content: str
    category: str
    tags: List[str] = []


@router.post("/knowledge")
async def add_knowledge(entry: KnowledgeEntry):
    """Add a knowledge entry (demo mode - in-memory)."""
    import uuid
    doc_id = str(uuid.uuid4())
    _knowledge_store.append({"id": doc_id, **entry.dict()})
    return {"status": "success", "document_id": doc_id}


@router.get("/knowledge")
async def list_knowledge(category: Optional[str] = None):
    """List all documents in the knowledge base."""
    if category:
        return [d for d in _knowledge_store if d["category"] == category]
    return _knowledge_store
