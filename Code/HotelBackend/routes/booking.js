// File: routes/booking.js
const express = require('express');
const router = express.Router();
const db = require('../firebase');
const { sendNotificationToOwner } = require('../utils/notifications');

// ==========================================
// API: Kiểm tra Voucher xem có dùng được không (Dành cho App Guest)
// ==========================================
router.post('/verify-voucher', async (req, res) => {
	try {
		const { code, amount } = req.body;
		if (!code) return res.status(400).json({ success: false, message: "Thiếu mã voucher!" });

		const snapshot = await db.collection('Vouchers').where('code', '==', code.toUpperCase()).get();
		if (snapshot.empty) return res.status(404).json({ success: false, message: "Mã voucher không tồn tại!" });

		const v = snapshot.docs[0].data();
		const now = new Date().toISOString();

		if (v.status !== 'active') return res.status(400).json({ success: false, message: "Voucher này hiện không sử dụng được!" });
		if (v.endDate && now > v.endDate) return res.status(400).json({ success: false, message: "Voucher đã hết hạn!" });
		if (v.usageLimit > 0 && v.usedCount >= v.usageLimit) return res.status(400).json({ success: false, message: "Voucher đã hết lượt sử dụng!" });
		if (v.minSpend > 0 && amount < v.minSpend) return res.status(400).json({ success: false, message: `Voucher này chỉ áp dụng cho đơn từ ${v.minSpend.toLocaleString()}VND` });

		res.status(200).json({ success: true, data: { id: snapshot.docs[0].id, ...v } });
	} catch (error) {
		res.status(500).json({ success: false, message: "Lỗi hệ thống!" });
	}
});

// ==========================================
// API: Tạo đơn đặt phòng mới (CÓ BẢO MẬT GIÁ + VOUCHER + THÔNG BÁO)
// ==========================================
router.post('/', async (req, res) => {
	try {
		const {
			userId,
			hotelId,
			hotelName,
			customerInfo, // Object chứa: firstName, lastName, email, phone, country
			checkIn,
			checkOut,
			bookedRooms, // Mảng các phòng khách chọn: [{ roomTypeId, quantity, price }]
			voucherId
		} = req.body;

		// Kiểm tra dữ liệu cơ bản (Validation)
		if (!hotelId || !customerInfo || !checkIn || !checkOut || !bookedRooms) {
			return res.status(400).json({ message: "Thiếu thông tin đặt phòng!" });
		}

		// 1. TÍNH TOÁN LẠI GIÁ TRÊN BACKEND (BẢO MẬT)
		let originalPrice = 0;
		for (const item of bookedRooms) {
			const rtDoc = await db.collection('RoomTypes').doc(item.roomTypeId).get();
			if (rtDoc.exists) {
				const pricePerNight = rtDoc.data().price || 0;
				originalPrice += (pricePerNight * (item.quantity || 1));
			}
		}

		// Tính số đêm
		const nights = Math.max(1, Math.ceil((new Date(checkOut) - new Date(checkIn)) / (1000 * 60 * 60 * 24)));
		originalPrice *= nights;

		// 2. ÁP DỤNG VOUCHER (NẾU CÓ)
		let discount = 0;
		if (voucherId) {
			const vDoc = await db.collection('Vouchers').doc(voucherId).get();
			if (vDoc.exists) {
				const v = vDoc.data();
				if (v.discountType === 'percent') {
					discount = (originalPrice * v.discountValue) / 100;
					if (v.maxDiscount > 0) discount = Math.min(discount, v.maxDiscount);
				} else {
					discount = v.discountValue;
				}
				// Cập nhật lượt dùng
				await db.collection('Vouchers').doc(voucherId).update({ usedCount: (v.usedCount || 0) + 1 });
			}
		}

		const totalPrice = Math.max(0, originalPrice - discount);

		// 3. Đóng gói dữ liệu để lưu vào Firebase
		const newBooking = {
			userId: userId || null,
			hotelId: hotelId,
			hotelName: hotelName,
			// Gộp Họ và Tên lại cho gọn theo UI
			customerName: `${customerInfo.lastName} ${customerInfo.firstName}`,
			customerEmail: customerInfo.email,
			customerPhone: customerInfo.phone,
			customerCountry: customerInfo.country,
			checkIn: checkIn,
			checkOut: checkOut,
			bookedRooms: bookedRooms, // Danh sách phòng đã chọn
			// Lưu thông tin thanh toán
			originalPrice: originalPrice,
			discount: discount,
			total: totalPrice,
			status: "Pending", // Đang chờ chủ khách sạn xác nhận
			createdAt: new Date().toISOString() // Giờ đặt phòng
		};

		// 4. Lưu vào Collection 'Bookings'
		const docRef = await db.collection('Bookings').add(newBooking);

		// 5. THÔNG BÁO CHO CHỦ SỞ HỮU
		try {
			const hotelDoc = await db.collection('Hotels').doc(hotelId).get();
			if (hotelDoc.exists) {
				const ownerId = hotelDoc.data().userId;
				if (ownerId) {
					await sendNotificationToOwner(ownerId, {
						title: "Đơn đặt phòng mới! 🏨",
						body: `Khách hàng ${newBooking.customerName} vừa đặt phòng tại ${hotelName}.`,
						type: "new_booking",
						data: { bookingId: docRef.id, hotelId: hotelId }
					});
				}
			}
		} catch (notifErr) {
			console.error("Lỗi khi gửi thông báo đặt phòng mới: ", notifErr);
		}

		// 6. Trả về thông báo thành công kèm theo Mã đơn hàng
		res.status(201).json({
			success: true,
			message: "Đặt phòng thành công!",
			bookingId: docRef.id,
			total: totalPrice,
			data: newBooking
		});

	} catch (error) {
		console.error("Lỗi khi tạo đơn đặt phòng: ", error);
		res.status(500).json({ success: false, message: "Lỗi hệ thống, vui lòng thử lại sau!" });
	}
});

