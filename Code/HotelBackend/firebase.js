// File: firebase.js
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

// Khởi tạo kết nối Firebase
admin.initializeApp({
	credential: admin.credential.cert(serviceAccount),
	databaseURL: `https://${serviceAccount.project_id}.firebaseio.com`,
});

const db = admin.firestore();

// Xuất biến db ra ngoài để các file khác có thể gọi vào dùng chung
module.exports = {db};