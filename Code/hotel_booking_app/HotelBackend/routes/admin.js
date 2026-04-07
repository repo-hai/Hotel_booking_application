// File: routes/admin.js
const express = require('express');
const router = express.Router();
const db = require('../firebase');

// API: Lấy thống kê tổng quan cho Dashboard
router.get('/dashboard/stats', async (req, res) => {
	try {
		// Dùng Promise.all để chạy 4 lệnh đếm CÙNG MỘT LÚC (chạy song song)
		// Giúp API phản hồi nhanh gấp 4 lần so với việc chạy tuần tự từng cái
		const [usersSnap, hotelsSnap, bookingsSnap, vouchersSnap] = await Promise.all([
			db.collection('Users').count().get(),
			db.collection('Hotels').count().get(),
			db.collection('Bookings').count().get(),
			db.collection('Vouchers').count().get()
		]);

		// Trích xuất con số từ kết quả
		const totalUsers = usersSnap.data().count;
		const totalHotels = hotelsSnap.data().count;
		const totalBookings = bookingsSnap.data().count;
		const totalVouchers = vouchersSnap.data().count;

		// Trả về đúng định dạng JSON như ảnh thiết kế của em
		res.status(200).json({
			success: true,
			data: {
				totalUsers: totalUsers,
				totalHotels: totalHotels,
				totalBookings: totalBookings,
				totalVouchers: totalVouchers
			}
		});

	} catch (error) {
		console.error("Lỗi khi lấy thống kê Dashboard: ", error);
		res.status(500).json({
			success: false,
			message: "Lỗi hệ thống khi lấy dữ liệu thống kê!"
		});
	}
});

// API: Lấy danh sách 5 đơn đặt phòng mới nhất cho Dashboard
router.get('/dashboard/recent-bookings', async (req, res) => {
	try {
		// 1. Lấy 5 đơn mới nhất từ Firebase
		// Dùng .limit(5) để ngắt lệnh, tiết kiệm chi phí đọc dữ liệu
		const snapshot = await db.collection('Bookings')
			.orderBy('createdAt', 'desc')
			.limit(5)
			.get();

		const recentBookings = [];

		// 2. Duyệt qua từng đơn hàng và "xào nấu" lại dữ liệu cho đúng thiết kế UI
		snapshot.forEach(doc => {
			const data = doc.data();

			// Xử lý định dạng ngày tháng (Từ ISO sang DD/MM/YYYY)
			let formattedDate = "";
			if (data.createdAt) {
				const dateObj = new Date(data.createdAt);
				const day = String(dateObj.getDate()).padStart(2, '0');
				const month = String(dateObj.getMonth() + 1).padStart(2, '0'); // Tháng trong JS bắt đầu từ 0
				const year = dateObj.getFullYear();
				formattedDate = `${day}/${month}/${year}`;
			}

			// Đóng gói thành Object y hệt như thiết kế JSON của Hải
			recentBookings.push({
				id: doc.id, // Ở Firebase ID là chuỗi ký tự ngẫu nhiên
				hotelName: data.hotelName || "Khách sạn chưa cập nhật tên",
				guestName: data.customerName || "Khách ẩn danh",
				date: formattedDate || "N/A",
				status: data.status ? data.status.toLowerCase() : "pending" // Chuyển chữ thường cho giống ảnh
			});
		});

		// 3. Trả kết quả về cho Admin App
		res.status(200).json({
			success: true,
			data: recentBookings
		});

	} catch (error) {
		console.error("Lỗi khi lấy đơn hàng gần đây: ", error);
		res.status(500).json({
			success: false,
			message: "Lỗi hệ thống khi lấy dữ liệu đơn hàng gần đây!"
		});
	}
});

