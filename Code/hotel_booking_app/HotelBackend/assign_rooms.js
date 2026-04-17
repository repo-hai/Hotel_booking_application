const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

// Khởi tạo Firebase
if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
}
const db = admin.firestore();

async function assignRoomsToConfirmedBookings() {
    console.log("🚀 Bắt đầu quá trình gán phòng tự động...");

    try {
        // 1. Lấy tất cả RoomTypes của hotel_1 để biết danh sách phòng Available
        const roomTypesSnapshot = await db.collection('RoomTypes').where('hotelId', '==', 'hotel_1').get();
        const roomTypeMap = {};
        
        roomTypesSnapshot.forEach(doc => {
            const data = doc.data();
            roomTypeMap[doc.id] = data.rooms || [];
        });

        // 2. Lấy tất cả Bookings ở trạng thái Confirmed mà chưa có assignedRoomNumber
        const bookingsSnapshot = await db.collection('Bookings')
            .where('status', '==', 'Confirmed')
            .get();

        let assignedCount = 0;

        for (const doc of bookingsSnapshot.docs) {
            const booking = doc.data();
            
            // Bỏ qua nếu đã có phòng gán
            if (booking.assignedRoomNumber) continue;

            // Tìm RoomTypeId (Sửa lại để lấy trực tiếp từ roomTypeId top-level)
            const rtId = booking.roomTypeId || (booking.bookedRooms && booking.bookedRooms.length > 0 ? (booking.bookedRooms[0].roomTypeId || booking.bookedRooms[0].id) : null);
            
            if (rtId) {
                const rooms = roomTypeMap[rtId];

                if (rooms) {
                    // Tìm phòng Available đầu tiên
                    const availableRoom = rooms.find(r => r.status === 'Available');
                    
                    if (availableRoom) {
                        console.log(`✅ Gán phòng ${availableRoom.roomNumber} cho Booking ${doc.id}`);
                        
                        // Cập nhật Booking
                        await db.collection('Bookings').doc(doc.id).update({
                            assignedRoomNumber: availableRoom.roomNumber
                        });

                        // Đánh dấu phòng này đã bị chiếm trong bộ nhớ tạm (local map) để không gán trùng
                        availableRoom.status = 'Occupied';
                        assignedCount++;
                    } else {
                        console.log(`⚠️ Hạng phòng ${rtId} không còn phòng trống cho Booking ${doc.id}`);
                    }
                }
            }
        }

        console.log(`\n🎉 HOÀN THÀNH! Đã gán thành công ${assignedCount} phòng.`);
        process.exit(0);
    } catch (error) {
        console.error("❌ Lỗi thực thi script:", error);
        process.exit(1);
    }
}

assignRoomsToConfirmedBookings();
