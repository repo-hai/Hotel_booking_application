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

// Phần của Đinh Hoàng Hải
// Khai báo các endpoint cho server
const UserController = require('./routes/controllers/User-controller');
const ChatboxController = require('./routes/controllers/Chatbox-controller');
const CommentRatingController = require('./routes/controllers/Comment-rating-controlller');
const PaymentController = require('./routes/controllers/Payment-controller');

app.post('/login', UserController.login);
app.post('/register', UserController.register);
app.post('/confirm-create-account', UserController.confirmCode);
app.post('/forgot-password', UserController.forgotPassword);
app.post('/change-password', UserController.changePassword);
app.post('/edit-profile', UserController.editProfile);
app.post('/comment-rating-controller/create-new-comment-rating', CommentRatingController.create_new_comment_rating);
app.post('/chatbox-controller/push-up-new-message', ChatboxController.pushUpNewMessage);
app.post('/booking-controller/create-new-booking', PaymentController.create_new_booking);
app.get('/get-user/:email', UserController.getUser);
app.get('/comment-rating-controller/get-avg-rating/:hotelID', CommentRatingController.getAvgRating);
app.get('/comment-rating-controller/get-list-comment-rating/:hotelID', CommentRatingController.get_list_comment_rating);
app.get('/chatbox-controller/get-list-chatbox/:userid', ChatboxController.getListChatbox);
app.get('/chatbox-controller/get-detail-chatbox/:chatboxid', ChatboxController.getDetailChatbox);
// Hết phần của Đinh Hoàng Hải


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
