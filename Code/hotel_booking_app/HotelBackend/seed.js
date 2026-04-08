const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

// Khởi tạo kết nối Firebase
admin.initializeApp({
	credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Danh sách các thành phố để xáo trộn ngẫu nhiên
const cities = ["Hà Nội", "Nha Trang", "Đà Lạt", "Đà Nẵng", "Phú Quốc", "Hồ Chí Minh", "Vũng Tàu"];

async function seed100Records() {
	console.log("⏳ Bắt đầu khởi động nhà máy sản xuất dữ liệu...");
	console.log("Quá trình này sẽ mất khoảng 15-30 giây, em kiên nhẫn đợi nhé!\n");

	try {
		// Chạy vòng lặp 100 lần
		for (let i = 1; i <= 100; i++) {
			// Lấy ngẫu nhiên một thành phố trong danh sách
			const randomCity = cities[i % cities.length];

			// Tạo các ID đồng bộ cho lần lặp thứ i
			const userId = `user_${i}`;
			const hotelId = `hotel_${i}`;
			const roomId = `roomtype_${i}`;
			const bookingId = `booking_${i}`;
			const convId = `conv_${i}`;

			// 1. Tạo 100 Users
			await db.collection('Users').doc(userId).set({
				email: `khachhang${i}@gmail.com`,
				name: `Khách Hàng Thứ ${i}`,
				phone: `0900000${i.toString().padStart(3, '0')}`,
				membershipLevel: i % 2 === 0 ? "Gold" : "Silver",
				point: i * 10
			});

			// 2. Tạo 100 Khách sạn rải rác ở các thành phố
			await db.collection('Hotels').doc(hotelId).set({
				userId: "uid_admin_01",
				name: `Khách sạn ${randomCity} ${i} Sao`,
				address: `Số ${i} Đường ABC, ${randomCity}`,
				city: randomCity,
				star: (i % 5) + 1, // Xáo trộn từ 1 đến 5 sao
				// Dùng link ảnh thật trên mạng để lát App Android hiển thị được
				images: ["https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=500&q=60"],
				amenities: [{ name: "Wifi miễn phí", icon: "wifi" }, { name: "Hồ bơi", icon: "pool" }]
			});

			// 3. Tạo 100 Loại phòng (Gắn liền với khách sạn ở trên)
			await db.collection('RoomTypes').doc(roomId).set({
				hotelId: hotelId,
				name: `Phòng Hạng Sang Loại ${i}`,
				price: 500000 + (i * 15000), // Giá thay đổi liên tục
				capacity: (i % 4) + 1, // Sức chứa xáo trộn từ 1 đến 4 người
				images: ["https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=500&q=60"],
				rooms: [{ roomId: `R101_${i}`, roomNumber: "101", status: "Available" }]
			});

			// 4. Tạo 100 Đơn đặt phòng
			await db.collection('Bookings').doc(bookingId).set({
				userId: userId,
				hotelId: hotelId,
				customerName: `Khách Hàng Thứ ${i}`,
				checkIn: "2026-05-10T14:00:00Z",
				checkOut: "2026-05-12T12:00:00Z",
				total: 1000000 + (i * 5000),
				status: i % 3 === 0 ? "Pending" : "Confirmed", // Trạng thái ngẫu nhiên
			});

			// 5. Tạo 100 Đánh giá (Reviews)
			await db.collection('Reviews').doc(`rev_${i}`).set({
				bookingId: bookingId,
				rating: (i % 5) + 1,
				comment: `Trải nghiệm tại khách sạn ${randomCity} số ${i} cực kỳ tuyệt vời!`,
				createdAt: new Date().toISOString()
			});

			// 6. Tạo 100 Vouchers
			await db.collection('Vouchers').doc(`voucher_${i}`).set({
				code: `SUMMER${i}`,
				discountType: "Percentage",
				value: (i % 5) + 5, // giảm 5% đến 9%
				status: "Active"
			});

			// 7. Tạo 100 Khung Chat & Tin nhắn
			await db.collection('Conversations').doc(convId).set({
				user1Id: userId,
				user2Id: "uid_admin_01",
				lastMessage: `Nhờ admin kiểm tra đơn ${bookingId} giúp tôi.`,
				updatedAt: new Date().toISOString()
			});

			// Tạo tin nhắn con chui vào bên trong Sub-collection
			await db.collection('Conversations').doc(convId).collection('Messages').doc(`msg_${i}`).set({
				senderId: userId,
				content: `Nhờ admin kiểm tra đơn ${bookingId} giúp tôi.`,
				sentAt: new Date().toISOString()
			});

			// Báo cáo tiến độ cho mỗi 10 vòng lặp để em đỡ sốt ruột
			if (i % 10 === 0) {
				console.log(`✔️ Đã sản xuất và bơm thành công ${i}/100 cụm dữ liệu...`);
			}
		}

		console.log("\n🎉 HOÀN TẤT! 700+ Bản ghi đã an tọa trên Firebase. Tha hồ test nhé!");
		process.exit();

	} catch (error) {
		console.error("❌ Bị lỗi trong quá trình bơm:", error);
	}
}

// Bóp cò chạy hàm
seed100Records();