// File: routes/owner.js
const express = require('express');
const router = express.Router();
const db = require('../firebase');
const { sendNotificationToUser } = require('../utils/notifications');
const multer = require('multer');
const path = require('path');

// Cấu hình Multer để upload ảnh
const storage = multer.diskStorage({
	destination: function (req, file, cb) {
		cb(null, 'public/uploads/');
	},
	filename: function (req, file, cb) {
		const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
		cb(null, uniqueSuffix + path.extname(file.originalname));
	}
});
const upload = multer({ storage: storage });

// POST /api/owner/upload - Upload file và trả về URL
router.post('/upload', upload.single('image'), (req, res) => {
	try {
		if (!req.file) return res.status(400).json({ success: false, message: 'No file uploaded' });
		// Lấy domain hiện tại, ở đây ta dùng localhost:3000 làm mặc định.
		// Bạn có thể tùy biến khi deploy.
		const fileUrl = `http://localhost:3000/uploads/${req.file.filename}`;
		res.status(200).json({ success: true, url: fileUrl });
	} catch (error) {
		res.status(500).json({ success: false, message: 'Upload error' });
	}
});

// ==========================================
// 1. HOTEL MANAGEMENT
// ==========================================

// GET /api/owner/:ownerId/hotels - Lấy danh sách khách sạn của chủ sở hữu
router.get('/:ownerId/hotels', async (req, res) => {
	try {
		const { ownerId } = req.params;
		const snapshot = await db.collection('Hotels').where('userId', '==', ownerId).get();
		const hotels = [];
		snapshot.forEach(doc => hotels.push({ id: doc.id, ...doc.data() }));
		res.status(200).json({ success: true, data: hotels });
	} catch (error) {
		console.error("Lỗi khi lấy danh sách khách sạn: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống!" });
	}
});

// POST /api/owner/hotels - Tạo khách sạn mới (Có hỗ trợ Policies)
router.post('/hotels', async (req, res) => {
	try {
		const {
			userId, name, type, description, telephone, email, address, city, star, images, amenities,
			checkInTime, checkOutTime, cancellationPolicy
		} = req.body;

		if (!userId || !name) {
			return res.status(400).json({ success: false, message: "Thiếu thông tin bắt buộc!" });
		}

		const newHotel = {
			userId, name,
			type: type || "Hotel",
			description: description || "",
			telephone: telephone || "",
			email: email || "",
			address: address || "",
			city: city || "",
			lat: Number(req.body.lat) || 0, // Hỗ trợ tọa độ từ bản đồ
			lng: Number(req.body.lng) || 0,
			star: Number(star) || 1,
			images: images || [],
			amenities: amenities || [],
			checkInTime: checkInTime || "14:00",
			checkOutTime: checkOutTime || "12:00",
			cancellationPolicy: cancellationPolicy || "Linh hoạt",
			createdAt: new Date().toISOString()
		};

		const docRef = await db.collection('Hotels').add(newHotel);
		res.status(201).json({ success: true, data: { id: docRef.id, ...newHotel } });
	} catch (error) {
		console.error("Lỗi khi tạo khách sạn: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống!" });
	}
});

// PUT /api/owner/hotels/:id - Cập nhật thông tin khách sạn (Có hỗ trợ Policies)
router.put('/hotels/:id', async (req, res) => {
	try {
		const { id } = req.params;
		const updateData = { ...req.body, updatedAt: new Date().toISOString() };

		if (updateData.star) updateData.star = Number(updateData.star);

		await db.collection('Hotels').doc(id).update(updateData);
		res.status(200).json({ success: true, message: "Cập nhật thành công!" });
	} catch (error) {
		console.error("Lỗi khi cập nhật khách sạn: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống!" });
	}
});

// DELETE /api/owner/hotels/:id - Xóa khách sạn
router.delete('/hotels/:id', async (req, res) => {
	try {
		const { id } = req.params;
		await db.collection('Hotels').doc(id).delete();
		res.status(200).json({ success: true, message: "Đã xóa khách sạn!" });
	} catch (error) {
		console.error("Lỗi khi xóa khách sạn: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống!" });
	}
});