// API: Lấy danh sách user (Lọc theo type, tìm kiếm keyword, phân trang)
router.get('/users', async (req, res) => {
	try {
		// 1. Lấy các tham số từ Query URL
		const { type, search, page, limit } = req.query;

		let query = db.collection('Users');

		// 2. Lọc theo role (type) ngay từ Database (nếu App có truyền lên)
		// Lưu ý: Dữ liệu mẫu gieo hạt lúc trước có thể chưa có trường 'type', 
		// code dưới đây sẽ tự gán mặc định nếu thiếu.
		if (type) {
			query = query.where('type', '==', type);
		}

		const snapshot = await query.get();
		let usersList = [];

		// 3. Đổ dữ liệu ra mảng và định dạng lại cho đúng thiết kế JSON của em
		snapshot.forEach(doc => {
			const data = doc.data();
			usersList.push({
				id: doc.id,
				name: data.name || "Khách chưa cập nhật tên",
				phone: data.phone || "",
				email: data.email || "",
				type: data.type || "customer",     // Mặc định là customer
				status: data.status || "active",   // Mặc định là active
				joinDate: data.createdAt || new Date().toISOString(),
				avatarUrl: data.avatarUrl || null
			});
		});

		// 4. Bắt đầu tìm kiếm In-Memory (Tìm theo Tên hoặc Số điện thoại)
		if (search) {
			// Chuyển từ khóa về chữ thường để tìm kiếm không phân biệt hoa/thường
			const keyword = search.toLowerCase();
			usersList = usersList.filter(user => {
				const matchName = user.name.toLowerCase().includes(keyword);
				const matchPhone = user.phone.includes(keyword);
				// Trả về true nếu tên hoặc SĐT có chứa từ khóa
				return matchName || matchPhone;
			});
		}

		// 5. Bắt đầu phân trang In-Memory
		const currentPage = parseInt(page) || 1;
		const currentLimit = parseInt(limit) || 20; // Thiết kế của em mặc định là 20
		const totalItems = usersList.length;

		const startIndex = (currentPage - 1) * currentLimit;
		const endIndex = currentPage * currentLimit;
		const paginatedUsers = usersList.slice(startIndex, endIndex);

		// 6. Trả về đúng format như bức ảnh thiết kế
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
		res.status(500).json({
			success: false,
			message: "Lỗi hệ thống khi lấy danh sách người dùng!"
		});
	}
});

// API: Lấy chi tiết 1 User
// Lưu ý: Các route có chứa tham số động (như /:id) phải đặt ở dưới cùng
router.get('/users/:id', async (req, res) => {
	try {
		// 1. Lấy ID của user từ trên đường link
		const userId = req.params.id;

		// 2. Vào Firebase tìm đúng quyển sổ của user có ID đó
		const userRef = db.collection('Users').doc(userId);
		const userDoc = await userRef.get();

		// 3. Kiểm tra xem user có tồn tại không
		if (!userDoc.exists) {
			return res.status(404).json({
				success: false,
				message: "Không tìm thấy người dùng này hoặc tài khoản đã bị xóa!"
			});
		}

		// 4. Lấy dữ liệu và chuẩn hóa lại các trường thông tin
		const data = userDoc.data();

		const userInfo = {
			id: userDoc.id,
			name: data.name || "Khách chưa cập nhật tên",
			phone: data.phone || "Chưa cập nhật SĐT",
			email: data.email || "Chưa cập nhật Email",
			type: data.type || "customer",
			status: data.status || "active",
			joinDate: data.createdAt || new Date().toISOString(), // Lấy ngày tạo từ DB
			avatarUrl: data.avatarUrl || null,
			// Khuyến mãi thêm vài trường nếu DB có sẵn
			point: data.point || 0,
			membershipLevel: data.membershipLevel || "Silver"
		};

		// 5. Trả kết quả về cho Admin App
		res.status(200).json({
			success: true,
			data: userInfo
		});

	} catch (error) {
		console.error("Lỗi khi lấy chi tiết user: ", error);
		res.status(500).json({
			success: false,
			message: "Lỗi hệ thống khi lấy thông tin chi tiết!"
		});
	}
});