// ==========================================
// API: Lấy danh sách đơn đặt phòng (CÓ PHÂN TRANG + Lọc theo status)
// ==========================================
router.get('/', async (req, res) => {
	try {
		const status = req.query.status;

		// 1. Lấy tham số phân trang từ query URL (Mặc định: Trang 1, giới hạn 10 đơn/trang)
		const page = parseInt(req.query.page) || 1;
		const limit = parseInt(req.query.limit) || 10;
		const offset = (page - 1) * limit; // Tính toán bỏ qua bao nhiêu bản ghi

		let query = db.collection('Bookings');

		// 2. Nếu có lọc theo status
		if (status) {
			query = query.where('status', '==', status);
		}

		// 3. Đếm tổng số bản ghi để tính toán tổng số trang
		const totalSnapshot = await query.count().get();
		const totalItems = totalSnapshot.data().count;
		const totalPages = Math.ceil(totalItems / limit);

		// 4. Áp dụng sắp xếp, bỏ qua (offset) và giới hạn (limit)
		const snapshot = await query.orderBy('createdAt', 'desc')
			.offset(offset)
			.limit(limit)
			.get();

		const bookingsList = [];

		// 5. Xử lý trường hợp không có dữ liệu
		if (snapshot.empty) {
			return res.status(200).json({
				message: status ? `Không có đơn hàng nào ở trạng thái ${status}.` : "Chưa có đơn đặt phòng nào.",
				data: [],
				pagination: {
					currentPage: page,
					limit: limit,
					totalPages: totalPages,
					totalItems: totalItems
				}
			});
		}

		// 6. Đổ dữ liệu vào mảng
		snapshot.forEach(doc => {
			bookingsList.push({
				id: doc.id,
				...doc.data()
			});
		});

		// 7. Trả kết quả chuẩn JSON kèm block 'pagination'
		res.status(200).json({
			message: "Lấy danh sách đơn hàng thành công!",
			data: bookingsList,
			pagination: {
				currentPage: page,
				limit: limit,
				totalPages: totalPages,
				totalItems: totalItems
			}
		});

	} catch (error) {
		console.error("Lỗi khi lấy danh sách đơn hàng: ", error);
		res.status(500).json({ message: "Không thể lấy dữ liệu đơn hàng!" });
	}
});