// ==========================================
// 2. ROOM MANAGEMENT
// ==========================================

// GET /api/owner/hotels/:hotelId/room-types - Lấy danh sách hạng phòng
router.get('/hotels/:hotelId/room-types', async (req, res) => {
	try {
		const { hotelId } = req.params;
		const snapshot = await db.collection('RoomTypes').where('hotelId', '==', hotelId).get();
		const roomTypes = [];
		snapshot.forEach(doc => roomTypes.push({ id: doc.id, ...doc.data() }));
		res.status(200).json({ success: true, data: roomTypes });
	} catch (error) {
		console.error("Lỗi khi lấy danh sách hạng phòng: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống!" });
	}
});

// POST /api/owner/room-types - Thêm hạng phòng mới
router.post('/room-types', async (req, res) => {
	try {
		const { hotelId, name, price, capacity, area, description, bedType, bedNum, images, amenities, rooms, cancellationPolicy } = req.body;
		const newRoomType = {
			hotelId, name,
			price: Number(price) || 0,
			capacity: Number(capacity) || 1,
			area: Number(area) || 0,
			description: description || "",
			bedType: bedType || "",
			bedNum: Number(bedNum) || 1,
			images: images || [],
			amenities: amenities || [],
			rooms: rooms || [],
			cancellationPolicy: cancellationPolicy || "Không thể hoàn trả",
			createdAt: new Date().toISOString()
		};
		const docRef = await db.collection('RoomTypes').add(newRoomType);
		res.status(201).json({ success: true, data: { id: docRef.id, ...newRoomType } });
	} catch (error) {
		console.error("Lỗi khi tạo hạng phòng: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống!" });
	}
});

// PATCH /api/owner/room-types/:roomTypeId/rooms - Quản lý danh sách phòng vật lý
router.patch('/room-types/:roomTypeId/rooms', async (req, res) => {
	try {
		const { roomTypeId } = req.params;
		const { rooms } = req.body;
		await db.collection('RoomTypes').doc(roomTypeId).update({ rooms, updatedAt: new Date().toISOString() });
		res.status(200).json({ success: true, message: "Cập nhật danh sách phòng thành công!" });
	} catch (error) {
		console.error("Lỗi khi cập nhật phòng: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống!" });
	}
});

// PUT /api/owner/room-types/:id - Cập nhật toàn bộ thông tin hạng phòng
router.put('/room-types/:id', async (req, res) => {
	try {
		const { id } = req.params;
		const updateData = { ...req.body, updatedAt: new Date().toISOString() };

		if (updateData.price) updateData.price = Number(updateData.price);
		if (updateData.capacity) updateData.capacity = Number(updateData.capacity);

		await db.collection('RoomTypes').doc(id).update(updateData);
		res.status(200).json({ success: true, message: "Cập nhật hạng phòng thành công!" });
	} catch (error) {
		console.error("Lỗi khi cập nhật hạng phòng: ", error);
		res.status(500).json({ success: false, message: "Lỗi nội bộ!" });
	}
});

// PATCH /api/owner/room-types/:roomTypeId/price-logic - Cập nhật giá theo logic thiết kế ở frontend (Weekdays/Weekends)
router.patch('/room-types/:roomTypeId/price-logic', async (req, res) => {
	try {
		const { roomTypeId } = req.params;
		const { type, price } = req.body; // type: 'all', 'weekdays', 'weekends'

		const updateData = { updatedAt: new Date().toISOString() };
		const numPrice = Number(price) || 0;

		if (type === 'all') {
			updateData.price = numPrice;
			updateData.weekdayPrice = numPrice;
			updateData.weekendPrice = numPrice;
		} else if (type === 'weekdays') {
			updateData.weekdayPrice = numPrice;
		} else if (type === 'weekends') {
			updateData.weekendPrice = numPrice;
		}

		await db.collection('RoomTypes').doc(roomTypeId).update(updateData);
		res.status(200).json({ success: true, message: `Đã cập nhật giá ${type} thành công!` });
	} catch (error) {
		console.error("Lỗi cập nhật giá logic: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống!" });
	}
});

// ==========================================
// 3. BOOKING MANAGEMENT
// ==========================================