// API: Thay đổi trạng thái user (Khóa hoặc Mở khóa tài khoản)
// Dùng PATCH vì chúng ta chỉ cập nhật duy nhất 1 trường status
router.patch('/users/:id/status', async (req, res) => {
	try {
		const userId = req.params.id;
		const { status } = req.body; // Nhận 'active' hoặc 'locked' từ App

		// 1. Kiểm tra dữ liệu đầu vào xem có hợp lệ không
		if (!status || !['active', 'locked'].includes(status)) {
			return res.status(400).json({
				success: false,
				message: "Trạng thái không hợp lệ! Chỉ nhận 'active' hoặc 'locked'."
			});
		}

		// 2. Tìm User trong Database
		const userRef = db.collection('Users').doc(userId);
		const userDoc = await userRef.get();

		if (!userDoc.exists) {
			return res.status(404).json({
				success: false,
				message: "Không tìm thấy người dùng này!"
			});
		}

		// 3. Tiến hành cập nhật trạng thái
		await userRef.update({
			status: status,
			updatedAt: new Date().toISOString() // Mentor tặng thêm: Lưu lại thời gian bị khóa/mở khóa để sau này dễ tra cứu
		});

		// 4. Trả kết quả thành công
		res.status(200).json({
			success: true,
			message: status === 'locked' ? "Đã khóa tài khoản thành công!" : "Đã mở khóa tài khoản thành công!"
		});

	} catch (error) {
		console.error("Lỗi khi cập nhật trạng thái user: ", error);
		res.status(500).json({
			success: false,
			message: "Lỗi hệ thống khi cập nhật trạng thái!"
		});
	}
});

// ==========================================
// API: Xóa vĩnh viễn 1 User (Từ ảnh trước của em)
// ==========================================
router.delete('/users/:id', async (req, res) => {
	try {
		const userId = req.params.id;
		const userRef = db.collection('Users').doc(userId);
		const userDoc = await userRef.get();

		if (!userDoc.exists) {
			return res.status(404).json({
				success: false,
				message: "Không tìm thấy người dùng này!"
			});
		}

		// Thực hiện xóa vĩnh viễn khỏi Database
		await userRef.delete();

		res.status(200).json({
			success: true,
			message: "Xóa tài khoản thành công"
		});

	} catch (error) {
		console.error("Lỗi khi xóa user: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống!" });
	}
});

// ==========================================
// API: Lấy danh sách Đơn hàng cho Admin (Siêu bộ lọc)
// ==========================================
router.get('/bookings', async (req, res) => {
	try {
		// 1. Lấy tất cả tham số từ URL
		const { status, search, startDate, endDate, sortBy, page, limit } = req.query;

		// 2. Lọc cơ bản từ Database: Lọc theo status trước cho nhẹ máy
		let query = db.collection('Bookings');
		if (status) {
			query = query.where('status', '==', status);
		}

		const snapshot = await query.get();
		let bookingsList = [];

		snapshot.forEach(doc => {
			bookingsList.push({ id: doc.id, ...doc.data() });
		});

		// 3. LỌC THEO KHOẢNG THỜI GIAN (In-Memory)
		if (startDate || endDate) {
			bookingsList = bookingsList.filter(booking => {
				const bookingDate = new Date(booking.createdAt).getTime();
				let isPass = true;

				// Nếu có startDate, ngày đặt phải lớn hơn hoặc bằng startDate
				if (startDate) {
					isPass = isPass && (bookingDate >= new Date(startDate).getTime());
				}
				// Nếu có endDate, ngày đặt phải nhỏ hơn hoặc bằng endDate (đến cuối ngày)
				if (endDate) {
					// Cộng thêm 24h để bao gồm trọn vẹn ngày endDate
					const endOfDay = new Date(endDate).getTime() + 86399000;
					isPass = isPass && (bookingDate <= endOfDay);
				}
				return isPass;
			});
		}

		// 4. LỌC THEO TỪ KHÓA - TÌM KIẾM ĐA NĂNG (In-Memory)
		if (search) {
			const keyword = search.toLowerCase();
			bookingsList = bookingsList.filter(booking => {
				// Tìm trong Mã đơn, Tên khách và Tên khách sạn
				const matchId = booking.id.toLowerCase().includes(keyword);
				const matchCustomer = (booking.customerName || "").toLowerCase().includes(keyword);
				const matchHotel = (booking.hotelName || "").toLowerCase().includes(keyword);

				return matchId || matchCustomer || matchHotel;
			});
		}

		// 5. SẮP XẾP (Sorting)
		// Mặc định luôn sắp xếp đơn mới nhất lên đầu nếu không truyền sortBy
		if (sortBy) {
			switch (sortBy) {
				case 'oldest': // Cũ nhất lên đầu
					bookingsList.sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt));
					break;
				case 'price_desc': // Giá cao nhất xuống thấp
					bookingsList.sort((a, b) => (b.total || 0) - (a.total || 0));
					break;
				case 'price_asc': // Giá thấp lên cao
					bookingsList.sort((a, b) => (a.total || 0) - (b.total || 0));
					break;
				case 'newest': // Mới nhất lên đầu
				default:
					bookingsList.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
					break;
			}
		} else {
			bookingsList.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)); // Mặc định
		}

		// 6. PHÂN TRANG (Pagination)
		const currentPage = parseInt(page) || 1;
		const currentLimit = parseInt(limit) || 20;
		const totalItems = bookingsList.length;

		const startIndex = (currentPage - 1) * currentLimit;
		const endIndex = currentPage * currentLimit;
		const paginatedBookings = bookingsList.slice(startIndex, endIndex);

		// 7. Trả về kết quả
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
		res.status(500).json({
			success: false,
			message: "Lỗi hệ thống khi tải danh sách đơn hàng!"
		});
	}
});

