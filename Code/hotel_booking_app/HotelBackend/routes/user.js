// File: routes/user.js
const express = require('express');
const router = express.Router();
const admin = require('firebase-admin'); // Dùng admin để gọi các lệnh đặc biệt của mảng
const db = require('../firebase');

// ==========================================
// 1. API: THÊM LỊCH SỬ TÌM KIẾM MỚI (Không cần phân trang)
// ==========================================
router.post('/:id/search-history', async (req, res) => {
	try {
		const userId = req.params.id;
		const { city, checkIn, checkOut, guests, rooms } = req.body;

		if (!city) {
			return res.status(400).json({ message: "Cần có ít nhất tên thành phố để lưu lịch sử!" });
		}

		const newSearchItem = {
			city: city,
			checkIn: checkIn || null,
			checkOut: checkOut || null,
			guests: guests || 1,
			rooms: rooms || 1,
			searchedAt: new Date().toISOString()
		};

		const userRef = db.collection('Users').doc(userId);

		await userRef.update({
			searchHistory: admin.firestore.FieldValue.arrayUnion(newSearchItem)
		});

		res.status(201).json({ message: "Đã lưu lịch sử tìm kiếm ngầm thành công!" });

	} catch (error) {
		console.error("Lỗi khi lưu lịch sử: ", error);
		res.status(500).json({ message: "Lỗi Server!" });
	}
});

// ==========================================
// 2. API: LẤY DANH SÁCH LỊCH SỬ TÌM KIẾM (CÓ PHÂN TRANG)
// ==========================================
router.get('/:id/search-history', async (req, res) => {
	try {
		const userId = req.params.id;
		const userDoc = await db.collection('Users').doc(userId).get();

		if (!userDoc.exists) {
			return res.status(404).json({ message: "Người dùng không tồn tại!" });
		}

		const userData = userDoc.data();
		let history = userData.searchHistory || [];

		// Sắp xếp lịch sử mới nhất lên đầu
		history = history.sort((a, b) => new Date(b.searchedAt) - new Date(a.searchedAt));

		// --- BẮT ĐẦU PHÂN TRANG ---
		const page = parseInt(req.query.page) || 1;
		const limit = parseInt(req.query.limit) || 10;

		const totalItems = history.length;
		const totalPages = Math.ceil(totalItems / limit);

		const startIndex = (page - 1) * limit;
		const endIndex = page * limit;
		const paginatedHistory = history.slice(startIndex, endIndex);
		// --- KẾT THÚC PHÂN TRANG ---

		res.status(200).json({
			message: "Lấy lịch sử thành công!",
			data: paginatedHistory,
			pagination: {
				currentPage: page,
				limit: limit,
				totalPages: totalPages,
				totalItems: totalItems
			}
		});

	} catch (error) {
		console.error("Lỗi khi lấy lịch sử: ", error);
		res.status(500).json({ message: "Lỗi Server!" });
	}
});

// ==========================================
// 3. API: GỢI Ý KHÁCH SẠN DÀNH RIÊNG CHO USER (CÓ PHÂN TRANG)
// ==========================================
router.get('/:id/suggestions', async (req, res) => {
	try {
		const userId = req.params.id;
		let suggestedCities = [];

		// BƯỚC 1: Lấy các thành phố từ Lịch sử tìm kiếm
		const userDoc = await db.collection('Users').doc(userId).get();
		if (userDoc.exists && userDoc.data().searchHistory) {
			const history = userDoc.data().searchHistory;
			const searchedCities = history.map(item => item.city);
			suggestedCities.push(...searchedCities);
		}

		// BƯỚC 2: Lấy các thành phố từ Lịch sử đặt phòng
		const bookingsSnapshot = await db.collection('Bookings').where('userId', '==', userId).get();
		const bookedHotelIds = [];

		if (!bookingsSnapshot.empty) {
			bookingsSnapshot.forEach(doc => {
				if (doc.data().hotelId) bookedHotelIds.push(doc.data().hotelId);
			});

			if (bookedHotelIds.length > 0) {
				const uniqueBookedHotelIds = [...new Set(bookedHotelIds)].slice(0, 10);
				const hotelsSnap = await db.collection('Hotels').where(admin.firestore.FieldPath.documentId(), 'in', uniqueBookedHotelIds).get();

				hotelsSnap.forEach(doc => {
					if (doc.data().city) suggestedCities.push(doc.data().city);
				});
			}
		}

		// BƯỚC 3: Sàng lọc, loại bỏ trùng lặp và LOẠI BỎ GIÁ TRỊ RÁC (undefined)
		let uniqueCities = [...new Set(suggestedCities)].filter(city => city != null && city !== "");

		if (uniqueCities.length === 0) {
			uniqueCities = ["Đà Lạt", "Nha Trang", "Vũng Tàu", "Đà Nẵng"];
		}

		uniqueCities = uniqueCities.slice(0, 10);

		// BƯỚC 4: Truy vấn Khách sạn
		const suggestedHotelsSnap = await db.collection('Hotels').where('city', 'in', uniqueCities).limit(10).get();

		let results = [];

		for (const doc of suggestedHotelsSnap.docs) {
			let hotel = { id: doc.id, ...doc.data() };

			const roomSnap = await db.collection('RoomTypes').where('hotelId', '==', hotel.id).get();
			let minPrice = 0;
			let capacity = 2;

			if (!roomSnap.empty) {
				const roomPrices = [];
				roomSnap.forEach(r => {
					roomPrices.push(r.data().price);
					capacity = r.data().capacity;
				});
				minPrice = Math.min(...roomPrices);
			}

			hotel.minRoomPrice = minPrice;
			hotel.suggestedCapacity = capacity;

			results.push(hotel);
		}

		// Trộn ngẫu nhiên danh sách gợi ý
		results = results.sort(() => Math.random() - 0.5);

		// --- BẮT ĐẦU PHÂN TRANG ---
		const page = parseInt(req.query.page) || 1;
		const limit = parseInt(req.query.limit) || 10;

		const totalItems = results.length;
		const totalPages = Math.ceil(totalItems / limit);

		const startIndex = (page - 1) * limit;
		const endIndex = page * limit;
		const paginatedResults = results.slice(startIndex, endIndex);
		// --- KẾT THÚC PHÂN TRANG ---

		res.status(200).json({
			message: "Lấy danh sách gợi ý thành công!",
			data: paginatedResults,
			pagination: {
				currentPage: page,
				limit: limit,
				totalPages: totalPages,
				totalItems: totalItems
			}
		});

	} catch (error) {
		console.error("Lỗi khi tạo danh sách gợi ý: ", error);
		res.status(500).json({ message: "Máy chủ đang bận!" });
	}
});

module.exports = router;