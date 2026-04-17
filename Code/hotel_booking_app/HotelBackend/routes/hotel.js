// File: routes/hotel.js
const express = require('express');
const router = express.Router();
const db = require('../firebase');

// Helper: chuẩn hóa hotel document → JSON trả về app
function normalizeHotel(id, data) {
	return {
		id: id,
		name: data.name || '',
		city: data.location || '',        // field mới là 'location'
		location: data.location || '',
		address: data.location || '',     // dùng location làm address
		type: data.type || 'Khách sạn',
		description: data.description || '',
		telephone: data.telephone || '',
		email: data.email || '',
		star: data.star || 0,
		// images là array [{ID, url}]
		images: (data.images || []).map(img => img.url || '').filter(Boolean),
		amenities: (data.amenities || []).map(a => ({
			id: a.ID,
			name: a.name || '',
			icon: a.icon || ''
		}))
	};
}

// Helper: chuẩn hóa roomType document → JSON trả về app
function normalizeRoom(id, data) {
	return {
		id: id,
		hotelId: data.hotelID || '',      // field mới là 'hotelID'
		name: data.name || '',
		price: data.price || 0,
		capacity: data.capacity || 1,
		area: data.area || 0,
		bedType: data.bedType || '',
		bedNum: data.bedNum || 1,
		description: data.description || '',
		// images là array [{ID, url}]
		images: (data.images || []).map(img => img.url || '').filter(Boolean),
		policies: (data.policies || []).map(p => ({ id: p.ID, name: p.name || '' })),
		amenities: (data.amenities || []).map(a => ({
			id: a.ID,
			name: a.name || '',
			icon: a.icon || ''
		})),
		// Normalize rooms vật lý: đổi ID → id để tránh lỗi duplicate key trong Dart JSON
		rooms: (data.rooms || []).map(r => ({
			id: String(r.ID || r.id || ''),
			roomNumber: r.roomNumber || '',
			status: r.status || 'Available'
		}))
	};
}
function hotelIdForQuery(id) {
	const n = parseInt(id);
	return isNaN(n) ? id : n;
}
// ==========================================
router.get('/', async (req, res) => {
	try {
		const page = parseInt(req.query.page) || 1;
		const limit = parseInt(req.query.limit) || 10;
		const offset = (page - 1) * limit;

		const totalSnapshot = await db.collection('Hotels').count().get();
		const totalItems = totalSnapshot.data().count;
		const totalPages = Math.ceil(totalItems / limit);

		const snapshot = await db.collection('Hotels').offset(offset).limit(limit).get();
		const hotelsList = [];
		snapshot.forEach(doc => hotelsList.push(normalizeHotel(doc.id, doc.data())));

		res.status(200).json({
			message: "Lấy danh sách thành công!",
			data: hotelsList,
			pagination: { currentPage: page, limit, totalPages, totalItems }
		});
	} catch (error) {
		console.error("Lỗi khi lấy danh sách khách sạn: ", error);
		res.status(500).json({ message: "Bị lỗi Server rồi!" });
	}
});

