/**
 * seed.js — Upload dữ liệu từ các file JSON lên Firebase Firestore
 *
 * CÁCH CHẠY (thủ công, KHÔNG tự chạy khi start server):
 *   node seed.js
 *
 * File này ĐỌC dữ liệu từ:
 *   - hotels.json    → Collection 'Hotels'
 *   - roomType.json  → Collection 'RoomTypes'
 *   - user.json      → Collection 'Users'
 *   - vouchers.json  → Collection 'Vouchers'
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
const hotelsData = require('./hotels.json');
const roomTypesData = require('./roomType.json');
const usersData = require('./user.json');
const vouchersData = require('./vouchers.json');

admin.initializeApp({
	credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function seedAll() {
	console.log('🌱 Bắt đầu seed dữ liệu từ các file JSON...\n');

	await seedHotels();
	await seedRoomTypes();
	await seedUsers();
	await seedVouchers();

	console.log('\n✅ Seed hoàn tất!');
	process.exit(0);
}

// ── Hotels ────────────────────────────────────────────────────────────────────
async function seedHotels() {
	console.log(`📦 Seeding ${hotelsData.length} Hotels...`);
	const batch = db.batch();

	// Phân bổ khách sạn cho các owner (User ID 2, 3, 4)
	const ownerIds = ['2', '3', '4'];

	for (const hotel of hotelsData) {
		const docId = String(hotel.ID);
		const ref = db.collection('Hotels').doc(docId);
		// Phân bổ đều cho các owner
		const ownerIndex = (hotel.ID - 1) % ownerIds.length;
		batch.set(ref, {
			ID: hotel.ID,
			userId: ownerIds[ownerIndex],
			type: hotel.type,
			name: hotel.name,
			description: hotel.description,
			telephone: hotel.telephone,
			location: hotel.location,
			email: hotel.email,
			star: hotel.star,
			images: hotel.images.map(img => ({ ID: img.ID, url: img.url })),
			amenities: hotel.amenities.map(a => ({ ID: a.ID, name: a.name, icon: a.icon }))
		});
	}

	await batch.commit();
	console.log(`   ✔ ${hotelsData.length} Hotels uploaded`);
}

// ── RoomTypes ─────────────────────────────────────────────────────────────────
async function seedRoomTypes() {
	console.log(`📦 Seeding ${roomTypesData.length} RoomTypes...`);

	// Firestore batch giới hạn 500 ops, chia nhỏ nếu cần
	const chunks = chunkArray(roomTypesData, 400);
	let total = 0;

	for (const chunk of chunks) {
		const batch = db.batch();
		for (const room of chunk) {
			const docId = String(room.ID);
			const ref = db.collection('RoomTypes').doc(docId);
			batch.set(ref, {
				ID: room.ID,
				hotelID: room.hotelID,
				name: room.name,
				area: room.area,
				price: room.price,
				description: room.description,
				bedType: room.bedType,
				capacity: room.capacity,
				bedNum: room.bedNum,
				images: room.images.map(img => ({ ID: img.ID, url: img.url })),
				policies: room.policies.map(p => ({ ID: p.ID, name: p.name })),
				amenities: room.amenities.map(a => ({ ID: a.ID, name: a.name, icon: a.icon })),
				rooms: room.rooms.map(r => ({ ID: r.ID, roomNumber: r.roomNumber, status: r.status }))
			});
		}
		await batch.commit();
		total += chunk.length;
	}

	console.log(`   ✔ ${total} RoomTypes uploaded`);
}

// ── Users ─────────────────────────────────────────────────────────────────────
async function seedUsers() {
	console.log(`📦 Seeding ${usersData.length} Users...`);
	const batch = db.batch();

	for (const user of usersData) {
		const docId = String(user.ID);
		const ref = db.collection('Users').doc(docId);

		const doc = {
			ID: user.ID,
			Email: user.Email,
			Password: user.Password,
			Phone: user.Phone,
			Name: user.Name,
			Location: user.Location,
			Gender: user.Gender,
			DateOfBirth: user.DateOfBirth,
			MembershipLevel: user.MembershipLevel || null,
			Point: user.Point || 0,
			TotalSpent: user.TotalSpent || 0,
			Role: user.Role
		};

		// Thêm SearchingHistory nếu có
		if (user.SearchingHistory && user.SearchingHistory.length > 0) {
			doc.SearchingHistory = user.SearchingHistory.map(h => ({
				ID: h.ID,
				Location: h.Location,
				Checkin: h.Checkin,
				Checkout: h.Checkout,
				RoomNum: h.RoomNum,
				Capacity: h.Capacity,
				searchedAt: new Date().toISOString()
			}));
		} else {
			doc.SearchingHistory = [];
		}

		// Thêm CustomerBookingInfo nếu có
		if (user.CustomerBookingInfo && user.CustomerBookingInfo.length > 0) {
			doc.CustomerBookingInfo = user.CustomerBookingInfo.map(c => ({
				ID: c.ID,
				Name: c.Name,
				Email: c.Email,
				Phone: c.Phone,
				Country: c.Country,
				IsDefault: c.IsDefault
			}));
		} else {
			doc.CustomerBookingInfo = [];
		}

		batch.set(ref, doc);
	}

	await batch.commit();
	console.log(`   ✔ ${usersData.length} Users uploaded`);
}

// ── Vouchers ──────────────────────────────────────────────────────────────────
async function seedVouchers() {
	console.log(`📦 Seeding ${vouchersData.length} Vouchers...`);
	const batch = db.batch();

	for (const v of vouchersData) {
		const docId = String(v.ID);
		const ref = db.collection('Vouchers').doc(docId);
		batch.set(ref, {
			ID: v.ID,
			Code: v.Code,
			DiscountType: v.DiscountType,
			Value: v.Value,
			MaxDiscountValue: v.MaxDiscountValue,
			MinSpend: v.MinSpend,
			UsageLimit: v.UsageLimit,
			Status: v.Status,
			TargetType: v.TargetType,
			startDate: v.startDate,
			endDate: v.endDate,
			UsageHistory: (v.UsageHistory || []).map(h => ({ ID: h.ID, UsedAt: h.UsedAt }))
		});
	}

	await batch.commit();
	console.log(`   ✔ ${vouchersData.length} Vouchers uploaded`);
}

// ── Helper ────────────────────────────────────────────────────────────────────
function chunkArray(arr, size) {
	const chunks = [];
	for (let i = 0; i < arr.length; i += size) {
		chunks.push(arr.slice(i, i + size));
	}
	return chunks;
}

// Chạy
seedAll().catch(err => {
	console.error('❌ Lỗi khi seed:', err);
	process.exit(1);
});
