// File: index.js
const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());

// Serve static files (uploaded images, etc.)
app.use('/uploads', express.static(path.join(__dirname, 'public/uploads')));

// 1. Nhập các "Trưởng phòng" (Routers) vào
// Sơn Hải
const hotelRoutes = require('./routes/hotel');
const bookingRoutes = require('./routes/booking');
const userRoutes = require('./routes/user');

// Minh
const adminRoutes = require('./routes/admin');

// Owner (Partner)
const ownerRoutes = require('./routes/owner');

// 2. Giao việc cho các Trưởng phòng
// Sơn Hải
app.use('/api/hotels', hotelRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/users', userRoutes);

// Minh
app.use('/api/admin', adminRoutes);

// Owner
app.use('/api/owner', ownerRoutes);

// 3. API test thử xem server còn sống không
app.get('/', (req, res) => {
	res.send("Xin chào, Backend Node.js đã chạy!");
});

// 4. Mở cửa lắng nghe
const PORT = 3000;
app.listen(PORT, () => {
	console.log(`🚀 Server đang chạy ngon lành ở port ${PORT}`);
});
