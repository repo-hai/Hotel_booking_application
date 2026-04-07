# Danh sách tất cả API cần thiết cho Admin - Hotel Booking App

## Context
Dựa trên toàn bộ chức năng admin đã xây dựng frontend (5 trang: Tổng quan, Quản lý người dùng, Quản lý khách sạn, Quản lý đặt phòng, Quản lý voucher), liệt kê đầy đủ các API endpoint cần thiết cho backend Node.js + Firebase.

**Base URL:** `/api/admin`

---

## 1. AUTH - Xác thực Admin (2 API)

| # | Method | Endpoint | Mô tả |
|---|--------|----------|--------|
| 1 | POST | `/api/admin/auth/login` | Đăng nhập admin (email + password) |
| 2 | POST | `/api/admin/auth/logout` | Đăng xuất, hủy token |

---

## 2. DASHBOARD - Tổng quan (2 API)

| # | Method | Endpoint | Mô tả |
|---|--------|----------|--------|
| 3 | GET | `/api/admin/dashboard/stats` | Lấy thống kê tổng quan (tổng user, tổng khách sạn, tổng đơn đặt phòng, tổng voucher) |
| 4 | GET | `/api/admin/dashboard/recent-bookings` | Lấy danh sách đơn đặt phòng gần đây (giới hạn 5-10 đơn mới nhất) |

---

## 3. USERS - Quản lý người dùng (4 API)

> **Lưu ý:** Admin chỉ có quyền xem thông tin, khóa/mở khóa và xóa tài khoản. Admin KHÔNG được sửa họ tên, SĐT của user.

| # | Method | Endpoint | Mô tả |
|---|--------|----------|--------|
| 5 | GET | `/api/admin/users?type=customer&search=keyword&page=1&limit=20` | Lấy danh sách user (filter theo type: customer/owner, tìm kiếm theo tên/SĐT, phân trang) |
| 6 | GET | `/api/admin/users/:id` | Lấy chi tiết 1 user (tên, SĐT, email, trạng thái, ngày tham gia) |
| 7 | PATCH | `/api/admin/users/:id/status` | Thay đổi trạng thái user (active ↔ locked) |
| 8 | DELETE | `/api/admin/users/:id` | Xóa vĩnh viễn tài khoản user |

---

## 4. HOTELS - Quản lý khách sạn & phòng (7 API)

| # | Method | Endpoint | Mô tả |
|---|--------|----------|--------|
| 9 | GET | `/api/admin/hotels?status=pending&page=1&limit=20` | Lấy danh sách khách sạn (filter theo status: pending/approved/rejected, phân trang) |
| 10 | GET | `/api/admin/hotels/:id` | Lấy chi tiết khách sạn (thông tin, ảnh, tiện nghi, chủ nhà, giấy tờ) |
| 11 | PATCH | `/api/admin/hotels/:id/approve` | Phê duyệt khách sạn (kèm option gửi email thông báo cho chủ nhà) |
| 12 | PATCH | `/api/admin/hotels/:id/reject` | Từ chối khách sạn (kèm lý do từ chối, gửi email cho chủ nhà) |
| 13 | GET | `/api/admin/hotels/:id/rooms` | Lấy danh sách phòng của khách sạn |
| 14 | GET | `/api/admin/hotels/:id/documents` | Lấy giấy tờ/tài liệu đăng ký (giấy phép KD, CCCD) |
| 15 | GET | `/api/admin/hotels/:id/images` | Lấy danh sách ảnh khách sạn |

---

## 5. BOOKINGS - Quản lý đơn đặt phòng (3 API)

> **Lưu ý:** Admin chỉ có quyền XEM đơn đặt phòng. Việc xác nhận/hủy đơn là chức năng của Chủ nhà (Owner).

| # | Method | Endpoint | Mô tả |
|---|--------|----------|--------|
| 16 | GET | `/api/admin/bookings?status=pending&search=keyword&page=1&limit=20` | Lấy danh sách đơn (filter theo status, tìm theo tên khách/khách sạn/mã đơn, sắp xếp, phân trang) |
| 17 | GET | `/api/admin/bookings/:id` | Lấy chi tiết đơn (thông tin chỗ nghỉ, khách hàng, ngày checkin/out, thanh toán) |
| 18 | GET | `/api/admin/bookings/stats?startDate=...&endDate=...` | Thống kê đơn đặt phòng theo khoảng thời gian |

---

## 6. VOUCHERS - Quản lý Voucher (6 API)

