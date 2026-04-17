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
		// --- 0. TẠO MẪU CHỦ KHÁCH SẠN DEMO ---
		const demoOwnerId = "owner_demo_01";
		const demoHotelId = "hotel_demo_pro";
		
		await db.collection('Users').doc(demoOwnerId).set({
			email: "partner@hotel.com",
			name: "Chủ Khách Sạn Demo",
			phone: "0988888888",
			type: "owner",
			createdAt: new Date().toISOString()
		});

		await db.collection('Hotels').doc(demoHotelId).set({
			userId: demoOwnerId,
			name: "Grand Palace Hotel Resido",
			address: "123 Đường Lê Lợi, Quận 1",
			city: "Hồ Chí Minh",
			lat: 10.7769, lng: 106.7009,
			star: 5,
			images: ["https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80"],
			amenities: [{ name: "Wifi", icon: "wifi" }, { name: "Hồ bơi", icon: "pool" }, { name: "Gym", icon: "fitness_center" }],
			checkInTime: "14:00", checkOutTime: "12:00",
			cancellationPolicy: "Linh hoạt : Miễn phí hủy trước 24h",
			createdAt: new Date().toISOString()
		});

		// Tạo một vài hạng phòng cho khách sạn Demo
		const roomTypesDemo = [
			{ id: "demo_rt_1", name: "Phòng Suite Hướng Biển", price: 1500000, capacity: 2 },
			{ id: "demo_rt_2", name: "Phòng Gia Đình Deluxe", price: 2500000, capacity: 4 }
		];

		for (const rt of roomTypesDemo) {
			await db.collection('RoomTypes').doc(rt.id).set({
				hotelId: demoHotelId,
				name: rt.name,
				price: rt.price,
				capacity: rt.capacity,
				weekdayPrice: rt.price,
				weekendPrice: rt.price * 1.2,
				images: ["https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=500&q=60"],
				amenities: ["Máy lạnh", "Tivi", "Bồn tắm"],
				rooms: [{ roomId: `R_D1_${rt.id}`, roomNumber: "101", status: "Available" }],
				createdAt: new Date().toISOString()
			});
		}

		// Tạo 15 đơn hàng mẫu (5 Chờ duyệt, 5 Sắp tới, 5 Đã hủy)
		const statuses = ["Pending", "Confirmed", "Cancelled"];
		for (let j = 1; j <= 15; j++) {
			const status = statuses[Math.floor((j-1)/5)];
			const bId = `booking_demo_${j}`;
			await db.collection('Bookings').doc(bId).set({
				userId: `user_${j}`,
				hotelId: demoHotelId,
				customerName: `Khách Hàng Demo ${j}`,
				checkIn: "2026-06-10T14:00:00Z",
				checkOut: "2026-06-12T12:00:00Z",
				total: 1500000 + (j * 10000),
				status: status,
				createdAt: new Date().toISOString(),
				// Một số có review
				review: j <= 5 ? {
					rating: (j % 5) + 1,
					comment: `Dịch vụ tại Grand Palace rất tốt, tôi sẽ quay lại! (Review số ${j})`,
					createdAt: new Date().toISOString()
				} : null
			});
		}

		// --- 1. CHẠY VÒNG LẶP 100 RECORDS TỰ ĐỘNG ---
		for (let i = 1; i <= 100; i++) {
			const randomCity = cities[i % cities.length];
			const userId = `user_${i}`;
			const hotelId = `hotel_${i}`;
			const roomId = `roomtype_${i}`;
			const bookingId = `booking_${i}`;

			await db.collection('Users').doc(userId).set({
				email: `khachhang${i}@gmail.com`,
				name: `Khách Hàng Thứ ${i}`,
				phone: `0900000${i.toString().padStart(3, '0')}`,
				type: "customer",
				membershipLevel: i % 2 === 0 ? "Gold" : "Silver",
				point: i * 10,
				createdAt: new Date().toISOString()
			});

			await db.collection('Hotels').doc(hotelId).set({
				userId: "owner_demo_01",
				name: `Khách sạn ${randomCity} ${i}`,
				address: `Số ${i} Đường ABC, ${randomCity}`,
				city: randomCity,
				lat: 10 + (i/100), lng: 106 + (i/100),
				star: (i % 5) + 1,
				images: ["https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=500&q=60"],
				amenities: [{ name: "Wifi miễn phí", icon: "wifi" }, { name: "Hồ bơi", icon: "pool" }],
				checkInTime: "14:00", checkOutTime: "12:00",
				cancellationPolicy: "Tiêu chuẩn",
				createdAt: new Date().toISOString()
			});

			await db.collection('RoomTypes').doc(roomId).set({
				hotelId: hotelId,
				name: `Hạng phòng ${i}`,
				price: 500000 + (i * 15000),
				capacity: (i % 4) + 1,
				images: ["https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=500&q=60"],
				rooms: [{ roomId: `R101_${i}`, roomNumber: "101", status: "Available" }],
				createdAt: new Date().toISOString()
			});

			await db.collection('Bookings').doc(bookingId).set({
				userId: userId,
				hotelId: hotelId,
				customerName: `Khách Hàng Thứ ${i}`,
				checkIn: "2026-05-10T14:00:00Z",
				checkOut: "2026-05-12T12:00:00Z",
				total: 1000000 + (i * 5000),
				status: (i % 4 === 0) ? "Cancelled" : (i % 3 === 0 ? "Pending" : "Confirmed"),
				createdAt: new Date().toISOString()
			});

			if (i % 10 === 0) {
				console.log(`✔️ Đã sản xuất và bơm thành công ${i}/100 cụm dữ liệu...`);
			}
		}

		console.log("\n🎉 HOÀN TẤT! Toàn bộ dữ liệu Demo cho Chủ khách sạn đã sẵn sàng trên Firebase.");
		process.exit();

	} catch (error) {
		console.error("❌ Bị lỗi trong quá trình bơm:", error);
	}
}

seed100Records();