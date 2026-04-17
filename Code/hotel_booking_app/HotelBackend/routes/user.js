// File: routes/user.js
const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const db = require('../firebase');

// ==========================================
// 1. THÊM LỊCH SỬ TÌM KIẾM MỚI
// ==========================================
router.post('/:id/search-history', async (req, res) => {
	try {
		const userId = req.params.id;
		const { city, checkIn, checkOut, guests, rooms } = req.body;

		if (!city) {
			return res.status(400).json({ message: "Cần có ít nhất tên thành phố để lưu lịch sử!" });
		}

		// Lưu theo cấu trúc mới (SearchingHistory với field viết hoa)
		const newSearchItem = {
			ID: Date.now(),
			Location: city,
			Checkin: checkIn || null,
			Checkout: checkOut || null,
			RoomNum: rooms || 1,
			Capacity: guests || 1,
			searchedAt: new Date().toISOString()
		};

		const userRef = db.collection('Users').doc(userId);
		await userRef.update({
			SearchingHistory: admin.firestore.FieldValue.arrayUnion(newSearchItem)
		});

		res.status(201).json({ message: "Đã lưu lịch sử tìm kiếm thành công!" });
	} catch (error) {
		console.error("Lỗi khi lưu lịch sử: ", error);
		res.status(500).json({ message: "Lỗi Server!" });
	}
});

// ==========================================
// 2. LẤY DANH SÁCH LỊCH SỬ TÌM KIẾM (CÓ PHÂN TRANG)
// ==========================================
router.get('/:id/search-history', async (req, res) => {
	try {
		const userId = req.params.id;
		const userDoc = await db.collection('Users').doc(userId).get();

		if (!userDoc.exists) {
			return res.status(404).json({ message: "Người dùng không tồn tại!" });
		}

		const userData = userDoc.data();
		// Đọc từ 'SearchingHistory' (cấu trúc mới)
		const rawHistory = userData.SearchingHistory || [];

		// Chuẩn hóa về format thống nhất cho Flutter app
		let history = rawHistory.map(item => ({
			city: item.Location || '',
			checkIn: item.Checkin || null,
			checkOut: item.Checkout || null,
			guests: item.Capacity || 1,
			rooms: item.RoomNum || 1,
			searchedAt: item.searchedAt || null
		}));

		history = history.sort((a, b) => new Date(b.searchedAt) - new Date(a.searchedAt));

		const page = parseInt(req.query.page) || 1;
		const limit = parseInt(req.query.limit) || 10;
		const totalItems = history.length;
		const totalPages = Math.ceil(totalItems / limit);
		const paginatedHistory = history.slice((page - 1) * limit, page * limit);

		res.status(200).json({
			message: "Lấy lịch sử thành công!",
			data: paginatedHistory,
			pagination: { currentPage: page, limit, totalPages, totalItems }
		});
	} catch (error) {
		console.error("Lỗi khi lấy lịch sử: ", error);
		res.status(500).json({ message: "Lỗi Server!" });
	}
});