| # | Method | Endpoint | Mô tả |
|---|--------|----------|--------|
| 19 | GET | `/api/admin/vouchers?status=active&search=keyword&page=1&limit=20` | Lấy danh sách voucher (filter theo status, tìm theo mã/tên, phân trang) |
| 20 | GET | `/api/admin/vouchers/:id` | Lấy chi tiết voucher |
| 21 | POST | `/api/admin/vouchers` | Tạo voucher mới |
| 22 | PUT | `/api/admin/vouchers/:id` | Cập nhật thông tin voucher |
| 23 | PATCH | `/api/admin/vouchers/:id/status` | Bật/tắt voucher (active ↔ disabled) |
| 24 | DELETE | `/api/admin/vouchers/:id` | Xóa voucher |

---

## 7. UPLOAD & COMMON (2 API)

| # | Method | Endpoint | Mô tả |
|---|--------|----------|--------|
| 25 | POST | `/api/admin/upload/image` | Upload ảnh (dùng cho avatar, ảnh khách sạn) |
| 26 | GET | `/api/admin/notifications` | Lấy danh sách thông báo cho admin |

---

## TỔNG KẾT: 26 API

| Module | Số API | Ghi chú |
|--------|--------|---------|
| Auth | 2 | |
| Dashboard | 2 | |
| Users | 4 | Chỉ xem, khóa/mở, xóa (không sửa thông tin cá nhân) |
| Hotels | 7 | |
| Bookings | 3 | Chỉ xem (xác nhận/hủy là quyền của Chủ nhà) |
| Vouchers | 6 | |
| Common | 2 | |
| **Tổng** | **26** |

---

## CHI TIẾT REQUEST/RESPONSE

### 1.1 POST `/api/admin/auth/login`
**Request body:**
```json
{
  "email": "admin@example.com",
  "password": "password123"
}
```
**Response:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "admin": {
      "id": 1,
      "email": "admin@example.com",
      "name": "Admin"
    }
  }
}
```

---

### 2.1 GET `/api/admin/dashboard/stats`
**Response:**
```json
{
  "success": true,
  "data": {
    "totalUsers": 24500,
    "totalHotels": 1840,
    "totalBookings": 3256,
    "totalVouchers": 156
  }
}
```

### 2.2 GET `/api/admin/dashboard/recent-bookings`
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1001,
      "hotelName": "Homestay Cát Bà Sea",
      "guestName": "Nguyễn Văn A",
      "date": "07/04/2026",
      "status": "pending"
    }
  ]
}
```

---

### 3.1 GET `/api/admin/users`
**Query params:**
- `type`: `customer` | `owner`
- `search`: string (tìm theo tên hoặc SĐT)
- `page`: number
- `limit`: number

**Response:**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": 1,
        "name": "Trần Anh Tuấn",
        "phone": "0904 123 456",
        "email": "tuan.tran@example.com",
        "type": "customer",
        "status": "active",
        "joinDate": "2025-05-12T00:00:00Z",
        "avatarUrl": null
      }
    ],
    "total": 100,
    "page": 1,
    "limit": 20
  }
}
```

### 3.3 PATCH `/api/admin/users/:id/status`
**Request body:**
```json
{
  "status": "locked"
}
```

### 3.4 DELETE `/api/admin/users/:id`
**Response:**
```json
{
  "success": true,
  "message": "Xóa tài khoản thành công"
}
```

---

### 4.1 GET `/api/admin/hotels`
**Query params:**
- `status`: `pending` | `approved` | `rejected`
- `page`: number
- `limit`: number

**Response:**
```json
{
  "success": true,
  "data": {
    "hotels": [
      {
        "id": 1,
        "name": "Homestay Cát Bà Sea",
        "type": "Homestay",
        "city": "Hải Phòng, Việt Nam",
        "ownerName": "Nguyễn Văn A",
        "requestDate": "2026-02-23T00:00:00Z",
        "hasIdDocument": true,
        "hasBusinessLicense": true,
        "status": "pending"
      }
    ],
    "total": 8,
    "page": 1,
    "limit": 20
  }
}
```

### 4.2 GET `/api/admin/hotels/:id`
**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Homestay Cát Bà Sea",
    "type": "Homestay",
    "address": "Đường 1/4, Thị trấn Cát Bà, Huyện Cát Hải, Hải Phòng, Việt Nam",
    "city": "Hải Phòng, Việt Nam",
    "ownerName": "Nguyễn Văn A",
    "ownerPhone": "0988 123 456",
    "requestDate": "2026-02-23T00:00:00Z",
    "hasIdDocument": true,
    "hasBusinessLicense": true,
    "pricePerNight": 500000,
    "roomCount": 5,
    "imageCount": 8,
    "amenities": ["Wifi miễn phí", "Chỗ đỗ xe", "Lễ tân 24/7"],
    "status": "pending",
    "images": [
      { "id": 1, "url": "https://..." }
    ]
  }
}
```

### 4.3 PATCH `/api/admin/hotels/:id/approve`
**Request body:**
```json
{
  "sendEmail": true
}
```
**Response:**
```json
{
  "success": true,
  "message": "Phê duyệt thành công"
}
```

