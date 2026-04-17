// File: routes/hotel.js
const express = require('express');
const router = express.Router();
const db = require('../firebase');

// ==========================================
// 1. API: Lấy danh sách tất cả khách sạn (CÓ PHÂN TRANG)
// Fields: ID, type, name, description, telephone, location, email, star, images[{ID,url}], amenities[{ID,name,icon}]
// ==========================================
router.get('/', async (req, res) => {
	try {
		const page = parseInt(req.query.page) || 1;
		const limit = parseInt(req.query.limit) || 10;
		const offset = (page - 1) * limit;

		const totalSnapshot = await db.collection('Hotels').count().get();
		const totalItems = totalSnapshot.data().count;
		const totalPages = Math.ceil(totalItems / limit);

		const snapshot = await db.collection('Hotels')
			.offset(offset)
			.limit(limit)
			.get();

		const hotelsList = [];
		snapshot.forEach(doc => {
			hotelsList.push({ id: doc.id, ...doc.data() });
		});

		res.status(200).json({
			message: "Lấy danh sách thành công!",
			data: hotelsList,
			pagination: {
				currentPage: page,
				limit: limit,
				totalPages: totalPages,
				totalItems: totalItems
			}
		});
	} catch (error) {
		console.error("Lỗi khi lấy danh sách khách sạn: ", error);
		res.status(500).json({ message: "Bị lỗi Server rồi!" });
	}
});

// ==========================================
// 2. API: Tìm kiếm khách sạn phù hợp (Địa điểm + Sức chứa + CÓ PHÂN TRANG)
// ==========================================
router.get('/search', async (req, res) => {
	try {
		const { city, guests, rooms } = req.query;

		if (!city || !guests || !rooms) {
			return res.status(400).json({ message: "Vui lòng nhập đầy đủ Thành phố, Số người và Số phòng!" });
		}

		const minCapacity = Math.ceil(parseInt(guests) / parseInt(rooms));
		// Tìm theo field 'location' thay vì 'city'
		const hotelSnapshot = await db.collection('Hotels').where('location', '==', city).get();

		if (hotelSnapshot.empty) {
			return res.status(200).json({ message: `Không tìm thấy khách sạn nào tại ${city}`, data: [] });
		}

		const results = [];
		for (const hotelDoc of hotelSnapshot.docs) {
			const hotelData = hotelDoc.data();
			hotelData.id = hotelDoc.id;

			// RoomType dùng field 'hotelID' thay vì 'hotelId'
			const roomSnapshot = await db.collection('RoomTypes')
				.where('hotelID', '==', hotelData.ID || parseInt(hotelDoc.id))
				.where('capacity', '>=', minCapacity)
				.get();

			if (!roomSnapshot.empty) {
				const suitableRooms = [];
				roomSnapshot.forEach(roomDoc => {
					suitableRooms.push({ id: roomDoc.id, ...roomDoc.data() });
				});
				results.push({ ...hotelData, availableRoomTypes: suitableRooms });
			}
		}

		const pageCurrent = parseInt(req.query.page) || 1;
		const limitCurrent = parseInt(req.query.limit) || 10;
		const totalItems = results.length;
		const totalPages = Math.ceil(totalItems / limitCurrent);
		const startIndex = (pageCurrent - 1) * limitCurrent;
		const paginatedResults = results.slice(startIndex, startIndex + limitCurrent);

		res.status(200).json({
			message: `Tìm thấy ${totalItems} khách sạn phù hợp tại ${city}`,
			data: paginatedResults,
			pagination: {
				currentPage: pageCurrent,
				limit: limitCurrent,
				totalPages: totalPages,
				totalItems: totalItems
			}
		});
	} catch (error) {
		console.error("Lỗi tìm kiếm: ", error);
		res.status(500).json({ message: "Máy chủ đang bận, vui lòng thử lại sau!" });
	}
});

