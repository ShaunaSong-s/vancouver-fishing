import os
from typing import Tuple

import google.generativeai as genai
from groq import AsyncGroq

from app.agent.knowledge_manager import KnowledgeManager
from app.agent.system_prompt import SYSTEM_PROMPT


class FishingAgent:
    """AI Agent for Vancouver fishing assistance with RAG support."""

    def __init__(self):
        self.provider = os.getenv("AI_PROVIDER", "gemini")
        self.knowledge_mgr = KnowledgeManager()
        self._setup_provider()

    def _setup_provider(self):
        if self.provider == "gemini":
            genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
            self.model = genai.GenerativeModel("gemini-1.5-flash")
        elif self.provider == "groq":
            self.groq_client = AsyncGroq(api_key=os.getenv("GROQ_API_KEY"))

    async def chat(self, message: str, history: list[dict]) -> Tuple[str, list[str]]:
        """Process a chat message with RAG context."""
        # 1. Retrieve relevant knowledge from vector DB
        context_docs = self.knowledge_mgr.search(message, top_k=5)
        sources = [doc["title"] for doc in context_docs]

        # 2. Build context-enhanced prompt
        context_text = "\n\n".join(
            [f"[{doc['category']}] {doc['title']}:\n{doc['content']}" for doc in context_docs]
        )

        enhanced_prompt = f"""{SYSTEM_PROMPT}

## 相关知识库内容:
{context_text if context_text else "（暂无相关知识库内容）"}

## 用户问题:
{message}
"""

        # 3. Call LLM
        if self.provider == "gemini":
            response = await self._call_gemini(enhanced_prompt, history)
        else:
            response = await self._call_groq(enhanced_prompt, history)

        return response, sources

    async def _call_gemini(self, prompt: str, history: list[dict]) -> str:
        """Call Google Gemini API."""
        # Convert history to Gemini format
        gemini_history = []
        for msg in history[-10:]:
            role = "user" if msg.get("role") == "user" else "model"
            gemini_history.append({"role": role, "parts": [msg["content"]]})

        chat = self.model.start_chat(history=gemini_history)
        response = chat.send_message(prompt)
        return response.text

    async def _call_groq(self, prompt: str, history: list[dict]) -> str:
        """Call Groq API (Llama 3)."""
        messages = [{"role": "system", "content": SYSTEM_PROMPT}]

        for msg in history[-10:]:
            messages.append({
                "role": msg.get("role", "user"),
                "content": msg["content"]
            })

        messages.append({"role": "user", "content": prompt})

        response = await self.groq_client.chat.completions.create(
            model="llama-3.1-70b-versatile",
            messages=messages,
            temperature=0.7,
            max_tokens=2000,
        )
        return response.choices[0].message.content