### 4.4 PATCH `/api/admin/hotels/:id/reject`
**Request body:**
```json
{
  "reason": "Giấy phép kinh doanh không hợp lệ",
  "customReason": ""
}
```
**Response:**
```json
{
  "success": true,
  "message": "Đã từ chối khách sạn"
}
```

---

### 5.1 GET `/api/admin/bookings`
**Query params:**
- `status`: `pending` | `confirmed` | `cancelled` | `completed`
- `search`: string (tìm theo tên khách, tên khách sạn, mã đơn)
- `sort`: `newest` | `oldest`
- `page`: number
- `limit`: number

**Response:**
```json
{
  "success": true,
  "data": {
    "bookings": [
      {
        "id": 1001,
        "hotelName": "Homestay Cát Bà Sea",
        "roomType": "Phòng Deluxe Đôi",
        "guestName": "Trần Anh Tuấn",
        "guestPhone": "0904 123 456",
        "guestEmail": "tuan.tran@example.com",
        "checkin": "2026-04-10",
        "checkout": "2026-04-13",
        "totalPrice": 1500000,
        "roomCount": 1,
        "guestCount": 2,
        "bookedAt": "2026-04-07T00:00:00Z",
        "paymentMethod": "Thẻ tín dụng",
        "paymentStatus": "Đã thanh toán",
        "status": "pending"
      }
    ],
    "total": 50,
    "page": 1,
    "limit": 20
  }
}
```

### 5.3 GET `/api/admin/bookings/stats`
**Query params:**
- `startDate`: date string
- `endDate`: date string

**Response:**
```json
{
  "success": true,
  "data": {
    "totalBookings": 150,
    "totalRevenue": 250000000,
    "byStatus": {
      "pending": 10,
      "confirmed": 80,
      "completed": 50,
      "cancelled": 10
    }
  }
}
```

---

### 6.1 GET `/api/admin/vouchers`
**Query params:**
- `status`: `active` | `expired` | `disabled`
- `search`: string (tìm theo mã hoặc tên)
- `page`: number
- `limit`: number

**Response:**
```json
{
  "success": true,
  "data": {
    "vouchers": [
      {
        "id": 1,
        "code": "SUMMER2026",
        "name": "Khuyến mãi Hè 2026",
        "discountType": "percent",
        "discountValue": 20,
        "maxDiscount": 500000,
        "minSpend": 1000000,
        "usageLimit": 500,
        "usedCount": 324,
        "startDate": "2026-05-01",
        "endDate": "2026-08-31",
        "targetType": "all",
        "status": "active"
      }
    ],
    "total": 10,
    "page": 1,
    "limit": 20
  }
}
```

### 6.3 POST `/api/admin/vouchers`
**Request body:**
```json
{
  "code": "SUMMER2026",
  "name": "Khuyến mãi Hè 2026",
  "discountType": "percent",
  "discountValue": 20,
  "maxDiscount": 500000,
  "minSpend": 1000000,
  "usageLimit": 500,
  "startDate": "2026-05-01",
  "endDate": "2026-08-31",
  "targetType": "all",
  "status": "active"
}
```
**Response:**
```json
{
  "success": true,
  "message": "Tạo voucher thành công",
  "data": {
    "id": 6
  }
}
```

### 6.4 PUT `/api/admin/vouchers/:id`
**Request body:**
```json
{
  "code": "SUMMER2026",
  "name": "Khuyến mãi Hè 2026 - Updated",
  "discountType": "percent",
  "discountValue": 25,
  "maxDiscount": 600000,
  "minSpend": 1000000,
  "usageLimit": 600,
  "startDate": "2026-05-01",
  "endDate": "2026-09-30",
  "targetType": "all",
  "status": "active"
}
```

### 6.5 PATCH `/api/admin/vouchers/:id/status`
**Request body:**
```json
{
  "status": "disabled"
}
```

---

### 7.1 POST `/api/admin/upload/image`
**Request:** `multipart/form-data`
- `file`: image file
- `type`: `avatar` | `hotel` | `document`

**Response:**
```json
{
  "success": true,
  "data": {
    "url": "https://firebasestorage.googleapis.com/...",
    "fileName": "image_123.jpg"
  }
}
```

---

## ERROR RESPONSE FORMAT
Tất cả API trả về lỗi theo format:
```json
{
  "success": false,
  "message": "Mô tả lỗi",
  "errorCode": "ERROR_CODE"
}
```

**HTTP Status Codes:**
- `200` - Thành công
- `201` - Tạo thành công
- `400` - Bad request (thiếu/sai params)
- `401` - Unauthorized (chưa đăng nhập)
- `403` - Forbidden (không có quyền)
- `404` - Not found
- `500` - Server error