// ==========================================
// API: Lấy danh sách Voucher cho Admin
// Hỗ trợ lọc theo status, tìm kiếm theo mã/tên, và phân trang
// ==========================================
router.get('/vouchers', async (req, res) => {
	try {
		// 1. Lấy các tham số từ Query URL
		const { status, search, page, limit } = req.query;

		let query = db.collection('Vouchers');

		// 2. Lọc theo trạng thái từ Database (vd: active, expired, disabled)
		if (status) {
			query = query.where('status', '==', status);
		}

		const snapshot = await query.get();
		let vouchersList = [];

		// 3. Đổ dữ liệu ra mảng và map lại các trường cho chuẩn với thiết kế JSON
		snapshot.forEach(doc => {
			const data = doc.data();
			vouchersList.push({
				id: doc.id,
				code: data.code || "",
				name: data.name || "Khuyến mãi chưa có tên",
				discountType: data.discountType || "percent",
				discountValue: data.discountValue || 0,
				maxDiscount: data.maxDiscount || 0,
				minSpend: data.minSpend || 0,
				usageLimit: data.usageLimit || 0,
				usedCount: data.usedCount || 0,
				startDate: data.startDate || null,
				endDate: data.endDate || null,
				targetType: data.targetType || "all",
				status: data.status || "active"
			});
		});

		// 4. Bắt đầu tìm kiếm In-Memory (Tìm theo Mã Voucher hoặc Tên chương trình)
		if (search) {
			const keyword = search.toLowerCase();
			vouchersList = vouchersList.filter(voucher => {
				const matchCode = (voucher.code || "").toLowerCase().includes(keyword);
				const matchName = (voucher.name || "").toLowerCase().includes(keyword);

				return matchCode || matchName;
			});
		}

		// 5. Phân trang In-Memory
		const currentPage = parseInt(page) || 1;
		const currentLimit = parseInt(limit) || 20; // Trùng khớp với thiết kế limit: 20
		const totalItems = vouchersList.length;

		const startIndex = (currentPage - 1) * currentLimit;
		const endIndex = currentPage * currentLimit;
		const paginatedVouchers = vouchersList.slice(startIndex, endIndex);

		// 6. Trả về đúng format Object bọc ngoài như ảnh thiết kế
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
		res.status(500).json({
			success: false,
			message: "Lỗi hệ thống khi lấy danh sách mã giảm giá!"
		});
	}
});

