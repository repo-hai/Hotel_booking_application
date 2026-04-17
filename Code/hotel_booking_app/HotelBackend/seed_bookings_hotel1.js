const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

// Khởi tạo kết nối Firebase
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const RT_INFOS = [
    { id: 'roomtype_1', price: 515000 },
    { id: 'zZd45BTxB8CeRlTqABiL', price: 800000 }
];

async function seedBookings() {
    console.log("🛌 Bắt đầu sinh 20 đơn đặt phòng mẫu cho Khách sạn số 1...");
    
    const statuses = ["Confirmed", "Checked-out", "Pending", "Cancelled"];
    const months = [4, 5, 6]; // Tháng 4, 5, 6 năm 2026

    try {
        for (let i = 1; i <= 20; i++) {
            const rt = RT_INFOS[i % RT_INFOS.length];
            const status = i <= 8 ? "Confirmed" : (i <= 14 ? "Checked-out" : (i <= 18 ? "Pending" : "Cancelled"));
            const month = months[i % months.length];
            const day = (i % 28) + 1;
            const bId = `booking_h1_${i}`;
            
            const checkInDate = new Date(2026, month - 1, day, 14, 0, 0);
            const checkOutDate = new Date(2026, month - 1, day + 2, 12, 0, 0);
            const nights = 2;
            const total = rt.price * nights;

            const bookingData = {
                userId: `user_test_${i}`,
                hotelId: 'hotel_1',
                roomTypeId: rt.id,
                customerName: `Khách hàng VIP ${i}`,
                customerEmail: `customer${i}@example.com`,
                customerPhone: `09123456${i.toString().padStart(2, '0')}`,
                checkIn: checkInDate.toISOString(),
                checkOut: checkOutDate.toISOString(),
                total: total,
                status: status,
                createdAt: new Date(2026, month - 1, day - 5).toISOString(),
                review: null
            };

            // Thêm review cho các đơn Checked-out
            if (status === "Checked-out") {
                bookingData.review = {
                    rating: (i % 5) + 1,
                    comment: `Trải nghiệm tuyệt vời tại đây. Phòng rất sạch sẽ và nhân viên nhiệt tình! (Review ${i})`,
                    createdAt: new Date(2026, month - 1, day + 3).toISOString()
                };
            }

            await db.collection('Bookings').doc(bId).set(bookingData);
            console.log(`✅ Đã tạo đơn ${bId} - Trạng thái: ${status} - Doanh thu: ${total.toLocaleString()} VND`);
        }

        console.log("\n🎉 HOÀN TẤT! 20 đơn đặt phòng đã được 'bơm' thành công lên hệ thống.");
        process.exit();
    } catch (error) {
        console.error("❌ Lỗi khi sinh dữ liệu:", error);
        process.exit(1);
    }
}

seedBookings();