// ==========================================
// API: Khách hàng GỬI YÊU CẦU hủy phòng
// ==========================================
router.put('/:id/request-cancel', async (req, res) => {
	try {
		const bookingId = req.params.id;
		const { reason } = req.body;

		const bookingRef = db.collection('Bookings').doc(bookingId);
		const bookingDoc = await bookingRef.get();

		if (!bookingDoc.exists) {
			return res.status(404).json({ message: "Không tìm thấy đơn hàng!" });
		}

		// Cả đơn hàng "Confirmed" lẫn "Pending" đều được phép gửi yêu cầu hủy
		if (!['Confirmed', 'Pending'].includes(bookingDoc.data().status)) {
			return res.status(400).json({ message: "Chỉ đơn hàng đang hoạt động mới có thể gửi yêu cầu hủy!" });
		}

		// Đổi trạng thái sang "Cancel_Requested"
		await bookingRef.update({
			status: 'Cancel_Requested',
			cancellationReason: reason || "Khách hàng thay đổi kế hoạch",
			cancelRequestedAt: new Date().toISOString() // Lưu lại thời gian xin hủy
		});

		// THÔNG BÁO CHO CHỦ SỞ HỮU
		try {
			const hotelDoc = await db.collection('Hotels').doc(bookingDoc.data().hotelId).get();
			if (hotelDoc.exists) {
				const ownerId = hotelDoc.data().userId;
				if (ownerId) {
					await sendNotificationToOwner(ownerId, {
						title: "Yêu cầu hủy phòng! ⚠️",
						body: `Khách hàng ${bookingDoc.data().customerName} vừa yêu cầu hủy đơn đặt phòng #${bookingId}.`,
						type: "cancel_request",
						data: { bookingId: bookingId, hotelId: bookingDoc.data().hotelId }
					});
				}
			}
		} catch (notifErr) {
			console.error("Lỗi khi gửi thông báo yêu cầu hủy: ", notifErr);
		}

		res.status(200).json({ message: "Đã gửi yêu cầu hủy phòng đến chủ khách sạn!" });

	} catch (error) {
		console.error("Lỗi khi gửi yêu cầu hủy: ", error);
		res.status(500).json({ message: "Lỗi hệ thống!" });
	}
});

// ==========================================
// API: Admin XỬ LÝ yêu cầu hủy phòng (Duyệt hoặc Từ chối)
// ==========================================
router.put('/:id/handle-cancel', async (req, res) => {
	try {
		const bookingId = req.params.id;
		// App của Admin sẽ gửi lên action là 'approve' (đồng ý) hoặc 'reject' (từ chối)
		const { action, adminNote } = req.body;

		const bookingRef = db.collection('Bookings').doc(bookingId);
		const bookingDoc = await bookingRef.get();

		if (!bookingDoc.exists || bookingDoc.data().status !== 'Cancel_Requested') {
			return res.status(400).json({ message: "Đơn hàng này không nằm trong trạng thái chờ duyệt hủy!" });
		}

		if (action === 'approve') {
			// Chủ KS đồng ý hủy
			await bookingRef.update({
				status: 'Cancelled',
				cancelledAt: new Date().toISOString(),
				adminNote: adminNote || "Đã duyệt yêu cầu hủy" // Lời nhắn của chủ KS (vd: Phạt 20% tiền cọc)
			});
			res.status(200).json({ message: "Đã XÁC NHẬN hủy phòng thành công!" });

		} else if (action === 'reject') {
			// Chủ KS từ chối hủy, đơn hàng quay lại trạng thái bình thường
			await bookingRef.update({
				status: 'Confirmed',
				adminNote: adminNote || "Từ chối hủy do vi phạm quy định 24h"
			});
			res.status(200).json({ message: "Đã TỪ CHỐI yêu cầu hủy, đơn hàng vẫn có hiệu lực." });

		} else {
			res.status(400).json({ message: "Hành động không hợp lệ. Chỉ nhận 'approve' hoặc 'reject'." });
		}

	} catch (error) {
		console.error("Lỗi khi xử lý hủy phòng: ", error);
		res.status(500).json({ message: "Lỗi hệ thống!" });
	}
});

module.exports = router;