// ==========================================
// API: Lấy chi tiết 1 Voucher
// ==========================================
router.get('/vouchers/:id', async (req, res) => {
	try {
		// 1. Lấy ID của voucher từ trên đường link URL
		const voucherId = req.params.id;

		// 2. Tìm đúng document trong collection Vouchers
		const voucherRef = db.collection('Vouchers').doc(voucherId);
		const voucherDoc = await voucherRef.get();

		// 3. Kiểm tra xem voucher có tồn tại không
		if (!voucherDoc.exists) {
			return res.status(404).json({
				success: false,
				message: "Không tìm thấy mã giảm giá này hoặc đã bị xóa!"
			});
		}

		// 4. Lấy dữ liệu và chuẩn hóa lại các trường
		const data = voucherDoc.data();

		const voucherDetail = {
			id: voucherDoc.id,
			code: data.code || "",
			name: data.name || "Khuyến mãi chưa có tên",
			discountType: data.discountType || "percent",
			discountValue: data.discountValue || 0,
			maxDiscount: data.maxDiscount || 0,
			minSpend: data.minSpend || 0,
			usageLimit: data.usageLimit || 0,
			usedCount: data.usedCount || 0,
			startDate: data.startDate || null,
			endDate: data.endDate || null,
			targetType: data.targetType || "all",
			status: data.status || "active",
			// Mentor thêm phần mô tả chi tiết nếu trong DB em có lưu
			description: data.description || "Chưa có mô tả chi tiết cho khuyến mãi này."
		};

		// 5. Trả kết quả về cho Admin App
		res.status(200).json({
			success: true,
			data: voucherDetail
		});

	} catch (error) {
		console.error("Lỗi khi lấy chi tiết voucher: ", error);
		res.status(500).json({
			success: false,
			message: "Lỗi hệ thống khi tải chi tiết mã giảm giá!"
		});
	}
});

// ==========================================
// API: Tạo Voucher mới
// ==========================================
router.post('/vouchers', async (req, res) => {
	try {
		const {
			code, name, discountType, discountValue,
			maxDiscount, minSpend, usageLimit,
			startDate, endDate, targetType, status
		} = req.body;

		// 1. Kiểm tra xem Admin có nhập thiếu trường quan trọng nào không
		if (!code || !name || !discountType || discountValue === undefined || !startDate || !endDate) {
			return res.status(400).json({
				success: false,
				message: "Vui lòng điền đầy đủ các thông tin bắt buộc (Mã, Tên, Loại giảm giá, Giá trị, Ngày bắt đầu, Ngày kết thúc)!"
			});
		}

		// 2. Chuyển mã code thành CHỮ IN HOA để đồng bộ và kiểm tra trùng lặp
		const upperCode = code.toUpperCase();

		// Truy vấn xem mã này đã tồn tại trong Database chưa
		const existSnapshot = await db.collection('Vouchers').where('code', '==', upperCode).get();
		if (!existSnapshot.empty) {
			return res.status(400).json({
				success: false,
				message: `Mã voucher '${upperCode}' đã tồn tại! Vui lòng tạo mã khác.`
			});
		}

		// 3. Đóng gói dữ liệu để lưu vào Firebase
		const newVoucher = {
			code: upperCode,
			name: name,
			discountType: discountType, // 'percent' (phần trăm) hoặc 'fixed' (tiền mặt)
			discountValue: Number(discountValue),
			maxDiscount: Number(maxDiscount) || 0,
			minSpend: Number(minSpend) || 0,
			usageLimit: Number(usageLimit) || 0,
			usedCount: 0, // Voucher mới tạo thì số lượt đã dùng luôn luôn là 0
			startDate: startDate,
			endDate: endDate,
			targetType: targetType || "all",
			status: status || "active",
			createdAt: new Date().toISOString() // Lưu lại thời gian tạo
		};

		// 4. Lưu vào Collection 'Vouchers'
		const docRef = await db.collection('Vouchers').add(newVoucher);

		// 5. Trả kết quả về theo đúng chuẩn JSON thiết kế
		// Trả về mã status 201 (Created) để báo hiệu tạo mới thành công
		res.status(201).json({
			success: true,
			message: "Tạo voucher thành công",
			data: {
				id: docRef.id // Trả về ID tự sinh của Firebase (thay vì ID số 6 như ảnh mẫu)
			}
		});

	} catch (error) {
		console.error("Lỗi khi tạo voucher: ", error);
		res.status(500).json({
			success: false,
			message: "Lỗi hệ thống khi tạo mã giảm giá mới!"
		});
	}
});

