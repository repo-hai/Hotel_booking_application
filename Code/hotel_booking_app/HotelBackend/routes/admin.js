// File: routes/admin.js
const express = require('express');
const router = express.Router();
const db = require('../firebase');

// API: Lấy thống kê tổng quan cho Dashboard
router.get('/dashboard/stats', async (req, res) => {
	try {
		const [usersSnap, hotelsSnap, bookingsSnap, vouchersSnap] = await Promise.all([
			db.collection('Users').count().get(),
			db.collection('Hotels').count().get(),
			db.collection('Bookings').count().get(),
			db.collection('Vouchers').count().get()
		]);

		res.status(200).json({
			success: true,
			data: {
				totalUsers: usersSnap.data().count,
				totalHotels: hotelsSnap.data().count,
				totalBookings: bookingsSnap.data().count,
				totalVouchers: vouchersSnap.data().count
			}
		});
	} catch (error) {
		console.error("Lỗi khi lấy thống kê Dashboard: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống khi lấy dữ liệu thống kê!" });
	}
});

// API: Lấy danh sách 5 đơn đặt phòng mới nhất cho Dashboard
router.get('/dashboard/recent-bookings', async (req, res) => {
	try {
		const snapshot = await db.collection('Bookings')
			.orderBy('createdAt', 'desc')
			.limit(5)
			.get();

		const recentBookings = [];
		snapshot.forEach(doc => {
			const data = doc.data();
			let formattedDate = "";
			if (data.createdAt) {
				const dateObj = new Date(data.createdAt);
				const day = String(dateObj.getDate()).padStart(2, '0');
				const month = String(dateObj.getMonth() + 1).padStart(2, '0');
				const year = dateObj.getFullYear();
				formattedDate = `${day}/${month}/${year}`;
			}
			recentBookings.push({
				id: doc.id,
				hotelName: data.hotelName || "Khách sạn chưa cập nhật tên",
				guestName: data.customerName || "Khách ẩn danh",
				date: formattedDate || "N/A",
				status: data.status ? data.status.toLowerCase() : "pending"
			});
		});

		res.status(200).json({ success: true, data: recentBookings });
	} catch (error) {
		console.error("Lỗi khi lấy đơn hàng gần đây: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống khi lấy dữ liệu đơn hàng gần đây!" });
	}
});

// ==========================================
// API: Lấy danh sách user (Lọc theo Role, tìm kiếm keyword, phân trang)
// Fields mới: ID, Email, Password, Phone, Name, Location, Gender,
//             DateOfBirth, MembershipLevel, Point, TotalSpent, Role
// ==========================================
router.get('/users', async (req, res) => {
	try {
		const { type, search, page, limit } = req.query;

		let query = db.collection('Users');

		// Lọc theo Role (admin/owner/user) — frontend truyền type=user hoặc type=owner
		if (type) {
			query = query.where('Role', '==', type);
		}

		const snapshot = await query.get();
		let usersList = [];

		snapshot.forEach(doc => {
			const data = doc.data();
			usersList.push({
				id: doc.id,
				name: data.Name || "Chưa cập nhật tên",
				phone: data.Phone || "",
				email: data.Email || "",
				role: data.Role || "user",
				location: data.Location || "",
				gender: data.Gender || "",
				dateOfBirth: data.DateOfBirth || null,
				membershipLevel: data.MembershipLevel || null,
				point: data.Point || 0,
				totalSpent: data.TotalSpent || 0
			});
		});

		// Tìm kiếm In-Memory theo Tên hoặc Số điện thoại
		if (search) {
			const keyword = search.toLowerCase();
			usersList = usersList.filter(user => {
				const matchName = user.name.toLowerCase().includes(keyword);
				const matchPhone = user.phone.includes(keyword);
				return matchName || matchPhone;
			});
		}

		// Phân trang In-Memory
		const currentPage = parseInt(page) || 1;
		const currentLimit = parseInt(limit) || 20;
		const totalItems = usersList.length;
		const startIndex = (currentPage - 1) * currentLimit;
		const paginatedUsers = usersList.slice(startIndex, startIndex + currentLimit);

		res.status(200).json({
			success: true,
			data: {
				users: paginatedUsers,
				total: totalItems,
				page: currentPage,
				limit: currentLimit
			}
		});
	} catch (error) {
		console.error("Lỗi khi lấy danh sách User: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống khi lấy danh sách người dùng!" });
	}
});

