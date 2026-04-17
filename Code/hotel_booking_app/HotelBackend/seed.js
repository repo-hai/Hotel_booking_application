const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
	credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const cities = ["Hà Nội", "Nha Trang", "Đà Lạt", "Đà Nẵng", "Phú Quốc", "Hồ Chí Minh", "Vũng Tàu"];

const hotelTypes = ["Khách sạn", "Resort", "Villa", "Homestay", "Căn hộ dịch vụ"];

const amenityPool = [
	{ ID: 1, name: "WiFi miễn phí", icon: "wifi" },
	{ ID: 2, name: "Hồ bơi", icon: "pool" },
	{ ID: 3, name: "Bãi đỗ xe", icon: "parking" },
	{ ID: 4, name: "Phòng gym", icon: "gym" },
	{ ID: 5, name: "Nhà hàng", icon: "restaurant" },
	{ ID: 6, name: "Spa", icon: "spa" },
	{ ID: 7, name: "Điều hòa không khí", icon: "ac" },
	{ ID: 8, name: "Bữa sáng miễn phí", icon: "breakfast" },
	{ ID: 9, name: "Thang máy", icon: "elevator" },
	{ ID: 10, name: "Quầy bar", icon: "bar" },
];

const bedTypes = ["Giường đôi lớn (King)", "Giường đôi (Queen)", "2 giường đơn (Twin)", "Giường đơn (Single)"];

const roomAmenityPool = [
	{ ID: 1, name: "WiFi miễn phí", icon: "wifi" },
	{ ID: 2, name: "Điều hòa không khí", icon: "ac" },
	{ ID: 3, name: "TV màn hình phẳng", icon: "tv" },
	{ ID: 4, name: "Tủ lạnh mini", icon: "fridge" },
	{ ID: 5, name: "Két an toàn", icon: "safe" },
];

const policyPool = [
	{ ID: 1, name: "Không hút thuốc" },
	{ ID: 2, name: "Không mang thú cưng" },
	{ ID: 3, name: "Không tổ chức tiệc" },
	{ ID: 4, name: "Nhận phòng từ 14:00" },
	{ ID: 5, name: "Trả phòng trước 12:00" },
];

const membershipLevels = ["Silver", "Gold", "Platinum"];
const genders = ["Nam", "Nữ", "Khác"];
const roles = ["user", "user", "user", "user", "admin"]; // 80% user, 20% admin

const hotelImages = [
	"https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=500&q=60",
	"https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=500&q=60",
	"https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=500&q=60",
];

const roomImages = [
	"https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=500&q=60",
	"https://images.unsplash.com/photo-1631049307264-da0ec9d70304?auto=format&fit=crop&w=500&q=60",
	"https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=500&q=60",
];

function pickRandom(arr, count = 1) {
	const shuffled = [...arr].sort(() => Math.random() - 0.5);
	return count === 1 ? shuffled[0] : shuffled.slice(0, count);
}

