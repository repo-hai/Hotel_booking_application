const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
const fs = require('fs');

// Khởi tạo Firebase
if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
}
const db = admin.firestore();

async function syncRoomTypes() {
    console.log("🔄 Bắt đầu đồng bộ hóa RoomTypes từ JSON lên Firestore...");

    try {
        const roomTypesData = JSON.parse(fs.readFileSync('./roomType.json', 'utf8'));
        
        for (const rt of roomTypesData) {
            // Mapping ID to match seeder data for hotel_1
            let docId = rt.ID.toString();
            if (rt.hotelID === 1) {
                if (rt.ID === 1) docId = 'roomtype_1';
                else if (rt.ID === 2) docId = 'zZd45BTxB8CeRlTqABiL';
            }
            
            console.log(`Updating RoomType ${docId} (${rt.name})...`);
            
            await db.collection('RoomTypes').doc(docId).set({
                hotelId: `hotel_${rt.hotelID}`,
                name: rt.name,
                area: rt.area,
                price: rt.price,
                description: rt.description,
                bedType: rt.bedType,
                capacity: rt.capacity,
                bedNum: rt.bedNum,
                images: rt.images,
                policies: rt.policies,
                amenities: rt.amenities,
                rooms: rt.rooms
            }, { merge: true });
        }

        console.log("\n✅ ĐỒNG BỘ HOÀN TẤT!");
        process.exit(0);
    } catch (error) {
        console.error("❌ Lỗi đồng bộ:", error);
        process.exit(1);
    }
}

syncRoomTypes();
