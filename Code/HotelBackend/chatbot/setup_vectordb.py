# -*- coding: utf-8 -*-
"""
Script tao Vector Database tu du lieu Hotels + RoomTypes JSON.
Su dung OpenAI Embeddings de ho tro tieng Viet tot.

Cach chay:
    cd HotelBackend/chatbot
    pip install -r requirements.txt
    set PYTHONIOENCODING=utf-8 && python setup_vectordb.py
"""

import json
import os
import sys

import chromadb
from chromadb.utils.embedding_functions import OpenAIEmbeddingFunction
from dotenv import load_dotenv

# Fix Windows console encoding
sys.stdout.reconfigure(encoding="utf-8")

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data")
DB_DIR = os.path.join(os.path.dirname(__file__), "chroma_db")

OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY")

openai_ef = OpenAIEmbeddingFunction(
    api_key=OPENAI_API_KEY,
    model_name="text-embedding-3-small",
)


def load_json(filename):
    filepath = os.path.join(DATA_DIR, filename)
    with open(filepath, "r", encoding="utf-8") as f:
        return json.load(f)


def format_price(price):
    return f"{price:,.0f}d".replace(",", ".")


def build_hotel_documents(hotels, room_types):
    rooms_by_hotel = {}
    for rt in room_types:
        hid = rt["hotelID"]
        if hid not in rooms_by_hotel:
            rooms_by_hotel[hid] = []
        rooms_by_hotel[hid].append(rt)

    documents = []
    metadatas = []
    ids = []

    for hotel in hotels:
        hotel_id = hotel["ID"]
        hotel_rooms = rooms_by_hotel.get(hotel_id, [])

        prices = [r["price"] for r in hotel_rooms] if hotel_rooms else [0]
        min_price = min(prices)
        max_price = max(prices)

        amenities = ", ".join([a["name"] for a in hotel.get("amenities", [])])

        room_lines = []
        for r in hotel_rooms:
            r_amenities = ", ".join([a["name"] for a in r.get("amenities", [])])
            r_policies = ", ".join([p["name"] for p in r.get("policies", [])])
            room_lines.append(
                "- %(name)s: %(price)s/\u0111\u00eam, "
                "s\u1ee9c ch\u1ee9a %(cap)s kh\u00e1ch, %(beds)s gi\u01b0\u1eddng (%(btype)s), "
                "di\u1ec7n t\u00edch %(area)sm\u00b2. "
                "Ti\u1ec7n nghi: %(amen)s. "
                "Ch\u00ednh s\u00e1ch: %(pol)s."
                % {
                    "name": r["name"],
                    "price": format_price(r["price"]),
                    "cap": r["capacity"],
                    "beds": r["bedNum"],
                    "btype": r["bedType"],
                    "area": r["area"],
                    "amen": r_amenities or "c\u01a1 b\u1ea3n",
                    "pol": r_policies or "li\u00ean h\u1ec7",
                }
            )

        rooms_text = "\n".join(room_lines) if room_lines else "Ch\u01b0a c\u00f3 th\u00f4ng tin."

        doc = (
            "Kh\u00e1ch s\u1ea1n: %(name)s\n"
            "Lo\u1ea1i h\u00ecnh: %(type)s\n"
            "V\u1ecb tr\u00ed: %(loc)s\n"
            "S\u1ed1 sao: %(star)s sao\n"
            "M\u00f4 t\u1ea3: %(desc)s\n"
            "Gi\u00e1 ph\u00f2ng: t\u1eeb %(minp)s \u0111\u1ebfn %(maxp)s\n"
            "Ti\u1ec7n nghi: %(amen)s\n"
            "Li\u00ean h\u1ec7: %(phone)s, %(email)s\n"
            "C\u00e1c lo\u1ea1i ph\u00f2ng:\n%(rooms)s"
            % {
                "name": hotel["name"],
                "type": hotel.get("type", "Kh\u00e1ch s\u1ea1n"),
                "loc": hotel["location"],
                "star": hotel["star"],
                "desc": hotel.get("description", ""),
                "minp": format_price(min_price),
                "maxp": format_price(max_price),
                "amen": amenities or "c\u01a1 b\u1ea3n",
                "phone": hotel.get("telephone", ""),
                "email": hotel.get("email", ""),
                "rooms": rooms_text,
            }
        )

        meta = {
            "hotel_id": hotel_id,
            "name": hotel["name"],
            "type": hotel.get("type", "Khach san"),
            "location": hotel["location"],
            "star": hotel["star"],
            "min_price": min_price,
            "max_price": max_price,
            "room_count": len(hotel_rooms),
        }

        documents.append(doc)
        metadatas.append(meta)
        ids.append(f"hotel_{hotel_id}")

    return documents, metadatas, ids


def main():
    print("=" * 50)
    print("SETUP VECTOR DATABASE")
    print("  Embedding: OpenAI text-embedding-3-small")
    print("=" * 50)

    print("\n[1/3] Loading JSON data...")
    hotels = load_json("hotels.json")
    room_types = load_json("roomType.json")
    print(f"  -> {len(hotels)} hotels, {len(room_types)} room types")

    print("\n[2/3] Building documents...")
    documents, metadatas, ids = build_hotel_documents(hotels, room_types)
    print(f"  -> {len(documents)} documents")
    print(f"\n  --- Preview ---")
    print(f"  {documents[0][:200]}...")

    print(f"\n[3/3] Saving to ChromaDB: {DB_DIR}")

    client = chromadb.PersistentClient(path=DB_DIR)

    try:
        client.delete_collection("hotels")
        print("  -> Deleted old collection")
    except Exception:
        pass

    collection = client.create_collection(
        name="hotels",
        embedding_function=openai_ef,
    )

    collection.add(documents=documents, metadatas=metadatas, ids=ids)
    print(f"  -> Saved {collection.count()} documents!")

    # Test
    print("\n--- Test queries ---")
    queries = [
        "khach san 5 sao o Ha Noi",
        "Resort o Da Nang",
        "phong gia dinh gia re",
        "khach san co ho boi spa Nha Trang",
    ]
    for q in queries:
        results = collection.query(query_texts=[q], n_results=3)
        print(f"\n  '{q}':")
        for i, meta in enumerate(results["metadatas"][0]):
            d = results["distances"][0][i]
            print(f"    [{i+1}] {meta['name']} ({meta['location']}) - {meta['star']} sao - dist: {d:.4f}")

    print("\n" + "=" * 50)
    print("DONE!")
    print("=" * 50)


if __name__ == "__main__":
    main()