// API: Lấy chi tiết 1 User
router.get('/users/:id', async (req, res) => {
	try {
		const userId = req.params.id;
		const userRef = db.collection('Users').doc(userId);
		const userDoc = await userRef.get();

		if (!userDoc.exists) {
			return res.status(404).json({ success: false, message: "Không tìm thấy người dùng này!" });
		}

		const data = userDoc.data();
		const userInfo = {
			id: userDoc.id,
			name: data.Name || "Chưa cập nhật tên",
			phone: data.Phone || "",
			email: data.Email || "",
			role: data.Role || "user",
			location: data.Location || "",
			gender: data.Gender || "",
			dateOfBirth: data.DateOfBirth || null,
			membershipLevel: data.MembershipLevel || null,
			point: data.Point || 0,
			totalSpent: data.TotalSpent || 0
		};

		res.status(200).json({ success: true, data: userInfo });
	} catch (error) {
		console.error("Lỗi khi lấy chi tiết user: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống khi lấy thông tin chi tiết!" });
	}
});

// API: Xóa vĩnh viễn 1 User
router.delete('/users/:id', async (req, res) => {
	try {
		const userId = req.params.id;
		const userRef = db.collection('Users').doc(userId);
		const userDoc = await userRef.get();

		if (!userDoc.exists) {
			return res.status(404).json({ success: false, message: "Không tìm thấy người dùng này!" });
		}

		await userRef.delete();
		res.status(200).json({ success: true, message: "Xóa tài khoản thành công" });
	} catch (error) {
		console.error("Lỗi khi xóa user: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống!" });
	}
});

// ==========================================
// API: Lấy danh sách Đơn hàng cho Admin
// ==========================================
router.get('/bookings', async (req, res) => {
	try {
		const { status, search, startDate, endDate, sortBy, page, limit } = req.query;

		let query = db.collection('Bookings');
		if (status) {
			query = query.where('status', '==', status);
		}

		const snapshot = await query.get();
		let bookingsList = [];
		snapshot.forEach(doc => {
			bookingsList.push({ id: doc.id, ...doc.data() });
		});

		// Lọc theo khoảng thời gian
		if (startDate || endDate) {
			bookingsList = bookingsList.filter(booking => {
				const bookingDate = new Date(booking.createdAt).getTime();
				let isPass = true;
				if (startDate) isPass = isPass && (bookingDate >= new Date(startDate).getTime());
				if (endDate) isPass = isPass && (bookingDate <= new Date(endDate).getTime() + 86399000);
				return isPass;
			});
		}

		// Tìm kiếm đa năng
		if (search) {
			const keyword = search.toLowerCase();
			bookingsList = bookingsList.filter(booking => {
				const matchId = booking.id.toLowerCase().includes(keyword);
				const matchCustomer = (booking.customerName || "").toLowerCase().includes(keyword);
				const matchHotel = (booking.hotelName || "").toLowerCase().includes(keyword);
				return matchId || matchCustomer || matchHotel;
			});
		}

		// Sắp xếp
		const sortFn = {
			oldest: (a, b) => new Date(a.createdAt) - new Date(b.createdAt),
			price_desc: (a, b) => (b.total || 0) - (a.total || 0),
			price_asc: (a, b) => (a.total || 0) - (b.total || 0),
		};
		bookingsList.sort(sortFn[sortBy] || ((a, b) => new Date(b.createdAt) - new Date(a.createdAt)));

		// Phân trang
		const currentPage = parseInt(page) || 1;
		const currentLimit = parseInt(limit) || 20;
		const totalItems = bookingsList.length;
		const startIndex = (currentPage - 1) * currentLimit;
		const paginatedBookings = bookingsList.slice(startIndex, startIndex + currentLimit);

		res.status(200).json({
			success: true,
			data: {
				bookings: paginatedBookings,
				total: totalItems,
				page: currentPage,
				limit: currentLimit
			}
		});
	} catch (error) {
		console.error("Lỗi khi lấy danh sách Booking Admin: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống khi tải danh sách đơn hàng!" });
	}
});

