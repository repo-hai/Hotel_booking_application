import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import json


def upload_collection(db, file_name, collection_name, name_field="name"):
    try:
        with open(file_name, "r", encoding="utf-8") as file:
            data = json.load(file)
    except FileNotFoundError:
        print(f"  Không tìm thấy file '{file_name}'. Bỏ qua.")
        return

    print(f"\n{'='*50}")
    print(f"Đẩy {len(data)} bản ghi lên collection '{collection_name}'...")
    success_count = 0

    for item in data:
        try:
            doc_id = str(item["ID"])
            db.collection(collection_name).document(doc_id).set(item)
            label = item.get(name_field, f"ID {item['ID']}")
            print(f"  [+] Đã thêm: {label}")
            success_count += 1
        except Exception as e:
            print(f"  [-] Lỗi ID {item.get('ID', '?')}: {e}")

    print(f"=> Hoàn thành {collection_name}: {success_count}/{len(data)}")


def main():
    try:
        cred = credentials.Certificate("../serviceAccountKey.json")
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("Đã kết nối th��nh công với Firebase!")
    except Exception as e:
        print(f"Lỗi kết nối Firebase: {e}")
        return

    upload_collection(db, "user.json",     "Users",     name_field="Name")
    upload_collection(db, "hotels.json",   "Hotels",    name_field="name")
    upload_collection(db, "roomType.json", "RoomTypes", name_field="name")
    upload_collection(db, "vouchers.json", "Vouchers",  name_field="name")

    print(f"\n{'='*50}")
    print("Upload tất cả hoàn tất!")


if __name__ == "__main__":
    main()
