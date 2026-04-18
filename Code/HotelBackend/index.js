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


const {login} = require('./routes/controllers/login');
const {register} = require('./routes/controllers/register');
const {confirmCode} = require('./routes/controllers/confirm_code');
const {forgotPassword} = require('./routes/controllers/forgot_password');
const {changePassword} = require('./routes/controllers/change_password');
const {editProfile} = require('./routes/controllers/edit_profile');
const {getAvgRating} = require('./routes/controllers/get_avg_rating');
const {getCommentRating} = require('./routes/controllers/get_comment_rating');
const {commentRating} = require('./routes/controllers/comment_rating');
const {getListChatbox} = require('./routes/controllers/get_list_chatbox');
const {getDetailChatbox} = require('./routes/controllers/get_detail_chatbox');
const {pushUpNewMessage} = require('./routes/controllers/commit_new_message');

app.post('/login', login);
app.post('/register', register);
app.post('/confirm-create-account', confirmCode);
app.post('/forgot-password', forgotPassword);
app.post('/change-password', changePassword);
app.post('/edit-profile', editProfile);
app.post('/comment-rating', commentRating);
app.post('/push-up-new-message', pushUpNewMessage);

app.get('/get-avg-rating', getAvgRating);
app.get('/get-comment-rating', getCommentRating);
app.get('/get-list-chatbox', getListChatbox);
app.get('/get-detail-chatbox', getDetailChatbox);

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