// ==========================================
// API: Cập nhật thông tin Voucher
// ==========================================
router.put('/vouchers/:id', async (req, res) => {
	try {
		const voucherId = req.params.id;
		const {
			code, name, discountType, discountValue,
			maxDiscount, minSpend, usageLimit,
			startDate, endDate, targetType, status
		} = req.body;

		const voucherRef = db.collection('Vouchers').doc(voucherId);
		const voucherDoc = await voucherRef.get();

		// 1. Kiểm tra Voucher có tồn tại không
		if (!voucherDoc.exists) {
			return res.status(404).json({
				success: false,
				message: "Không tìm thấy mã giảm giá này!"
			});
		}

		const currentData = voucherDoc.data();
		let upperCode = currentData.code;

		// 2. Xử lý logic mã Code: Nếu Admin đổi mã Code mới, phải kiểm tra xem có trùng với mã KHÁC không
		if (code) {
			upperCode = code.toUpperCase();
			// Nếu mã mới khác mã cũ, tiến hành query kiểm tra trùng lặp
			if (upperCode !== currentData.code) {
				const existSnapshot = await db.collection('Vouchers').where('code', '==', upperCode).get();
				if (!existSnapshot.empty) {
					return res.status(400).json({
						success: false,
						message: `Mã voucher '${upperCode}' đã tồn tại ở một chương trình khác! Vui lòng chọn mã khác.`
					});
				}
			}
		}

		// 3. Tiến hành cập nhật dữ liệu (Chỉ cập nhật những trường được gửi lên, nếu không thì giữ nguyên dữ liệu cũ)
		await voucherRef.update({
			code: upperCode,
			name: name || currentData.name,
			discountType: discountType || currentData.discountType,
			discountValue: discountValue !== undefined ? Number(discountValue) : currentData.discountValue,
			maxDiscount: maxDiscount !== undefined ? Number(maxDiscount) : currentData.maxDiscount,
			minSpend: minSpend !== undefined ? Number(minSpend) : currentData.minSpend,
			usageLimit: usageLimit !== undefined ? Number(usageLimit) : currentData.usageLimit,
			startDate: startDate || currentData.startDate,
			endDate: endDate || currentData.endDate,
			targetType: targetType || currentData.targetType,
			status: status || currentData.status,
			updatedAt: new Date().toISOString() // Ghi vết thời gian chỉnh sửa
		});

		// 4. Trả kết quả thành công
		res.status(200).json({
			success: true,
			message: "Cập nhật voucher thành công"
		});

	} catch (error) {
		console.error("Lỗi khi cập nhật voucher: ", error);
		res.status(500).json({
			success: false,
			message: "Lỗi hệ thống khi cập nhật!"
		});
	}
});

// ==========================================
// API: Xóa vĩnh viễn Voucher
// ==========================================
router.delete('/vouchers/:id', async (req, res) => {
	try {
		const voucherId = req.params.id;
		const voucherRef = db.collection('Vouchers').doc(voucherId);
		const voucherDoc = await voucherRef.get();

		// 1. Kiểm tra tồn tại
		if (!voucherDoc.exists) {
			return res.status(404).json({
				success: false,
				message: "Không tìm thấy mã giảm giá này!"
			});
		}

		// 2. Xóa khỏi Firebase
		await voucherRef.delete();

		// 3. Trả kết quả theo đúng chuẩn thiết kế
		res.status(200).json({
			success: true,
			message: "Xóa voucher thành công"
		});

	} catch (error) {
		console.error("Lỗi khi xóa voucher: ", error);
		res.status(500).json({
			success: false,
			message: "Lỗi hệ thống khi xóa voucher!"
		});
	}
});

module.exports = router;