// GET /api/owner/hotels/:hotelId/bookings - Lấy danh sách đơn (Có lọc theo status thiết kế ở frontend)
router.get('/hotels/:hotelId/bookings', async (req, res) => {
	try {
		const { hotelId } = req.params;
		const { status } = req.query; // 'Pending', 'Confirmed' (Sắp tới), 'Completed', 'Cancelled'

		// 1. Fetch RoomTypes first to map ID -> Name
		const roomTypesSnap = await db.collection('RoomTypes').where('hotelId', '==', hotelId).get();
		const roomTypeNameMap = {};
		roomTypesSnap.forEach(doc => {
			roomTypeNameMap[doc.id] = doc.data().name;
		});

		let query = db.collection('Bookings').where('hotelId', '==', hotelId);
		if (status) {
			query = query.where('status', '==', status);
		}

		const snapshot = await query.get();
		const bookings = [];
		snapshot.forEach(doc => {
			const data = doc.data();

			// Map room type name
			let roomTypeName = Object.values(roomTypeNameMap)[0] || "Standard"; // Mặc định lấy tên hạng phòng đầu tiên hoặc Standard
			if (data.bookedRooms && data.bookedRooms.length > 0) {
				roomTypeName = data.bookedRooms[0].roomTypeName || roomTypeNameMap[data.bookedRooms[0].roomTypeId] || roomTypeName;
			} else if (data.roomTypeId) {
				roomTypeName = roomTypeNameMap[data.roomTypeId] || roomTypeName;
			}

			bookings.push({
				id: doc.id,
				...data,
				roomTypeName: roomTypeName
			});
		});

		bookings.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
		res.status(200).json({ success: true, data: bookings });
	} catch (error) {
		console.error("Lỗi khi lấy đơn: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống!" });
	}
});

// PATCH /api/owner/bookings/:bookingId/status - Duyệt/Từ chối (Hỗ trợ Reject Reason)
router.patch('/bookings/:bookingId/status', async (req, res) => {
	try {
		const { bookingId } = req.params;
		const { status, rejectReason, adminNote } = req.body;

		const updateData = { status, updatedAt: new Date().toISOString() };
		if (status === 'Cancelled' && rejectReason) updateData.rejectReason = rejectReason;
		if (adminNote) updateData.adminNote = adminNote;

		await db.collection('Bookings').doc(bookingId).update(updateData);

		// THÔNG BÁO CHO KHÁCH HÀNG (GUEST)
		try {
			const bookingDoc = await db.collection('Bookings').doc(bookingId).get();
			if (bookingDoc.exists) {
				const guestId = bookingDoc.data().userId;
				const hotelName = bookingDoc.data().hotelName || "Khách sạn";

				let title = "Cập nhật đơn đặt phòng! 🏨";
				let body = `Đơn của bạn tại ${hotelName} đã được chuyển sang trạng thái: ${status}`;

				if (status === 'Confirmed') {
					title = "Đơn đặt phòng đã được xác nhận! 🎉";
					body = `Chúc mừng! Chủ khách sạn ${hotelName} đã xác nhận đơn của bạn.`;
				} else if (status === 'Cancelled') {
					title = "Đơn đặt phòng bị hủy ❌";
					body = `Rất tiếc, chủ khách sạn ${hotelName} đã hủy đơn của bạn${rejectReason ? ': ' + rejectReason : '.'}`;
				}

				if (guestId) {
					await sendNotificationToUser(guestId, {
						title, body, type: "booking_update",
						data: { bookingId, status }
					});
				}
			}
		} catch (notifErr) { console.error("Lỗi gửi thông báo cho khách: ", notifErr); }

		res.status(200).json({ success: true, message: `Đã cập nhật đơn hàng thành: ${status}` });
	} catch (error) {
		console.error("Lỗi cập nhật đơn: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống!" });
	}
});

// ==========================================
// 4. STATISTICS & ANALYTICS
// ==========================================