// ==========================================
// 3. GỢI Ý KHÁCH SẠN DÀNH RIÊNG CHO USER (CÓ PHÂN TRANG)
// ==========================================
router.get('/:id/suggestions', async (req, res) => {
	try {
		const userId = req.params.id;
		let suggestedLocations = [];

		// BƯỚC 1: Lấy địa điểm từ SearchingHistory (cấu trúc mới)
		const userDoc = await db.collection('Users').doc(userId).get();
		if (userDoc.exists) {
			const rawHistory = userDoc.data().SearchingHistory || [];
			rawHistory.forEach(item => {
				if (item.Location) suggestedLocations.push(item.Location);
			});
		}

		// BƯỚC 2: Lấy địa điểm từ lịch sử đặt phòng
		const bookingsSnapshot = await db.collection('Bookings').where('userId', '==', userId).get();
		if (!bookingsSnapshot.empty) {
			const bookedHotelIds = [];
			bookingsSnapshot.forEach(doc => {
				if (doc.data().hotelId) bookedHotelIds.push(doc.data().hotelId);
			});

			if (bookedHotelIds.length > 0) {
				const uniqueIds = [...new Set(bookedHotelIds)].slice(0, 10);
				const hotelsSnap = await db.collection('Hotels')
					.where(admin.firestore.FieldPath.documentId(), 'in', uniqueIds)
					.get();
				hotelsSnap.forEach(doc => {
					if (doc.data().location) suggestedLocations.push(doc.data().location);
				});
			}
		}

		// BƯỚC 3: Lọc trùng
		let uniqueLocations = [...new Set(suggestedLocations)].filter(l => l);
		if (uniqueLocations.length === 0) {
			uniqueLocations = ["Lâm Đồng (Đà Lạt)", "Khánh Hòa (Nha Trang)", "Bà Rịa - Vũng Tàu", "Đà Nẵng"];
		}
		uniqueLocations = uniqueLocations.slice(0, 10);

		// BƯỚC 4: Truy vấn khách sạn theo 'location' (cấu trúc mới)
		const suggestedHotelsSnap = await db.collection('Hotels')
			.where('location', 'in', uniqueLocations)
			.limit(10)
			.get();

		let results = [];
		for (const doc of suggestedHotelsSnap.docs) {
			const data = doc.data();
			const hotel = {
				id: doc.id,
				name: data.name || '',
				city: data.location || '',
				location: data.location || '',
				address: data.location || '',
				star: data.star || 0,
				type: data.type || '',
				images: (data.images || []).map(img => img.url || '').filter(Boolean),
				amenities: (data.amenities || []).map(a => ({ name: a.name || '', icon: a.icon || '' }))
			};

			// Lấy giá phòng thấp nhất theo 'hotelID' (cấu trúc mới)
			const roomSnap = await db.collection('RoomTypes').where('hotelID', '==', parseInt(hotel.id) || hotel.id).get();
			let minPrice = 0;
			if (!roomSnap.empty) {
				const prices = [];
				roomSnap.forEach(r => prices.push(r.data().price || 0));
				minPrice = Math.min(...prices);
			}
			hotel.minRoomPrice = minPrice;
			results.push(hotel);
		}

		results = results.sort(() => Math.random() - 0.5);

		const page = parseInt(req.query.page) || 1;
		const limit = parseInt(req.query.limit) || 10;
		const totalItems = results.length;
		const totalPages = Math.ceil(totalItems / limit);
		const paginatedResults = results.slice((page - 1) * limit, page * limit);

		res.status(200).json({
			message: "Lấy danh sách gợi ý thành công!",
			data: paginatedResults,
			pagination: { currentPage: page, limit, totalPages, totalItems }
		});
	} catch (error) {
		console.error("Lỗi khi tạo danh sách gợi ý: ", error);
		res.status(500).json({ message: "Máy chủ đang bận!" });
	}
});

module.exports = router;




// ==========================================
// 4. LẤY DANH SÁCH VOUCHER KHẢ DỤNG CHO USER
// Lọc: Status=Active, còn hạn, còn lượt dùng, đơn hàng đủ MinSpend
// ==========================================
router.get('/vouchers/available', async (req, res) => {
	try {
		const { orderTotal } = req.query; // Tổng đơn hàng để kiểm tra MinSpend
		const total = parseFloat(orderTotal) || 0;
		const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD

		// Lấy tất cả voucher Active
		const snap = await db.collection('Vouchers')
			.where('Status', '==', 'Active')
			.get();

		const vouchers = [];
		snap.forEach(doc => {
			const d = doc.data();

			// Kiểm tra còn hạn
			if (d.endDate && d.endDate < today) return;
			if (d.startDate && d.startDate > today) return;

			// Kiểm tra còn lượt dùng
			const usedCount = (d.UsageHistory || []).length;
			if (d.UsageLimit > 0 && usedCount >= d.UsageLimit) return;

			// Kiểm tra MinSpend
			if (d.MinSpend > 0 && total > 0 && total < d.MinSpend) return;

			// Tính số tiền giảm thực tế
			let discountAmount = 0;
			if (d.DiscountType === 'Percentage') {
				discountAmount = total * d.Value;
				if (d.MaxDiscountValue > 0) {
					discountAmount = Math.min(discountAmount, d.MaxDiscountValue);
				}
			} else if (d.DiscountType === 'Fixed') {
				discountAmount = d.Value;
			}

			vouchers.push({
				id: doc.id,
				code: d.Code || '',
				discountType: d.DiscountType || 'Percentage',
				value: d.Value || 0,
				maxDiscountValue: d.MaxDiscountValue || 0,
				minSpend: d.MinSpend || 0,
				targetType: d.TargetType || 'all',
				startDate: d.startDate || null,
				endDate: d.endDate || null,
				usageLimit: d.UsageLimit || 0,
				usedCount: usedCount,
				discountAmount: Math.round(discountAmount),
			});
		});

		// Sắp xếp theo discountAmount giảm dần
		vouchers.sort((a, b) => b.discountAmount - a.discountAmount);

		res.status(200).json({
			message: "Lấy danh sách voucher thành công!",
			data: vouchers
		});
	} catch (error) {
		console.error("Lỗi khi lấy vouchers: ", error);
		res.status(500).json({ message: "Lỗi Server!" });
	}
});
