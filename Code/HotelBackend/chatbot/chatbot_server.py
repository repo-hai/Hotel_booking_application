"""
FastAPI server: RAG Chatbot tư vấn khách sạn.
Query ChromaDB → lấy context → gọi OpenAI → trả lời.

Cách chạy:
    cd HotelBackend/chatbot
    python setup_vectordb.py       (chạy 1 lần đầu)
    python chatbot_server.py       (khởi động server)

Server chạy ở http://localhost:8000
"""

import os
from contextlib import asynccontextmanager

import chromadb
from chromadb.utils.embedding_functions import OpenAIEmbeddingFunction
from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from openai import OpenAI
from pydantic import BaseModel

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

# ─── Config ───
OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY")
OPENAI_MODEL = "gpt-5-nano"
DB_DIR = os.path.join(os.path.dirname(__file__), "chroma_db")

SYSTEM_PROMPT = """Bạn là trợ lý tư vấn khách sạn thông minh của ứng dụng Hotel Booking.

NHIỆM VỤ:
- Tư vấn khách sạn và phòng PHÙ HỢP với yêu cầu của khách dựa trên DỮ LIỆU HỆ THỐNG được cung cấp bên dưới
- Gợi ý cụ thể: tên khách sạn, mô tả, loại phòng, giá, tiện nghi
- Nếu khách hỏi ngoài phạm vi dữ liệu, hãy nói rõ và tư vấn chung

QUY TẮC:
- Luôn trả lời bằng tiếng Việt, thân thiện, ngắn gọn
- Phải trả lời dựa vào dữ liệu từ hệ thống không được bịa đặt, trích dẫn tên khách sạn và giá cụ thể
- Không sử dụng emoji 
- Khi gợi ý, liệt kê rõ: tên Khách Sạn, vị trí, số sao, giá phòng, tiện nghi nổi bật
"""

# ─── Global state ───
openai_client: OpenAI = None  # type: ignore
chroma_collection = None
conversation_histories: dict[str, list] = {}


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Khởi tạo ChromaDB + OpenAI client khi server start."""
    global openai_client, chroma_collection

    # Load ChromaDB with OpenAI embeddings
    print(f"Loading ChromaDB from: {DB_DIR}")
    openai_ef = OpenAIEmbeddingFunction(
        api_key=OPENAI_API_KEY,
        model_name="text-embedding-3-small",
    )
    chroma_client = chromadb.PersistentClient(path=DB_DIR)
    chroma_collection = chroma_client.get_collection(
        "hotels", embedding_function=openai_ef
    )
    print(f"Loaded {chroma_collection.count()} documents from ChromaDB")

    # Init OpenAI
    openai_client = OpenAI(api_key=OPENAI_API_KEY)
    print("OpenAI client đã sẵn sàng")

    yield  # Server chạy ở đây

    print("Server shutting down...")


app = FastAPI(title="Hotel Booking Chatbot", lifespan=lifespan)

# CORS — cho Flutter web gọi được
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


# ─── Models ───
class ChatRequest(BaseModel):
    message: str
    session_id: str = "default"


class ChatResponse(BaseModel):
    reply: str
    sources: list[dict] = []


# ─── Helpers ───
def query_hotels(user_message: str, n_results: int = 5) -> str:
    """Tìm khách sạn liên quan từ ChromaDB."""
    results = chroma_collection.query(
        query_texts=[user_message],
        n_results=n_results,
    )

    if not results["documents"] or not results["documents"][0]:
        return "Không tìm thấy khách sạn phù hợp trong hệ thống."

    context_parts = []
    for i, doc in enumerate(results["documents"][0]):
        meta = results["metadatas"][0][i]
        context_parts.append(f"--- Khách sạn {i + 1}: {meta['name']} ---\n{doc}")

    return "\n\n".join(context_parts)


def get_sources(user_message: str, n_results: int = 3) -> list[dict]:
    """Trả về metadata của các KS liên quan (để frontend hiển thị nếu cần)."""
    results = chroma_collection.query(
        query_texts=[user_message],
        n_results=n_results,
    )
    sources = []
    if results["metadatas"] and results["metadatas"][0]:
        for meta in results["metadatas"][0]:
            sources.append(
                {
                    "hotel_id": meta.get("hotel_id"),
                    "name": meta.get("name"),
                    "location": meta.get("location"),
                    "star": meta.get("star"),
                    "min_price": meta.get("min_price"),
                }
            )
    return sources


# ─── Endpoints ───
@app.post("/chat", response_model=ChatResponse)
async def chat(req: ChatRequest):
    """Endpoint chính: nhận tin nhắn → RAG → trả lời."""
    session_id = req.session_id
    user_message = req.message.strip()

    if not user_message:
        return ChatResponse(reply="Bạn chưa nhập gì, hãy hỏi mình nhé! 😊")

    # 1. Query ChromaDB
    hotel_context = query_hotels(user_message)
    sources = get_sources(user_message)

    # 2. Lấy lịch sử hội thoại (giới hạn 20 tin gần nhất)
    if session_id not in conversation_histories:
        conversation_histories[session_id] = []
    history = conversation_histories[session_id]

    # 3. Build messages cho OpenAI
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {
            "role": "system",
            "content": f"DỮ LIỆU KHÁCH SẠN TỪ HỆ THỐNG (dùng để tư vấn):\n\n{hotel_context}",
        },
    ]
    # Thêm lịch sử hội thoại (giới hạn 20 tin nhắn gần nhất)
    messages.extend(history[-20:])
    messages.append({"role": "user", "content": user_message})

    # 4. Gọi OpenAI
    try:
        response = openai_client.chat.completions.create(
            model=OPENAI_MODEL, messages=messages
        )
        reply = response.choices[0].message.content.strip()
    except Exception as e:
        reply = f"Xin lỗi, mình gặp sự cố: {str(e)}"

    # 5. Lưu lịch sử
    history.append({"role": "user", "content": user_message})
    history.append({"role": "assistant", "content": reply})
    # Giữ tối đa 40 tin nhắn
    if len(history) > 40:
        conversation_histories[session_id] = history[-40:]

    return ChatResponse(reply=reply, sources=sources)


@app.post("/chat/clear")
async def clear_chat(session_id: str = "default"):
    """Xóa lịch sử hội thoại."""
    conversation_histories.pop(session_id, None)
    return {"success": True, "message": "Đã xóa lịch sử chat"}


@app.get("/health")
async def health():
    """Health check."""
    count = chroma_collection.count() if chroma_collection else 0
    return {"status": "ok", "documents_count": count}


if __name__ == "__main__":
    import uvicorn

    print("🚀 Khởi động Hotel Booking Chatbot Server...")
    print("   Endpoint:  http://localhost:8000")
    print("   Docs:      http://localhost:8000/docs")
    uvicorn.run(app, host="0.0.0.0", port=8000)