// GET /api/owner/hotels/:hotelId/statistics - Thống kê (Có lọc theo ngày thiết kế ở frontend)
router.get('/hotels/:hotelId/statistics', async (req, res) => {
	try {
		const { hotelId } = req.params;
		const { startDate, endDate } = req.query; // Định dạng YYYY-MM-DD

		// 1. Fetch RoomTypes first to have ID -> Name map
		const roomTypesSnap = await db.collection('RoomTypes').where('hotelId', '==', hotelId).get();
		const roomTypeNameMap = {};
		roomTypesSnap.forEach(doc => {
			roomTypeNameMap[doc.id] = doc.data().name;
		});

		const bookingsSnap = await db.collection('Bookings').where('hotelId', '==', hotelId).get();
		let totalRevenue = 0, confirmed = 0, cancelled = 0;
		const roomTypeStats = {};

		bookingsSnap.forEach(doc => {
			const data = doc.data();
			const createdDate = data.createdAt.split('T')[0];

			// Áp dụng bộ lọc ngày nếu có
			if (startDate && createdDate < startDate) return;
			if (endDate && createdDate > endDate) return;

			if (data.status === 'Confirmed' || data.status === 'Checked-out' || data.status === 'Checked-in') {
				totalRevenue += (data.total || 0);
				confirmed++;

				// Track room type counts
				if (data.bookedRooms && data.bookedRooms.length > 0) {
					data.bookedRooms.forEach(room => {
						let name = room.roomTypeName || roomTypeNameMap[room.roomTypeId];
						if (!name && room.roomTypeId === 'roomtype_1') name = "Phòng Standard";
						name = name || "Hạng phòng";
						roomTypeStats[name] = (roomTypeStats[name] || 0) + (room.quantity || 1);
					});
				} else if (data.roomTypeId) {
					let name = roomTypeNameMap[data.roomTypeId];
					if (!name && data.roomTypeId === 'roomtype_1') name = "Phòng Standard";
					name = name || "Hạng phòng";
					roomTypeStats[name] = (roomTypeStats[name] || 0) + 1;
				}
			} else if (data.status === 'Cancelled') {
				cancelled++;
			}
		});

		let mostPopularRoom = "Phòng Standard", maxRooms = 0;
		if (Object.keys(roomTypeStats).length > 0) {
			mostPopularRoom = "N/A";
			for (const [name, count] of Object.entries(roomTypeStats)) {
				if (count > maxRooms) { maxRooms = count; mostPopularRoom = name; }
			}
		}

		res.status(200).json({
			success: true,
			data: {
				totalRevenue,
				totalBookings: confirmed,
				cancelledBookings: cancelled,
				mostPopularRoom,
				mostPopularRoomCount: maxRooms
			}
		});
	} catch (error) {
		console.error("Lỗi thống kê: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống!" });
	}
});

// GET /api/owner/hotels/:hotelId/revenue-report - Biểu đồ doanh thu
router.get('/hotels/:hotelId/revenue-report', async (req, res) => {
	try {
		const { hotelId } = req.params;
		const { startDate, endDate } = req.query;
		const snapshot = await db.collection('Bookings').where('hotelId', '==', hotelId).get();
		const report = {};
		snapshot.forEach(doc => {
			const data = doc.data();
			if (data.status !== 'Cancelled') {
				const date = data.createdAt.split('T')[0];
				if (startDate && date < startDate) return;
				if (endDate && date > endDate) return;
				report[date] = (report[date] || 0) + (data.total || 0);
			}
		});
		const reportArray = Object.keys(report).sort().map(date => ({ date, revenue: report[date] }));
		res.status(200).json({ success: true, data: reportArray });
	} catch (error) {
		res.status(500).json({ success: false, message: "Lỗi hệ thống!" });
	}
});

// ==========================================
// 5. REVIEW MANAGEMENT
// ==========================================

router.get('/hotels/:hotelId/reviews', async (req, res) => {
	try {
		const { hotelId } = req.params;
		const snapshot = await db.collection('Bookings').where('hotelId', '==', hotelId).get();
		const reviews = [];
		snapshot.forEach(doc => {
			if (doc.data().review) reviews.push({ bookingId: doc.id, customerName: doc.data().customerName, ...doc.data().review });
		});
		res.status(200).json({ success: true, data: reviews });
	} catch (error) {
		res.status(500).json({ success: false, message: "Lỗi hệ thống!" });
	}
});