// ==========================================
// 2. Tìm kiếm khách sạn (Địa điểm + Sức chứa + PHÂN TRANG)
// ==========================================
router.get('/search', async (req, res) => {
	try {
		const { city, guests, rooms } = req.query;
		if (!city || !guests || !rooms) {
			return res.status(400).json({ message: "Vui lòng nhập đầy đủ Thành phố, Số người và Số phòng!" });
		}

		const minCapacity = Math.ceil(parseInt(guests) / parseInt(rooms));

		// Tìm theo field 'location' (cấu trúc mới)
		const hotelSnapshot = await db.collection('Hotels').where('location', '==', city).get();
		if (hotelSnapshot.empty) {
			return res.status(200).json({ message: `Không tìm thấy khách sạn nào tại ${city}`, data: [] });
		}

		const results = [];
		for (const hotelDoc of hotelSnapshot.docs) {
			const hotel = normalizeHotel(hotelDoc.id, hotelDoc.data());

			const roomSnapshot = await db.collection('RoomTypes')
				.where('hotelID', '==', hotelIdForQuery(hotel.id))
				.get();

			const allRooms = [];
			const suitableRooms = [];
			if (!roomSnapshot.empty) {
				roomSnapshot.forEach(roomDoc => {
					const roomData = roomDoc.data();
					const normalized = normalizeRoom(roomDoc.id, roomData);
					allRooms.push(normalized);
					if ((roomData.capacity || 1) >= minCapacity) {
						suitableRooms.push(normalized);
					}
				});
			}

			// Luôn thêm hotel, ưu tiên suitableRooms nếu có
			const displayRooms = suitableRooms.length > 0 ? suitableRooms : allRooms;
			hotel.availableRoomTypes = displayRooms;
			hotel.rooms = displayRooms;
			hotel.minRoomPrice = allRooms.length > 0
				? Math.min(...allRooms.map(r => r.price))
				: 0;
			results.push(hotel);
		}

		const page = parseInt(req.query.page) || 1;
		const limit = parseInt(req.query.limit) || 10;
		const totalItems = results.length;
		const totalPages = Math.ceil(totalItems / limit);
		const paginatedResults = results.slice((page - 1) * limit, page * limit);

		res.status(200).json({
			message: `Tìm thấy ${totalItems} khách sạn phù hợp tại ${city}`,
			data: paginatedResults,
			pagination: { currentPage: page, limit, totalPages, totalItems }
		});
	} catch (error) {
		console.error("Lỗi tìm kiếm: ", error);
		res.status(500).json({ message: "Máy chủ đang bận!" });
	}
});

// ==========================================
// 3. Bộ lọc nâng cao + Sắp xếp (PHÂN TRANG)
// ==========================================
router.post('/filter', async (req, res) => {
	try {
		const { city, minPrice, maxPrice, minStar, requiredAmenityIcons, propertyTypes, sortBy } = req.body;

		let query = db.collection('Hotels');
		if (city) query = query.where('location', '==', city);
		const hotelSnapshot = await query.get();

		let filteredHotels = [];
		for (const doc of hotelSnapshot.docs) {
			const hotel = normalizeHotel(doc.id, doc.data());

			const roomSnap = await db.collection('RoomTypes').where('hotelID', '==', hotelIdForQuery(hotel.id)).get();
			const roomsList = [];
			roomSnap.forEach(r => roomsList.push(normalizeRoom(r.id, r.data())));

			hotel.rooms = roomsList;
			hotel.minRoomPrice = roomsList.length > 0 ? Math.min(...roomsList.map(r => r.price)) : 0;
			filteredHotels.push(hotel);
		}

		// Lọc theo hạng sao
		if (minStar) {
			filteredHotels = filteredHotels.filter(h => h.star >= minStar);
		}

		// Lọc theo loại chỗ nghỉ (type)
		if (propertyTypes && propertyTypes.length > 0) {
			filteredHotels = filteredHotels.filter(h =>
				propertyTypes.includes(h.type)
			);
		}

		// Lọc theo tiện nghi — so sánh theo icon (fa-wifi, fa-spa...)
		if (requiredAmenityIcons && requiredAmenityIcons.length > 0) {
			filteredHotels = filteredHotels.filter(h => {
				const hotelIcons = h.amenities.map(a => a.icon);
				return requiredAmenityIcons.every(icon => hotelIcons.includes(icon));
			});
		}

		// Lọc theo khoảng giá phòng
		if (minPrice !== undefined || maxPrice !== undefined) {
			filteredHotels = filteredHotels.filter(h =>
				h.rooms.some(r => {
					const passMin = minPrice !== undefined ? r.price >= minPrice : true;
					const passMax = maxPrice !== undefined ? r.price <= maxPrice : true;
					return passMin && passMax;
				})
			);
		}

		// Sắp xếp
		if (sortBy) {
			switch (sortBy) {
				case 'price_asc': filteredHotels.sort((a, b) => a.minRoomPrice - b.minRoomPrice); break;
				case 'price_desc': filteredHotels.sort((a, b) => b.minRoomPrice - a.minRoomPrice); break;
				case 'star_desc': filteredHotels.sort((a, b) => b.star - a.star); break;
				case 'star_asc': filteredHotels.sort((a, b) => a.star - b.star); break;
			}
		}

		const page = parseInt(req.query.page) || 1;
		const limit = parseInt(req.query.limit) || 10;
		const totalItems = filteredHotels.length;
		const totalPages = Math.ceil(totalItems / limit);
		const paginatedHotels = filteredHotels.slice((page - 1) * limit, page * limit);

		res.status(200).json({
			message: `Tìm thấy ${totalItems} khách sạn phù hợp`,
			data: paginatedHotels,
			pagination: { currentPage: page, limit, totalPages, totalItems }
		});
	} catch (error) {
		console.error("Lỗi khi lọc/sắp xếp: ", error);
		res.status(500).json({ message: "Lỗi Server!" });
	}
});

