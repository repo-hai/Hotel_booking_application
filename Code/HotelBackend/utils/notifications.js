const db = require('../firebase');
const admin = require('firebase-admin');

/**
 * Gửi thông báo đến chủ sở hữu (Firestore + FCM)
 * @param {string} ownerId ID của chủ sở hữu
 * @param {object} notification { title, body, type, data }
 */
async function sendNotificationToOwner(ownerId, notification) {
    try {
        const { title, body, type, data } = notification;

        // 1. Lưu vào Firestore
        const notificationData = {
            userId: ownerId,
            title,
            body,
            type: type || 'info', // e.g., 'new_booking', 'cancel_request'
            data: data || {},
            isRead: false,
            createdAt: new Date().toISOString()
        };

        const docRef = await db.collection('Notifications').add(notificationData);
        console.log(`[Notification] Saved to Firestore: ${docRef.id} for owner ${ownerId}`);

        // 2. Gửi qua Firebase Cloud Messaging (FCM)
        // Gửi qua Topic để tất cả thiết bị của Owner đều nhận được
        const message = {
            notification: {
                title: title,
                body: body,
            },
            data: {
                ...data,
                click_action: "FLUTTER_NOTIFICATION_CLICK",
                id: docRef.id,
                type: type || 'info'
            },
            topic: `owner_${ownerId}`
        };

        try {
            const response = await admin.messaging().send(message);
            console.log(`[FCM] Successfully sent message to topic owner_${ownerId}:`, response);
        } catch (fcmError) {
            console.error(`[FCM] Error sending message to topic owner_${ownerId}:`, fcmError);
            // Không throw lỗi ở đây để tránh làm hỏng luồng chính nếu FCM cấu hình chưa chuẩn
        }

        return docRef.id;
    } catch (error) {
        console.error("Lỗi khi xử lý thông báo: ", error);
    }
}

/**
 * Gửi thông báo đến khách hàng (Firestore + FCM)
 * @param {string} userId ID của khách hàng
 * @param {object} notification { title, body, type, data }
 */
async function sendNotificationToUser(userId, notification) {
    try {
        const { title, body, type, data } = notification;

        // 1. Lưu vào Firestore
        const notificationData = {
            userId: userId,
            title,
            body,
            type: type || 'info',
            data: data || {},
            isRead: false,
            createdAt: new Date().toISOString()
        };

        const docRef = await db.collection('Notifications').add(notificationData);

        // 2. Gửi qua FCM (Topic: user_{userId})
        const message = {
            notification: { title, body },
            data: { ...data, id: docRef.id, type: type || 'info' },
            topic: `user_${userId}`
        };

        await admin.messaging().send(message).catch(e => console.error("FCM User Error:", e));

        return docRef.id;
    } catch (error) {
        console.error("Lỗi thông báo khách hàng: ", error);
    }
}

module.exports = {
    sendNotificationToOwner,
    sendNotificationToUser
};
