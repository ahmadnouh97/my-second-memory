import json
from datetime import datetime
from typing import AsyncIterator

from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse
from langchain_core.messages import AIMessage, HumanMessage, SystemMessage
from langchain_core.tools import tool
from langchain_groq import ChatGroq
from langgraph.prebuilt import create_react_agent
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.database import get_db
from app.repositories.item_repository import ItemRepository
from app.schemas.item import ItemResponse
from app.services.search_service import hybrid_search

router = APIRouter()


class ChatMessage(BaseModel):
    role: str  # "user" | "assistant"
    content: str


class ChatRequest(BaseModel):
    message: str
    history: list[ChatMessage] = []


SYSTEM_PROMPT = """You are a personal knowledge assistant with access to the user's saved content library.

You can search and retrieve items from their library to answer questions.
When you find relevant items, return them in a structured format so the user can click through to them.

Always be helpful and concise. If asked about specific content (videos, articles, etc.), use the tools
to search the library first before answering.

When listing items, always include the item references using the format:
ITEMS_JSON: [{"id": "...", "title": "...", "url": "...", "thumbnail_url": "...", "tags": [...], "content_type": "..."}]

Put this JSON block at the END of your response after the text explanation."""


def make_tools(db: AsyncSession):
    @tool
    async def search_items_tool(query: str, content_type: str | None = None) -> str:
        """Search the user's saved content library using semantic + keyword search.
        Use this when the user asks about specific topics, titles, or content.
        Args:
            query: Search query (keywords or natural language)
            content_type: Optional filter - one of: youtube, instagram, article, link
        """
        repo = ItemRepository(db)
        results = await hybrid_search(repo, query, content_type=content_type, limit=5)
        if not results:
            return "No items found matching that query."
        items_data = [ItemResponse.model_validate(i).model_dump(mode="json") for i in results]
        return json.dumps(items_data)

    @tool
    async def list_items_tool(
        tags: list[str] | None = None,
        content_type: str | None = None,
        date_from: str | None = None,
        date_to: str | None = None,
        limit: int = 10,
    ) -> str:
        """List items from the user's library with optional filtering.
        Use this for queries like "show me my latest saves", "what did I save recently?",
        or "show me all YouTube videos".
        Args:
            tags: Filter by these tags (e.g. ["productivity", "python"])
            content_type: Filter by type: youtube, instagram, article, link
            date_from: ISO date string to filter from (e.g. "2025-01-01")
            date_to: ISO date string to filter to (e.g. "2025-12-31")
            limit: Number of items to return (max 20)
        """
        repo = ItemRepository(db)
        parsed_from = datetime.fromisoformat(date_from) if date_from else None
        parsed_to = datetime.fromisoformat(date_to) if date_to else None
        items, total = await repo.list_filtered(
            tags=tags,
            content_type=content_type,
            date_from=parsed_from,
            date_to=parsed_to,
            page=1,
            limit=min(limit, 20),
        )
        if not items:
            return "No items found matching those filters."
        items_data = [ItemResponse.model_validate(i).model_dump(mode="json") for i in items]
        return json.dumps({"total": total, "items": items_data})

    return [search_items_tool, list_items_tool]


async def _stream_agent_response(
    message: str, history: list[ChatMessage], db: AsyncSession
) -> AsyncIterator[str]:
    llm = ChatGroq(
        model="qwen/qwen3-32b",
        api_key=settings.groq_api_key,
        temperature=0,
        streaming=True,
    )
    tools = make_tools(db)
    agent = create_react_agent(llm, tools)

    messages = [SystemMessage(content=SYSTEM_PROMPT)]
    for msg in history[-10:]:  # Keep last 10 messages for context
        if msg.role == "user":
            messages.append(HumanMessage(content=msg.content))
        else:
            messages.append(AIMessage(content=msg.content))
    messages.append(HumanMessage(content=message))

    full_text = ""
    async for chunk in agent.astream({"messages": messages}, stream_mode="values"):
        last_message = chunk["messages"][-1]
        if isinstance(last_message, AIMessage) and last_message.content:
            # Only stream new content (delta)
            new_content = last_message.content
            if new_content.startswith(full_text):
                delta = new_content[len(full_text):]
                full_text = new_content
                if delta:
                    yield f"data: {json.dumps({'type': 'text', 'content': delta})}\n\n"

    # Parse out ITEMS_JSON if present in the final message
    if "ITEMS_JSON:" in full_text:
        parts = full_text.split("ITEMS_JSON:", 1)
        items_json_str = parts[1].strip()
        try:
            # Find the JSON array
            start = items_json_str.index("[")
            end = items_json_str.rindex("]") + 1
            items_data = json.loads(items_json_str[start:end])
            yield f"data: {json.dumps({'type': 'items', 'items': items_data})}\n\n"
        except (ValueError, json.JSONDecodeError):
            pass

    yield "data: [DONE]\n\n"


@router.post("")
async def chat(body: ChatRequest, db: AsyncSession = Depends(get_db)):
    return StreamingResponse(
        _stream_agent_response(body.message, body.history, db),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
        },
    )