// ==========================================
// API: Lấy danh sách Voucher cho Admin
// Fields mới: ID, Code, DiscountType ("Percentage"/"Fixed"), Value (decimal),
//             MaxDiscountValue, MinSpend, UsageLimit, Status, TargetType,
//             startDate, endDate, UsageHistory[]
// ==========================================
router.get('/vouchers', async (req, res) => {
	try {
		const { status, search, page, limit } = req.query;

		let query = db.collection('Vouchers');

		// Lọc theo Status từ Database (Active, Expired, Disabled)
		if (status) {
			query = query.where('Status', '==', status);
		}

		const snapshot = await query.get();
		let vouchersList = [];

		snapshot.forEach(doc => {
			const data = doc.data();
			const usageHistory = data.UsageHistory || [];
			vouchersList.push({
				id: doc.id,
				code: data.Code || "",
				discountType: data.DiscountType || "Percentage",
				value: data.Value || 0,
				maxDiscountValue: data.MaxDiscountValue || 0,
				minSpend: data.MinSpend || 0,
				usageLimit: data.UsageLimit || 0,
				usedCount: usageHistory.length,
				startDate: data.startDate || null,
				endDate: data.endDate || null,
				targetType: data.TargetType || "all",
				status: data.Status || "Active"
			});
		});

		// Tìm kiếm theo Mã Voucher
		if (search) {
			const keyword = search.toLowerCase();
			vouchersList = vouchersList.filter(voucher => {
				return (voucher.code || "").toLowerCase().includes(keyword);
			});
		}

		// Phân trang
		const currentPage = parseInt(page) || 1;
		const currentLimit = parseInt(limit) || 20;
		const totalItems = vouchersList.length;
		const startIndex = (currentPage - 1) * currentLimit;
		const paginatedVouchers = vouchersList.slice(startIndex, startIndex + currentLimit);

		res.status(200).json({
			success: true,
			data: {
				vouchers: paginatedVouchers,
				total: totalItems,
				page: currentPage,
				limit: currentLimit
			}
		});
	} catch (error) {
		console.error("Lỗi khi lấy danh sách Voucher: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống khi lấy danh sách mã giảm giá!" });
	}
});

// API: Lấy chi tiết 1 Voucher
router.get('/vouchers/:id', async (req, res) => {
	try {
		const voucherId = req.params.id;
		const voucherRef = db.collection('Vouchers').doc(voucherId);
		const voucherDoc = await voucherRef.get();

		if (!voucherDoc.exists) {
			return res.status(404).json({ success: false, message: "Không tìm thấy mã giảm giá này!" });
		}

		const data = voucherDoc.data();
		const usageHistory = data.UsageHistory || [];

		res.status(200).json({
			success: true,
			data: {
				id: voucherDoc.id,
				code: data.Code || "",
				discountType: data.DiscountType || "Percentage",
				value: data.Value || 0,
				maxDiscountValue: data.MaxDiscountValue || 0,
				minSpend: data.MinSpend || 0,
				usageLimit: data.UsageLimit || 0,
				usedCount: usageHistory.length,
				startDate: data.startDate || null,
				endDate: data.endDate || null,
				targetType: data.TargetType || "all",
				status: data.Status || "Active"
			}
		});
	} catch (error) {
		console.error("Lỗi khi lấy chi tiết voucher: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống khi tải chi tiết mã giảm giá!" });
	}
});