async function seedNewFormat() {
	console.log("⏳ Bắt đầu seed dữ liệu theo cấu trúc MỚI...\n");

	try {
		for (let i = 1; i <= 100; i++) {
			const city = cities[i % cities.length];
			const userId = `user_${i}`;
			const hotelId = `hotel_${i}`;
			const roomTypeId = `roomtype_${i}`;
			const bookingId = `booking_${i}`;
			const voucherId = `voucher_${i}`;

			// ── 1. USER (theo cấu trúc mới) ──────────────────────────────
			const customerBookingInfos = [];
			if (i % 3 === 0) {
				customerBookingInfos.push({
					ID: 1,
					Name: `Khách Hàng ${i}`,
					Email: `khachhang${i}@gmail.com`,
					Phone: `0900000${i.toString().padStart(3, '0')}`,
					Country: "Việt Nam",
					IsDefault: true
				});
			}

			await db.collection('Users').doc(userId).set({
				Email: `khachhang${i}@gmail.com`,
				Password: `hashed_password_${i}`,
				Phone: `0900000${i.toString().padStart(3, '0')}`,
				Name: `Khách Hàng Thứ ${i}`,
				Location: city,
				Gender: pickRandom(genders),
				DateOfBirth: `199${i % 10}-0${(i % 9) + 1}-${(i % 28) + 1}`.replace(/-(\d)-/, '-0$1-'),
				MembershipLevel: pickRandom(membershipLevels),
				Point: i * 10,
				TotalSpent: i * 500000,
				Role: pickRandom(roles),
				SearchingHistory: i % 2 === 0 ? [
					{
						ID: 1,
						Location: city,
						Checkin: "2026-05-10",
						Checkout: "2026-05-12",
						RoomNum: 1,
						Capacity: 2,
						searchedAt: new Date().toISOString()
					}
				] : [],
				CustomerBookingInfo: customerBookingInfos
			});

			// ── 2. HOTEL (theo cấu trúc mới) ─────────────────────────────
			const hotelAmenities = pickRandom(amenityPool, (i % 4) + 2);
			const hotelImgList = pickRandom(hotelImages, Math.min(hotelImages.length, (i % 3) + 1));

			await db.collection('Hotels').doc(hotelId).set({
				ID: i,
				type: pickRandom(hotelTypes),
				name: `Khách sạn ${city} ${(i % 5) + 1} Sao`,
				description: `Khách sạn ${(i % 5) + 1} sao tọa lạc tại trung tâm ${city}. Cung cấp dịch vụ lưu trú cao cấp với đầy đủ tiện nghi hiện đại.`,
				telephone: `02${i.toString().padStart(9, '0')}`,
				location: city,
				email: `hotel${i}@example.com`,
				star: (i % 5) + 1,
				images: (Array.isArray(hotelImgList) ? hotelImgList : [hotelImgList]).map((url, idx) => ({
					ID: idx + 1,
					url: url
				})),
				amenities: (Array.isArray(hotelAmenities) ? hotelAmenities : [hotelAmenities]).map(a => ({
					ID: a.ID,
					name: a.name,
					icon: a.icon
				}))
			});

			// ── 3. ROOM TYPE (theo cấu trúc mới) ─────────────────────────
			const roomAmenities = pickRandom(roomAmenityPool, (i % 3) + 2);
			const roomPolicies = pickRandom(policyPool, (i % 3) + 1);
			const roomImgList = pickRandom(roomImages, Math.min(roomImages.length, (i % 2) + 1));
			const capacity = (i % 4) + 1;
			const bedNum = capacity <= 2 ? 1 : 2;

			await db.collection('RoomTypes').doc(roomTypeId).set({
				ID: i,
				hotelID: hotelId,
				name: `Phòng ${pickRandom(bedTypes)}`,
				area: 15 + (i % 6) * 5,
				price: 500000 + (i * 15000),
				description: `Phòng rộng rãi với tầm nhìn đẹp, đầy đủ tiện nghi hiện đại.`,
				bedType: pickRandom(bedTypes),
				capacity: capacity,
				bedNum: bedNum,
				images: (Array.isArray(roomImgList) ? roomImgList : [roomImgList]).map((url, idx) => ({
					ID: idx + 1,
					url: url
				})),
				policies: (Array.isArray(roomPolicies) ? roomPolicies : [roomPolicies]).map(p => ({
					ID: p.ID,
					name: p.name
				})),
				amenities: (Array.isArray(roomAmenities) ? roomAmenities : [roomAmenities]).map(a => ({
					ID: a.ID,
					name: a.name,
					icon: a.icon
				})),
				rooms: [
					{ ID: i * 10 + 1, roomNumber: `${i}01`, status: "Available" },
					{ ID: i * 10 + 2, roomNumber: `${i}02`, status: i % 3 === 0 ? "Occupied" : "Available" }
				]
			});

			// ── 4. BOOKING ────────────────────────────────────────────────
			await db.collection('Bookings').doc(bookingId).set({
				userId: userId,
				hotelId: hotelId,
				hotelName: `Khách sạn ${city} ${(i % 5) + 1} Sao`,
				customerName: `Khách Hàng Thứ ${i}`,
				customerEmail: `khachhang${i}@gmail.com`,
				customerPhone: `0900000${i.toString().padStart(3, '0')}`,
				customerCountry: "Việt Nam",
				checkIn: "2026-05-10T14:00:00Z",
				checkOut: "2026-05-12T12:00:00Z",
				bookedRooms: [
					{ roomTypeId: roomTypeId, quantity: 1, price: 500000 + (i * 15000) }
				],
				originalPrice: (500000 + (i * 15000)) * 1.1,
				discount: (500000 + (i * 15000)) * 0.1,
				total: 500000 + (i * 15000),
				status: i % 4 === 0 ? "Cancelled" : i % 3 === 0 ? "Completed" : "Confirmed",
				createdAt: new Date().toISOString()
			});

			// ── 5. REVIEW ─────────────────────────────────────────────────
			await db.collection('Reviews').doc(`rev_${i}`).set({
				hotelId: hotelId,
				bookingId: bookingId,
				rating: (i % 5) + 1,
				comment: `Trải nghiệm tại khách sạn ${city} rất tuyệt vời! Phòng sạch sẽ, nhân viên thân thiện.`,
				guestName: `Khách Hàng Thứ ${i}`,
				createdAt: new Date().toISOString()
			});

			// ── 6. VOUCHER (theo cấu trúc mới) ───────────────────────────
			await db.collection('Vouchers').doc(voucherId).set({
				ID: i,
				Code: `SUMMER${i}`,
				DiscountType: i % 2 === 0 ? "Percentage" : "Fixed",
				Value: i % 2 === 0 ? (i % 5) + 5 : (i % 10 + 1) * 50000,
				MaxDiscountValue: i % 2 === 0 ? 500000 : 0,
				MinSpend: (i % 5 + 1) * 200000,
				UsageLimit: (i % 10 + 1) * 10,
				Status: i % 5 === 0 ? "Expired" : "Active",
				TargetType: i % 3 === 0 ? "new_user" : "all",
				startDate: "2026-01-01",
				endDate: i % 5 === 0 ? "2026-03-31" : "2026-12-31",
				UsageHistory: []
			});

			if (i % 10 === 0) {
				console.log(`✔️ Đã seed ${i}/100 bản ghi...`);
			}
		}

		console.log("\n🎉 HOÀN TẤT! Dữ liệu đã được seed theo cấu trúc MỚI!");
		process.exit(0);

	} catch (error) {
		console.error("❌ Lỗi khi seed:", error);
		process.exit(1);
	}
}

seedNewFormat();