router.get('/hotels/:hotelId/reviews/summary', async (req, res) => {
	try {
		const { hotelId } = req.params;
		const snapshot = await db.collection('Bookings').where('hotelId', '==', hotelId).get();
		const dist = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
		let totalRating = 0, count = 0;
		snapshot.forEach(doc => {
			const r = doc.data().review;
			if (r && r.rating) {
				const s = Math.round(r.rating);
				if (dist[s] !== undefined) { dist[s]++; totalRating += r.rating; count++; }
			}
		});
		res.status(200).json({
			success: true,
			data: {
				averageRating: count > 0 ? (totalRating / count).toFixed(1) : 0,
				totalCount: count, // Hỗ trợ hiển thị "Reviews (532)" ở frontend
				stars: dist
			}
		});
	} catch (error) {
		res.status(500).json({ success: false, message: "Lỗi hệ thống!" });
	}
});

// ==========================================
// 6. UTILITIES & OPS
// ==========================================

router.get('/utilities/amenities', (req, res) => {
	const list = [
		{ id: 1, name: "Wifi", icon: "wifi" }, { id: 2, name: "Pool", icon: "pool" },
		{ id: 3, name: "Gym", icon: "fitness_center" }, { id: 4, name: "Parking", icon: "local_parking" },
		{ id: 5, name: "Kitchen", icon: "kitchen" }, { id: 6, name: "AC", icon: "ac_unit" }
	];
	res.status(200).json({ success: true, data: list });
});

router.patch('/bookings/:bookingId/status', async (req, res) => {
	try {
		const { bookingId } = req.params;
		const { status, rejectReason, assignedRoomNumber } = req.body;

		const updateData = { status, updatedAt: new Date().toISOString() };
		if (rejectReason) updateData.rejectReason = rejectReason;
		if (assignedRoomNumber) updateData.assignedRoomNumber = assignedRoomNumber;

		await db.collection('Bookings').doc(bookingId).update(updateData);
		res.status(200).json({ success: true, message: `Booking status updated to ${status}` });
	} catch (error) {
		console.error("Lỗi cập nhật trạng thái đơn hàng:", error);
		res.status(500).json({ success: false, message: "Lỗi server!" });
	}
});

router.patch('/bookings/:bookingId/check-in', async (req, res) => {
	try {
		await db.collection('Bookings').doc(req.params.bookingId).update({ status: 'Checked-in', checkInTime: new Date().toISOString() });
		res.status(200).json({ success: true, message: "Checked-in!" });
	} catch (error) { res.status(500).json({ success: false }); }
});

router.patch('/bookings/:bookingId/check-out', async (req, res) => {
	try {
		await db.collection('Bookings').doc(req.params.bookingId).update({ status: 'Checked-out', checkOutTime: new Date().toISOString() });
		res.status(200).json({ success: true, message: "Checked-out!" });
	} catch (error) { res.status(500).json({ success: false }); }
});

// ==========================================
// 7. DASHBOARD & FINANCIALS
// ==========================================

router.get('/dashboard/:ownerId', async (req, res) => {
	try {
		const { ownerId } = req.params;
		const { hotelId } = req.query;
		let hotelIds = [];
		if (hotelId) {
			hotelIds = [hotelId];
		} else {
			const hotelsSnap = await db.collection('Hotels').where('userId', '==', ownerId).get();
			hotelIds = hotelsSnap.docs.map(doc => doc.id);
		}

		if (hotelIds.length === 0) return res.status(200).json({ success: true, data: { pending: 0, revenue: 0 } });

		const today = new Date().toISOString().split('T')[0];
		const bookingsSnap = await db.collection('Bookings').where('hotelId', 'in', hotelIds.slice(0, 10)).get();
		let pending = 0, checkIn = 0, checkOut = 0, revenue = 0;
		const now = new Date();
		const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1).getTime();

		bookingsSnap.forEach(doc => {
			const data = doc.data();
			if (data.status === 'Confirmed') pending++;
			if (data.checkIn && data.checkIn.includes(today)) checkIn++;
			if (data.checkOut && data.checkOut.includes(today)) checkOut++;
			const created = new Date(data.createdAt).getTime();
			if (created >= startOfMonth && data.status !== 'Cancelled') revenue += (data.total || 0);
		});

		res.status(200).json({ success: true, data: { pending, checkInToday: checkIn, checkOutToday: checkOut, revenueCurrentMonth: revenue, hotelCount: hotelIds.length } });
	} catch (error) { res.status(500).json({ success: false }); }
});