// ==========================================
// 3. API: Bộ lọc nâng cao + Sắp xếp (Filter & Sort + CÓ PHÂN TRANG)
// ==========================================
router.post('/filter', async (req, res) => {
	try {
		const { city, minPrice, maxPrice, minStar, requiredAmenities, sortBy } = req.body;

		let query = db.collection('Hotels');
		// Tìm theo field 'location'
		if (city) {
			query = query.where('location', '==', city);
		}
		const hotelSnapshot = await query.get();

		let filteredHotels = [];
		for (const doc of hotelSnapshot.docs) {
			let hotel = { id: doc.id, ...doc.data() };

			const roomSnap = await db.collection('RoomTypes')
				.where('hotelID', '==', hotel.ID || parseInt(doc.id))
				.get();
			let rooms = [];
			roomSnap.forEach(r => rooms.push({ id: r.id, ...r.data() }));

			hotel.rooms = rooms;
			hotel.minRoomPrice = rooms.length > 0 ? Math.min(...rooms.map(r => r.price)) : 0;
			filteredHotels.push(hotel);
		}

		if (minStar) {
			filteredHotels = filteredHotels.filter(h => h.star >= minStar);
		}
		if (requiredAmenities && requiredAmenities.length > 0) {
			filteredHotels = filteredHotels.filter(h => {
				const icons = (h.amenities || []).map(a => a.icon);
				return requiredAmenities.every(req => icons.includes(req));
			});
		}
		if (minPrice !== undefined || maxPrice !== undefined) {
			filteredHotels = filteredHotels.filter(h => {
				return h.rooms.some(r => {
					let passMin = minPrice !== undefined ? r.price >= minPrice : true;
					let passMax = maxPrice !== undefined ? r.price <= maxPrice : true;
					return passMin && passMax;
				});
			});
		}

		if (sortBy) {
			switch (sortBy) {
				case 'price_asc':
					filteredHotels.sort((a, b) => a.minRoomPrice - b.minRoomPrice);
					break;
				case 'price_desc':
					filteredHotels.sort((a, b) => b.minRoomPrice - a.minRoomPrice);
					break;
				case 'star_desc':
					filteredHotels.sort((a, b) => b.star - a.star);
					break;
			}
		}

		const pageCurrent = parseInt(req.query.page) || 1;
		const limitCurrent = parseInt(req.query.limit) || 10;
		const totalItems = filteredHotels.length;
		const totalPages = Math.ceil(totalItems / limitCurrent);
		const startIndex = (pageCurrent - 1) * limitCurrent;
		const paginatedHotels = filteredHotels.slice(startIndex, startIndex + limitCurrent);

		res.status(200).json({
			message: `Tìm thấy ${totalItems} khách sạn phù hợp`,
			data: paginatedHotels,
			pagination: {
				currentPage: pageCurrent,
				limit: limitCurrent,
				totalPages: totalPages,
				totalItems: totalItems
			}
		});
	} catch (error) {
		console.error("Lỗi khi lọc/sắp xếp: ", error);
		res.status(500).json({ message: "Lỗi Server!" });
	}
});

// ==========================================
// 4. API: Xem chi tiết 1 Khách sạn (kèm RoomTypes)
// ==========================================
router.get('/:id', async (req, res) => {
	try {
		const hotelId = req.params.id;
		const hotelRef = db.collection('Hotels').doc(hotelId);
		const hotelDoc = await hotelRef.get();

		if (!hotelDoc.exists) {
			return res.status(404).json({ message: "Khách sạn không tồn tại hoặc đã bị xóa!" });
		}

		const hotelData = { id: hotelDoc.id, ...hotelDoc.data() };

		// RoomType dùng field 'hotelID'
		const roomSnapshot = await db.collection('RoomTypes')
			.where('hotelID', '==', hotelData.ID || parseInt(hotelId))
			.get();
		const rooms = [];
		roomSnapshot.forEach(doc => {
			rooms.push({ id: doc.id, ...doc.data() });
		});
		hotelData.rooms = rooms;

		res.status(200).json({
			message: "Lấy thông tin chi tiết khách sạn thành công!",
			data: hotelData
		});
	} catch (error) {
		console.error("Lỗi khi lấy chi tiết khách sạn: ", error);
		res.status(500).json({ message: "Máy chủ đang bận!" });
	}
});

module.exports = router;
