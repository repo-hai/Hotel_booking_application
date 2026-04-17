import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import json


def upload_hotels_to_firestore():
    # 1. Khởi tạo Firebase Admin SDK với Service Account Key
    try:
        cred = credentials.Certificate("../serviceAccountKey.json")
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("Đã kết nối thành công với Firebase!")
    except Exception as e:
        print(f"Lỗi kết nối Firebase: {e}")
        return

    # 2. Đọc dữ liệu từ file JSON
    try:
        with open("hotels.json", "r", encoding="utf-8") as file:
            hotels_data = json.load(file)
    except FileNotFoundError:
        print("Không tìm thấy file 'hotels.json'. Vui lòng kiểm tra lại.")
        return

    # 3. Đẩy dữ liệu lên collection 'Vouchers'
    collection_name = "Hotels"
    success_count = 0

    print(
        f"Đang tiến hành đẩy {len(hotels_data)} bản ghi lên collection '{collection_name}'..."
    )

    for hotel in hotels_data:
        try:
            # Sử dụng trường 'ID' của khách sạn làm Document ID trong Firestore
            # Nếu muốn Firebase tự sinh chuỗi ID ngẫu nhiên, đổi thành: db.collection(collection_name).add(hotel)
            doc_id = str(hotel["ID"])
            db.collection(collection_name).document(doc_id).set(hotel)

            print(f"  [+] Đã thêm: {hotel['name']}")
            success_count += 1
        except Exception as e:
            print(f"  [-] Lỗi khi thêm khách sạn ID {hotel['ID']}: {e}")

    # 4. Tổng kết
    print("=" * 40)
    print(
        f"Hoàn thành! Đã đẩy thành công {success_count}/{len(hotels_data)} khách sạn."
    )


if __name__ == "__main__":
    upload_hotels_to_firestore()