// API: Tạo Voucher mới
router.post('/vouchers', async (req, res) => {
	try {
		const {
			code, discountType, value,
			maxDiscountValue, minSpend, usageLimit,
			startDate, endDate, targetType, status
		} = req.body;

		if (!code || !discountType || value === undefined || !startDate || !endDate) {
			return res.status(400).json({
				success: false,
				message: "Vui lòng điền đầy đủ các thông tin bắt buộc!"
			});
		}

		const upperCode = code.toUpperCase();

		// Kiểm tra trùng mã
		const existSnapshot = await db.collection('Vouchers').where('Code', '==', upperCode).get();
		if (!existSnapshot.empty) {
			return res.status(400).json({
				success: false,
				message: `Mã voucher '${upperCode}' đã tồn tại!`
			});
		}

		const newVoucher = {
			Code: upperCode,
			DiscountType: discountType,
			Value: Number(value),
			MaxDiscountValue: Number(maxDiscountValue) || 0,
			MinSpend: Number(minSpend) || 0,
			UsageLimit: Number(usageLimit) || 0,
			startDate: startDate,
			endDate: endDate,
			TargetType: targetType || "all",
			Status: status || "Active",
			UsageHistory: []
		};

		const docRef = await db.collection('Vouchers').add(newVoucher);

		res.status(201).json({
			success: true,
			message: "Tạo voucher thành công",
			data: { id: docRef.id }
		});
	} catch (error) {
		console.error("Lỗi khi tạo voucher: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống khi tạo mã giảm giá mới!" });
	}
});

// API: Cập nhật thông tin Voucher
router.put('/vouchers/:id', async (req, res) => {
	try {
		const voucherId = req.params.id;
		const {
			code, discountType, value,
			maxDiscountValue, minSpend, usageLimit,
			startDate, endDate, targetType, status
		} = req.body;

		const voucherRef = db.collection('Vouchers').doc(voucherId);
		const voucherDoc = await voucherRef.get();

		if (!voucherDoc.exists) {
			return res.status(404).json({ success: false, message: "Không tìm thấy mã giảm giá này!" });
		}

		const currentData = voucherDoc.data();
		let upperCode = currentData.Code;

		if (code) {
			upperCode = code.toUpperCase();
			if (upperCode !== currentData.Code) {
				const existSnapshot = await db.collection('Vouchers').where('Code', '==', upperCode).get();
				if (!existSnapshot.empty) {
					return res.status(400).json({
						success: false,
						message: `Mã voucher '${upperCode}' đã tồn tại!`
					});
				}
			}
		}

		await voucherRef.update({
			Code: upperCode,
			DiscountType: discountType || currentData.DiscountType,
			Value: value !== undefined ? Number(value) : currentData.Value,
			MaxDiscountValue: maxDiscountValue !== undefined ? Number(maxDiscountValue) : currentData.MaxDiscountValue,
			MinSpend: minSpend !== undefined ? Number(minSpend) : currentData.MinSpend,
			UsageLimit: usageLimit !== undefined ? Number(usageLimit) : currentData.UsageLimit,
			startDate: startDate || currentData.startDate,
			endDate: endDate || currentData.endDate,
			TargetType: targetType || currentData.TargetType,
			Status: status || currentData.Status
		});

		res.status(200).json({ success: true, message: "Cập nhật voucher thành công" });
	} catch (error) {
		console.error("Lỗi khi cập nhật voucher: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống khi cập nhật!" });
	}
});

// API: Xóa vĩnh viễn Voucher
router.delete('/vouchers/:id', async (req, res) => {
	try {
		const voucherId = req.params.id;
		const voucherRef = db.collection('Vouchers').doc(voucherId);
		const voucherDoc = await voucherRef.get();

		if (!voucherDoc.exists) {
			return res.status(404).json({ success: false, message: "Không tìm thấy mã giảm giá này!" });
		}

		await voucherRef.delete();
		res.status(200).json({ success: true, message: "Xóa voucher thành công" });
	} catch (error) {
		console.error("Lỗi khi xóa voucher: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống khi xóa voucher!" });
	}
});

module.exports = router;