router.get('/:ownerId/financials', async (req, res) => {
	try {
		const { ownerId } = req.params;
		const hotelsSnap = await db.collection('Hotels').where('userId', '==', ownerId).get();
		const hotelIds = hotelsSnap.docs.map(doc => doc.id);
		if (hotelIds.length === 0) return res.status(200).json({ success: true, data: { totalIncome: 0 } });
		const paysSnap = await db.collection('Payments').where('hotelId', 'in', hotelIds.slice(0, 10)).get();
		let income = 0;
		const list = [];
		paysSnap.forEach(doc => {
			const d = doc.data();
			if (d.status === 'Paid' || d.status === 'Completed') income += (d.amount || 0);
			list.push({ id: doc.id, ...d });
		});
		res.status(200).json({ success: true, data: { totalIncome: income, payments: list } });
	} catch (error) { res.status(500).json({ success: false }); }
});

// ==========================================
// 8. NOTIFICATIONS
// ==========================================

router.get('/:ownerId/notifications', async (req, res) => {
	try {
		const snap = await db.collection('Notifications').where('userId', '==', req.params.ownerId).orderBy('createdAt', 'desc').get();
		const list = [];
		snap.forEach(doc => list.push({ id: doc.id, ...doc.data() }));
		res.status(200).json({ success: true, data: list });
	} catch (error) { res.status(500).json({ success: false }); }
});

router.patch('/notifications/:id/read', async (req, res) => {
	try {
		await db.collection('Notifications').doc(req.params.id).update({ isRead: true });
		res.status(200).json({ success: true });
	} catch (error) { res.status(500).json({ success: false }); }
});

// DELETE /api/owner/room-types/:id - Xóa hạng phòng
router.delete('/room-types/:id', async (req, res) => {
	try {
		const { id } = req.params;
		await db.collection('RoomTypes').doc(id).delete();
		res.status(200).json({ success: true, message: "Đã xóa hạng phòng!" });
	} catch (error) {
		console.error("Lỗi khi xóa hạng phòng: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống!" });
	}
});

// GET /api/owner/utilities/room-amenities - Danh sách tiện nghi phòng (cho model RoomAmenity)
router.get('/utilities/room-amenities', (req, res) => {
	const list = [
		{ id: 101, name: "Máy lạnh (AC)", icon: "ac_unit" },
		{ id: 102, name: "Tivi màn hình phẳng", icon: "tv" },
		{ id: 103, name: "Minibar", icon: "kitchen" },
		{ id: 104, name: "Bồn tắm", icon: "bathtub" },
		{ id: 105, name: "Ban công", icon: "balcony" },
		{ id: 106, name: "Máy sấy tóc", icon: "air" }
	];
	res.status(200).json({ success: true, data: list });
});

// GET /api/owner/:ownerId/financial-summary - Tóm tắt thu nhập (cho Profile)
router.get('/:ownerId/financial-summary', async (req, res) => {
	try {
		const { ownerId } = req.params;
		const hotelsSnap = await db.collection('Hotels').where('userId', '==', ownerId).get();
		const hotelIds = hotelsSnap.docs.map(doc => doc.id);

		if (hotelIds.length === 0) return res.status(200).json({ success: true, data: { totalEarnings: 0 } });

		const paysSnap = await db.collection('Payments').where('hotelId', 'in', hotelIds.slice(0, 10)).get();
		let total = 0;
		paysSnap.forEach(doc => {
			if (doc.data().status === 'Paid' || doc.data().status === 'Completed') {
				total += (doc.data().amount || 0);
			}
		});

		res.status(200).json({ success: true, data: { totalEarnings: total } });
	} catch (error) {
		console.error("Lỗi summary: ", error);
		res.status(500).json({ success: false });
	}
});

module.exports = router;