// ==========================================
// 4. Reviews của 1 Khách sạn
// Ưu tiên query trực tiếp theo hotelId, fallback qua bookings
// ==========================================
router.get('/:id/reviews', async (req, res) => {
	try {
		const hotelId = req.params.id;
		const limit = parseInt(req.query.limit) || 20;
		let allReviews = [];

		// Cách 1: Query trực tiếp nếu Reviews có field hotelId
		const directSnap = await db.collection('Reviews')
			.where('hotelId', '==', hotelId)
			.limit(limit)
			.get();

		if (!directSnap.empty) {
			directSnap.forEach(doc => {
				const data = doc.data();
				allReviews.push({
					id: doc.id,
					rating: data.rating || 0,
					comment: data.comment || '',
					createdAt: data.createdAt || null,
					guestName: data.guestName || 'Khách ẩn danh'
				});
			});
		} else {
			// Cách 2: Join qua Bookings
			const bookingsSnap = await db.collection('Bookings')
				.where('hotelId', '==', hotelId)
				.get();

			if (!bookingsSnap.empty) {
				const bookingIds = bookingsSnap.docs.map(d => d.id);
				for (let i = 0; i < bookingIds.length; i += 10) {
					const batch = bookingIds.slice(i, i + 10);
					const reviewsSnap = await db.collection('Reviews')
						.where('bookingId', 'in', batch)
						.get();
					reviewsSnap.forEach(doc => {
						const data = doc.data();
						const booking = bookingsSnap.docs.find(b => b.id === data.bookingId);
						allReviews.push({
							id: doc.id,
							rating: data.rating || 0,
							comment: data.comment || '',
							createdAt: data.createdAt || null,
							guestName: booking ? (booking.data().customerName || 'Khách ẩn danh') : 'Khách ẩn danh'
						});
					});
				}
			}
		}

		if (allReviews.length === 0) {
			return res.status(200).json({
				message: "Chưa có đánh giá nào",
				data: { reviews: [], totalReviews: 0, averageRating: 0, breakdown: {} }
			});
		}

		const totalReviews = allReviews.length;
		const averageRating = Math.round(
			(allReviews.reduce((sum, r) => sum + r.rating, 0) / totalReviews) * 10
		) / 10;

		const breakdown = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 };
		allReviews.forEach(r => {
			const star = Math.min(5, Math.max(1, Math.round(r.rating)));
			breakdown[star] = (breakdown[star] || 0) + 1;
		});

		allReviews.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

		res.status(200).json({
			message: "Lấy đánh giá thành công!",
			data: { reviews: allReviews.slice(0, limit), totalReviews, averageRating, breakdown }
		});
	} catch (error) {
		console.error("Lỗi khi lấy reviews: ", error);
		res.status(500).json({ message: "Lỗi Server!" });
	}
});

// ==========================================
// 4. Chi tiết 1 Khách sạn
// ==========================================
router.get('/:id', async (req, res) => {
	try {
		const hotelId = req.params.id;
		const hotelDoc = await db.collection('Hotels').doc(hotelId).get();
		if (!hotelDoc.exists) {
			return res.status(404).json({ message: "Khách sạn không tồn tại hoặc đã bị xóa!" });
		}

		const hotel = normalizeHotel(hotelDoc.id, hotelDoc.data());

		const roomSnapshot = await db.collection('RoomTypes').where('hotelID', '==', hotelIdForQuery(hotelId)).get();
		const rooms = [];
		roomSnapshot.forEach(doc => rooms.push(normalizeRoom(doc.id, doc.data())));
		hotel.rooms = rooms;

		res.status(200).json({
			message: "Lấy thông tin chi tiết khách sạn thành công!",
			data: hotel
		});
	} catch (error) {
		console.error("Lỗi khi lấy chi tiết khách sạn: ", error);
		res.status(500).json({ message: "Máy chủ đang bận!" });
	}
});

module.exports = router;
