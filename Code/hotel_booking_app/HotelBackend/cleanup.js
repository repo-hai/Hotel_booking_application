const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

// Khởi tạo kết nối Firebase
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function cleanupDatabase() {
    console.log("🧹 Bắt đầu quy trình dọn dẹp hệ thống...");
    console.log("Mục tiêu: Chỉ giữ lại 'hotel_1' và các hạng phòng của nó.\n");

    try {
        // --- 1. DỌN DEP KHÁCH SẠN ---
        console.log("--- Đang quét danh sách Khách sạn ---");
        const hotelsSnapshot = await db.collection('Hotels').get();
        let hotelsDeleted = 0;

        for (const doc of hotelsSnapshot.docs) {
            if (doc.id !== 'hotel_1') {
                await db.collection('Hotels').doc(doc.id).delete();
                console.log(`🗑️ Đã xóa Hotel: ${doc.id}`);
                hotelsDeleted++;
            } else {
                console.log(`✅ Giữ lại Hotel mục tiêu: ${doc.id}`);
            }
        }
        console.log(`=> Tổng cộng đã xóa ${hotelsDeleted} khách sạn.\n`);

        // --- 2. DỌN DẸP HẠNG PHÒNG ---
        console.log("--- Đang quét danh sách Hạng phòng ---");
        const roomTypesSnapshot = await db.collection('RoomTypes').get();
        let roomTypesDeleted = 0;

        for (const doc of roomTypesSnapshot.docs) {
            const data = doc.data();
            if (data.hotelId !== 'hotel_1') {
                await db.collection('RoomTypes').doc(doc.id).delete();
                console.log(`🗑️ Đã xóa RoomType: ${doc.id} (Thuộc Hotel: ${data.hotelId})`);
                roomTypesDeleted++;
            } else {
                console.log(`✅ Giữ lại RoomType: ${doc.id} (Thuộc Hotel: ${data.hotelId})`);
            }
        }
        console.log(`=> Tổng cộng đã xóa ${roomTypesDeleted} hạng phòng.\n`);

        console.log("🎉 HOÀN TẤT DỌN DẸP! Database hiện đã ở trạng thái sạch sẽ.");
        process.exit();

    } catch (error) {
        console.error("❌ Lỗi trong quá trình dọn dẹp:", error);
        process.exit(1);
    }
}

cleanupDatabase();
