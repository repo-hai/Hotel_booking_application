# HƯỚNG DẪN SỬ DỤNG API - HOTEL BOOKING BACKEND

## 📋 MỤC LỤC
1. [Giới thiệu](#giới-thiệu)
2. [Cài đặt và Chạy Backend](#cài-đặt-và-chạy-backend)
3. [Cấu trúc Project](#cấu-trúc-project)
4. [Danh sách API](#danh-sách-api)
5. [Hướng dẫn Test với Postman](#hướng-dẫn-test-với-postman)

---

## 🎯 GIỚI THIỆU

Backend này được xây dựng bằng **Node.js + Express + Firebase Firestore** để phục vụ ứng dụng đặt phòng khách sạn.

**Công nghệ sử dụng:**
- Node.js & Express 5.2.1
- Firebase Admin SDK 13.7.0
- CORS 2.8.6

**Base URL:** `http://localhost:3000`

---

## 🚀 CÀI ĐẶT VÀ CHẠY BACKEND

### Bước 1: Cài đặt Node.js
Đảm bảo máy đã cài Node.js (phiên bản 14 trở lên). Kiểm tra bằng lệnh:
```bash
node --version
npm --version
```

### Bước 2: Cài đặt Dependencies
Di chuyển vào thư mục HotelBackend và cài đặt các package:
```bash
cd Code/hotel_booking_app/HotelBackend
npm install
```

### Bước 3: Cấu hình Firebase
- Đảm bảo file `serviceAccountKey.json` tồn tại trong thư mục gốc
- File này chứa thông tin xác thực Firebase (không được chia sẻ công khai)

### Bước 4: Chạy Server
```bash
node index.js
```

Nếu thành công, bạn sẽ thấy thông báo:
```
🚀 Server đang chạy ngon lành ở port 3000
```


### Bước 5: Khởi tạo dữ liệu mẫu (Tùy chọn)
Để tạo 100 bản ghi mẫu cho testing:
```bash
node seed.js
```

Lệnh này sẽ tạo:
- 100 Users
- 100 Hotels (rải rác ở 7 thành phố)
- 100 RoomTypes
- 100 Bookings
- 100 Reviews
- 100 Vouchers
- 100 Conversations với Messages

---

## 📁 CẤU TRÚC PROJECT

```
HotelBackend/
├── index.js              # Entry point, khởi tạo Express server
├── firebase.js           # Cấu hình kết nối Firebase
├── serviceAccountKey.json # Thông tin xác thực Firebase (bí mật)
├── seed.js               # Script tạo dữ liệu mẫu
├── package.json          # Danh sách dependencies
└── routes/               # Các module API
    ├── hotel.js          # API liên quan đến khách sạn
    ├── booking.js        # API đặt phòng
    ├── user.js           # API người dùng
    └── admin.js          # API quản trị
```

---

## 📡 DANH SÁCH API

### 🏨 NHÓM API: HOTELS (`/api/hotels`)

#### 1. Lấy danh sách tất cả khách sạn (có phân trang)
**Endpoint:** `GET /api/hotels`

**Mô tả:** Lấy danh sách khách sạn với hỗ trợ phân trang

**Query Parameters:**
| Tham số | Kiểu | Mặc định | Mô tả |
|---------|------|----------|-------|
| page | number | 1 | Số trang hiện tại |
| limit | number | 10 | Số lượng khách sạn mỗi trang |

**Response thành công (200):**
```json
{
  "message": "Lấy danh sách thành công!",
  "data": [
    {
      "id": "hotel_1",
      "name": "Khách sạn Hà Nội 2 Sao",
      "address": "Số 1 Đường ABC, Hà Nội",
      "city": "Hà Nội",
      "star": 2,
      "images": ["https://..."],
      "amenities": [
        { "name": "Wifi miễn phí", "icon": "wifi" }
      ]
    }
  ],
  "pagination": {
    "currentPage": 1,
    "limit": 10,
    "totalPages": 10,
    "totalItems": 100
  }
}
```


**Cách test với Postman:**
1. Method: `GET`
2. URL: `http://localhost:3000/api/hotels?page=1&limit=10`
3. Click **Send**

---

#### 2. Tìm kiếm khách sạn phù hợp
**Endpoint:** `GET /api/hotels/search`

**Mô tả:** Tìm khách sạn theo thành phố, số người và số phòng

**Query Parameters:**
| Tham số | Kiểu | Bắt buộc | Mô tả |
|---------|------|----------|-------|
| city | string | ✅ | Tên thành phố |
| guests | number | ✅ | Số lượng khách |
| rooms | number | ✅ | Số lượng phòng cần đặt |
| page | number | ❌ | Số trang (mặc định: 1) |
| limit | number | ❌ | Số kết quả/trang (mặc định: 10) |

**Response thành công (200):**
```json
{
  "message": "Tìm thấy 5 khách sạn phù hợp tại Đà Nẵng",
  "data": [
    {
      "id": "hotel_4",
      "name": "Khách sạn Đà Nẵng 5 Sao",
      "city": "Đà Nẵng",
      "star": 5,
      "availableRoomTypes": [
        {
          "id": "roomtype_4",
          "name": "Phòng Hạng Sang Loại 4",
          "price": 560000,
          "capacity": 2
        }
      ]
    }
  ],
  "pagination": {
    "currentPage": 1,
    "limit": 10,
    "totalPages": 1,
    "totalItems": 5
  }
}
```

**Cách test với Postman:**
1. Method: `GET`
2. URL: `http://localhost:3000/api/hotels/search?city=Đà Nẵng&guests=2&rooms=1`
3. Click **Send**

---

#### 3. Bộ lọc nâng cao và sắp xếp
**Endpoint:** `POST /api/hotels/filter`

**Mô tả:** Lọc khách sạn theo nhiều tiêu chí và sắp xếp kết quả

**Query Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| page | number | Số trang (mặc định: 1) |
| limit | number | Số kết quả/trang (mặc định: 10) |

**Request Body:**
```json
{
  "city": "Hà Nội",
  "minPrice": 500000,
  "maxPrice": 1000000,
  "minStar": 4,
  "requiredAmenities": ["wifi", "pool"],
  "sortBy": "price_asc"
}
```

**Các giá trị sortBy:**
- `price_asc`: Giá tăng dần
- `price_desc`: Giá giảm dần
- `star_desc`: Số sao giảm dần


**Response thành công (200):**
```json
{
  "message": "Tìm thấy 3 khách sạn phù hợp",
  "data": [
    {
      "id": "hotel_1",
      "name": "Khách sạn Hà Nội 5 Sao",
      "city": "Hà Nội",
      "star": 5,
      "minRoomPrice": 750000,
      "rooms": [...]
    }
  ],
  "pagination": {
    "currentPage": 1,
    "limit": 10,
    "totalPages": 1,
    "totalItems": 3
  }
}
```

**Cách test với Postman:**
1. Method: `POST`
2. URL: `http://localhost:3000/api/hotels/filter?page=1&limit=10`
3. Headers: `Content-Type: application/json`
4. Body (raw JSON):
```json
{
  "city": "Hà Nội",
  "minStar": 4,
  "sortBy": "price_asc"
}
```
5. Click **Send**

---

#### 4. Xem chi tiết khách sạn
**Endpoint:** `GET /api/hotels/:id`

**Mô tả:** Lấy thông tin chi tiết của 1 khách sạn kèm danh sách phòng

**Path Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| id | string | ID của khách sạn |

**Response thành công (200):**
```json
{
  "message": "Lấy thông tin chi tiết khách sạn thành công!",
  "data": {
    "id": "hotel_1",
    "name": "Khách sạn Hà Nội 2 Sao",
    "address": "Số 1 Đường ABC, Hà Nội",
    "city": "Hà Nội",
    "star": 2,
    "images": ["https://..."],
    "amenities": [
      { "name": "Wifi miễn phí", "icon": "wifi" },
      { "name": "Hồ bơi", "icon": "pool" }
    ],
    "rooms": [
      {
        "id": "roomtype_1",
        "name": "Phòng Hạng Sang Loại 1",
        "price": 515000,
        "capacity": 2,
        "images": ["https://..."]
      }
    ]
  }
}
```

**Response lỗi (404):**
```json
{
  "message": "Khách sạn không tồn tại hoặc đã bị xóa!"
}
```

**Cách test với Postman:**
1. Method: `GET`
2. URL: `http://localhost:3000/api/hotels/hotel_1`
3. Click **Send**

---


### 📝 NHÓM API: BOOKINGS (`/api/bookings`)

#### 5. Tạo đơn đặt phòng mới
**Endpoint:** `POST /api/bookings`

**Mô tả:** Khách hàng tạo đơn đặt phòng mới

**Request Body:**
```json
{
  "hotelId": "hotel_1",
  "hotelName": "Khách sạn Hà Nội 2 Sao",
  "customerInfo": {
    "firstName": "Văn A",
    "lastName": "Nguyễn",
    "email": "vana@gmail.com",
    "phone": "0901234567",
    "country": "Việt Nam"
  },
  "checkIn": "2026-05-10T14:00:00Z",
  "checkOut": "2026-05-12T12:00:00Z",
  "bookedRooms": [
    {
      "roomTypeId": "roomtype_1",
      "quantity": 2,
      "price": 515000
    }
  ],
  "originalPrice": 2060000,
  "discount": 206000,
  "totalPrice": 1854000
}
```

**Response thành công (201):**
```json
{
  "message": "Đặt phòng thành công!",
  "bookingId": "abc123xyz",
  "data": {
    "hotelId": "hotel_1",
    "hotelName": "Khách sạn Hà Nội 2 Sao",
    "customerName": "Nguyễn Văn A",
    "customerEmail": "vana@gmail.com",
    "customerPhone": "0901234567",
    "customerCountry": "Việt Nam",
    "checkIn": "2026-05-10T14:00:00Z",
    "checkOut": "2026-05-12T12:00:00Z",
    "bookedRooms": [...],
    "originalPrice": 2060000,
    "discount": 206000,
    "total": 1854000,
    "status": "Confirmed",
    "createdAt": "2026-04-08T10:30:00.000Z"
  }
}
```

**Response lỗi (400):**
```json
{
  "message": "Thiếu thông tin đặt phòng!"
}
```

**Cách test với Postman:**
1. Method: `POST`
2. URL: `http://localhost:3000/api/bookings`
3. Headers: `Content-Type: application/json`
4. Body (raw JSON): Copy request body ở trên
5. Click **Send**

---

#### 6. Lấy danh sách đơn đặt phòng
**Endpoint:** `GET /api/bookings`

**Mô tả:** Lấy danh sách đơn đặt phòng với phân trang và lọc theo trạng thái

**Query Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| status | string | Lọc theo trạng thái: `Confirmed`, `Pending`, `Cancelled`, `Cancel_Requested` |
| page | number | Số trang (mặc định: 1) |
| limit | number | Số đơn/trang (mặc định: 10) |


**Response thành công (200):**
```json
{
  "message": "Lấy danh sách đơn hàng thành công!",
  "data": [
    {
      "id": "booking_1",
      "userId": "user_1",
      "hotelId": "hotel_1",
      "customerName": "Khách Hàng Thứ 1",
      "checkIn": "2026-05-10T14:00:00Z",
      "checkOut": "2026-05-12T12:00:00Z",
      "total": 1005000,
      "status": "Confirmed"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "limit": 10,
    "totalPages": 10,
    "totalItems": 100
  }
}
```

**Cách test với Postman:**
1. Method: `GET`
2. URL: `http://localhost:3000/api/bookings?status=Confirmed&page=1&limit=10`
3. Click **Send**

---

#### 7. Khách hàng gửi yêu cầu hủy phòng
**Endpoint:** `PUT /api/bookings/:id/request-cancel`

**Mô tả:** Khách hàng gửi yêu cầu hủy đơn đặt phòng (chuyển status sang `Cancel_Requested`)

**Path Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| id | string | ID của đơn đặt phòng |

**Request Body:**
```json
{
  "reason": "Thay đổi kế hoạch du lịch"
}
```

**Response thành công (200):**
```json
{
  "message": "Đã gửi yêu cầu hủy phòng đến chủ khách sạn!"
}
```

**Response lỗi (400):**
```json
{
  "message": "Chỉ đơn hàng đã xác nhận mới có thể gửi yêu cầu hủy!"
}
```

**Response lỗi (404):**
```json
{
  "message": "Không tìm thấy đơn hàng!"
}
```

**Cách test với Postman:**
1. Method: `PUT`
2. URL: `http://localhost:3000/api/bookings/booking_1/request-cancel`
3. Headers: `Content-Type: application/json`
4. Body (raw JSON):
```json
{
  "reason": "Thay đổi kế hoạch du lịch"
}
```
5. Click **Send**

---

#### 8. Admin xử lý yêu cầu hủy phòng
**Endpoint:** `PUT /api/bookings/:id/handle-cancel`

**Mô tả:** Admin duyệt hoặc từ chối yêu cầu hủy phòng

**Path Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| id | string | ID của đơn đặt phòng |

**Request Body:**
```json
{
  "action": "approve",
  "adminNote": "Đã duyệt yêu cầu hủy"
}
```

**Các giá trị action:**
- `approve`: Đồng ý hủy (chuyển status sang `Cancelled`)
- `reject`: Từ chối hủy (chuyển status về `Confirmed`)


**Response thành công (200) - Approve:**
```json
{
  "message": "Đã XÁC NHẬN hủy phòng thành công!"
}
```

**Response thành công (200) - Reject:**
```json
{
  "message": "Đã TỪ CHỐI yêu cầu hủy, đơn hàng vẫn có hiệu lực."
}
```

**Response lỗi (400):**
```json
{
  "message": "Đơn hàng này không nằm trong trạng thái chờ duyệt hủy!"
}
```

**Cách test với Postman:**
1. Method: `PUT`
2. URL: `http://localhost:3000/api/bookings/booking_1/handle-cancel`
3. Headers: `Content-Type: application/json`
4. Body (raw JSON):
```json
{
  "action": "approve",
  "adminNote": "Đã duyệt yêu cầu hủy"
}
```
5. Click **Send**

---

### 👤 NHÓM API: USERS (`/api/users`)

#### 9. Thêm lịch sử tìm kiếm
**Endpoint:** `POST /api/users/:id/search-history`

**Mô tả:** Lưu lịch sử tìm kiếm của người dùng (chạy ngầm khi user search)

**Path Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| id | string | ID của người dùng |

**Request Body:**
```json
{
  "city": "Đà Nẵng",
  "checkIn": "2026-05-10T14:00:00Z",
  "checkOut": "2026-05-12T12:00:00Z",
  "guests": 2,
  "rooms": 1
}
```

**Response thành công (201):**
```json
{
  "message": "Đã lưu lịch sử tìm kiếm ngầm thành công!"
}
```

**Response lỗi (400):**
```json
{
  "message": "Cần có ít nhất tên thành phố để lưu lịch sử!"
}
```

**Cách test với Postman:**
1. Method: `POST`
2. URL: `http://localhost:3000/api/users/user_1/search-history`
3. Headers: `Content-Type: application/json`
4. Body (raw JSON): Copy request body ở trên
5. Click **Send**

---

#### 10. Lấy lịch sử tìm kiếm
**Endpoint:** `GET /api/users/:id/search-history`

**Mô tả:** Lấy danh sách lịch sử tìm kiếm của người dùng (sắp xếp mới nhất lên đầu)

**Path Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| id | string | ID của người dùng |

**Query Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| page | number | Số trang (mặc định: 1) |
| limit | number | Số kết quả/trang (mặc định: 10) |


**Response thành công (200):**
```json
{
  "message": "Lấy lịch sử thành công!",
  "data": [
    {
      "city": "Đà Nẵng",
      "checkIn": "2026-05-10T14:00:00Z",
      "checkOut": "2026-05-12T12:00:00Z",
      "guests": 2,
      "rooms": 1,
      "searchedAt": "2026-04-08T10:30:00.000Z"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "limit": 10,
    "totalPages": 1,
    "totalItems": 5
  }
}
```

**Response lỗi (404):**
```json
{
  "message": "Người dùng không tồn tại!"
}
```

**Cách test với Postman:**
1. Method: `GET`
2. URL: `http://localhost:3000/api/users/user_1/search-history?page=1&limit=10`
3. Click **Send**

---

#### 11. Gợi ý khách sạn dành riêng cho user
**Endpoint:** `GET /api/users/:id/suggestions`

**Mô tả:** Gợi ý khách sạn dựa trên lịch sử tìm kiếm và đặt phòng của user

**Path Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| id | string | ID của người dùng |

**Query Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| page | number | Số trang (mặc định: 1) |
| limit | number | Số kết quả/trang (mặc định: 10) |

**Response thành công (200):**
```json
{
  "message": "Lấy danh sách gợi ý thành công!",
  "data": [
    {
      "id": "hotel_5",
      "name": "Khách sạn Đà Nẵng 3 Sao",
      "city": "Đà Nẵng",
      "star": 3,
      "minRoomPrice": 575000,
      "suggestedCapacity": 2,
      "images": ["https://..."],
      "amenities": [...]
    }
  ],
  "pagination": {
    "currentPage": 1,
    "limit": 10,
    "totalPages": 1,
    "totalItems": 8
  }
}
```

**Cách test với Postman:**
1. Method: `GET`
2. URL: `http://localhost:3000/api/users/user_1/suggestions?page=1&limit=10`
3. Click **Send**

---


### 🔐 NHÓM API: ADMIN (`/api/admin`)

#### 12. Lấy thống kê Dashboard
**Endpoint:** `GET /api/admin/dashboard/stats`

**Mô tả:** Lấy số liệu thống kê tổng quan cho trang Dashboard Admin

**Response thành công (200):**
```json
{
  "success": true,
  "data": {
    "totalUsers": 100,
    "totalHotels": 100,
    "totalBookings": 100,
    "totalVouchers": 100
  }
}
```

**Cách test với Postman:**
1. Method: `GET`
2. URL: `http://localhost:3000/api/admin/dashboard/stats`
3. Click **Send**

---

#### 13. Lấy 5 đơn đặt phòng mới nhất
**Endpoint:** `GET /api/admin/dashboard/recent-bookings`

**Mô tả:** Lấy 5 đơn đặt phòng gần đây nhất cho Dashboard

**Response thành công (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "booking_100",
      "hotelName": "Khách sạn Vũng Tàu 1 Sao",
      "guestName": "Khách Hàng Thứ 100",
      "date": "08/04/2026",
      "status": "confirmed"
    },
    {
      "id": "booking_99",
      "hotelName": "Khách sạn Phú Quốc 5 Sao",
      "guestName": "Khách Hàng Thứ 99",
      "date": "08/04/2026",
      "status": "pending"
    }
  ]
}
```

**Cách test với Postman:**
1. Method: `GET`
2. URL: `http://localhost:3000/api/admin/dashboard/recent-bookings`
3. Click **Send**

---

#### 14. Lấy danh sách Users (Admin)
**Endpoint:** `GET /api/admin/users`

**Mô tả:** Lấy danh sách người dùng với bộ lọc và tìm kiếm

**Query Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| type | string | Lọc theo loại: `customer`, `admin` |
| search | string | Tìm kiếm theo tên hoặc số điện thoại |
| page | number | Số trang (mặc định: 1) |
| limit | number | Số user/trang (mặc định: 20) |

**Response thành công (200):**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "user_1",
        "name": "Khách Hàng Thứ 1",
        "phone": "0900000001",
        "email": "khachhang1@gmail.com",
        "type": "customer",
        "status": "active",
        "joinDate": "2026-04-08T10:00:00.000Z",
        "avatarUrl": null
      }
    ],
    "total": 100,
    "page": 1,
    "limit": 20
  }
}
```

**Cách test với Postman:**
1. Method: `GET`
2. URL: `http://localhost:3000/api/admin/users?type=customer&search=Khách&page=1&limit=20`
3. Click **Send**

---


#### 15. Lấy chi tiết 1 User
**Endpoint:** `GET /api/admin/users/:id`

**Mô tả:** Xem thông tin chi tiết của 1 người dùng

**Path Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| id | string | ID của người dùng |

**Response thành công (200):**
```json
{
  "success": true,
  "data": {
    "id": "user_1",
    "name": "Khách Hàng Thứ 1",
    "phone": "0900000001",
    "email": "khachhang1@gmail.com",
    "type": "customer",
    "status": "active",
    "joinDate": "2026-04-08T10:00:00.000Z",
    "avatarUrl": null,
    "point": 10,
    "membershipLevel": "Silver"
  }
}
```

**Response lỗi (404):**
```json
{
  "success": false,
  "message": "Không tìm thấy người dùng này hoặc tài khoản đã bị xóa!"
}
```

**Cách test với Postman:**
1. Method: `GET`
2. URL: `http://localhost:3000/api/admin/users/user_1`
3. Click **Send**

---

#### 16. Thay đổi trạng thái User (Khóa/Mở khóa)
**Endpoint:** `PATCH /api/admin/users/:id/status`

**Mô tả:** Khóa hoặc mở khóa tài khoản người dùng

**Path Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| id | string | ID của người dùng |

**Request Body:**
```json
{
  "status": "locked"
}
```

**Các giá trị status:**
- `active`: Mở khóa tài khoản
- `locked`: Khóa tài khoản

**Response thành công (200):**
```json
{
  "success": true,
  "message": "Đã khóa tài khoản thành công!"
}
```

**Response lỗi (400):**
```json
{
  "success": false,
  "message": "Trạng thái không hợp lệ! Chỉ nhận 'active' hoặc 'locked'."
}
```

**Cách test với Postman:**
1. Method: `PATCH`
2. URL: `http://localhost:3000/api/admin/users/user_1/status`
3. Headers: `Content-Type: application/json`
4. Body (raw JSON):
```json
{
  "status": "locked"
}
```
5. Click **Send**

---

#### 17. Xóa User
**Endpoint:** `DELETE /api/admin/users/:id`

**Mô tả:** Xóa vĩnh viễn tài khoản người dùng

**Path Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| id | string | ID của người dùng |

**Response thành công (200):**
```json
{
  "success": true,
  "message": "Xóa tài khoản thành công"
}
```

**Response lỗi (404):**
```json
{
  "success": false,
  "message": "Không tìm thấy người dùng này!"
}
```

**Cách test với Postman:**
1. Method: `DELETE`
2. URL: `http://localhost:3000/api/admin/users/user_1`
3. Click **Send**

---


#### 18. Lấy danh sách Bookings (Admin)
**Endpoint:** `GET /api/admin/bookings`

**Mô tả:** Lấy danh sách đơn đặt phòng với bộ lọc siêu mạnh

**Query Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| status | string | Lọc theo trạng thái: `Confirmed`, `Pending`, `Cancelled`, `Cancel_Requested` |
| search | string | Tìm theo mã đơn, tên khách, tên khách sạn |
| startDate | string | Lọc từ ngày (ISO format: `2026-05-01`) |
| endDate | string | Lọc đến ngày (ISO format: `2026-05-31`) |
| sortBy | string | Sắp xếp: `newest`, `oldest`, `price_asc`, `price_desc` |
| page | number | Số trang (mặc định: 1) |
| limit | number | Số đơn/trang (mặc định: 20) |

**Response thành công (200):**
```json
{
  "success": true,
  "data": {
    "bookings": [
      {
        "id": "booking_1",
        "userId": "user_1",
        "hotelId": "hotel_1",
        "customerName": "Khách Hàng Thứ 1",
        "checkIn": "2026-05-10T14:00:00Z",
        "checkOut": "2026-05-12T12:00:00Z",
        "total": 1005000,
        "status": "Confirmed"
      }
    ],
    "total": 100,
    "page": 1,
    "limit": 20
  }
}
```

**Cách test với Postman:**
1. Method: `GET`
2. URL: `http://localhost:3000/api/admin/bookings?status=Confirmed&sortBy=newest&page=1&limit=20`
3. Click **Send**

**Ví dụ tìm kiếm nâng cao:**
```
http://localhost:3000/api/admin/bookings?search=Khách Hàng&startDate=2026-05-01&endDate=2026-05-31&sortBy=price_desc
```

---

#### 19. Lấy danh sách Vouchers (Admin)
**Endpoint:** `GET /api/admin/vouchers`

**Mô tả:** Lấy danh sách mã giảm giá với bộ lọc và tìm kiếm

**Query Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| status | string | Lọc theo trạng thái: `active`, `expired`, `disabled` |
| search | string | Tìm theo mã voucher hoặc tên chương trình |
| page | number | Số trang (mặc định: 1) |
| limit | number | Số voucher/trang (mặc định: 20) |

**Response thành công (200):**
```json
{
  "success": true,
  "data": {
    "vouchers": [
      {
        "id": "voucher_1",
        "code": "SUMMER1",
        "name": "Khuyến mãi chưa có tên",
        "discountType": "Percentage",
        "discountValue": 6,
        "maxDiscount": 0,
        "minSpend": 0,
        "usageLimit": 0,
        "usedCount": 0,
        "startDate": null,
        "endDate": null,
        "targetType": "all",
        "status": "Active"
      }
    ],
    "total": 100,
    "page": 1,
    "limit": 20
  }
}
```

**Cách test với Postman:**
1. Method: `GET`
2. URL: `http://localhost:3000/api/admin/vouchers?status=Active&search=SUMMER&page=1&limit=20`
3. Click **Send**

---


#### 20. Lấy chi tiết 1 Voucher
**Endpoint:** `GET /api/admin/vouchers/:id`

**Mô tả:** Xem thông tin chi tiết của 1 mã giảm giá

**Path Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| id | string | ID của voucher |

**Response thành công (200):**
```json
{
  "success": true,
  "data": {
    "id": "voucher_1",
    "code": "SUMMER1",
    "name": "Khuyến mãi chưa có tên",
    "discountType": "Percentage",
    "discountValue": 6,
    "maxDiscount": 0,
    "minSpend": 0,
    "usageLimit": 0,
    "usedCount": 0,
    "startDate": null,
    "endDate": null,
    "targetType": "all",
    "status": "Active",
    "description": "Chưa có mô tả chi tiết cho khuyến mãi này."
  }
}
```

**Response lỗi (404):**
```json
{
  "success": false,
  "message": "Không tìm thấy mã giảm giá này hoặc đã bị xóa!"
}
```

**Cách test với Postman:**
1. Method: `GET`
2. URL: `http://localhost:3000/api/admin/vouchers/voucher_1`
3. Click **Send**

---

#### 21. Tạo Voucher mới
**Endpoint:** `POST /api/admin/vouchers`

**Mô tả:** Tạo mã giảm giá mới

**Request Body:**
```json
{
  "code": "NEWYEAR2026",
  "name": "Khuyến mãi Tết Nguyên Đán 2026",
  "discountType": "percent",
  "discountValue": 20,
  "maxDiscount": 500000,
  "minSpend": 1000000,
  "usageLimit": 100,
  "startDate": "2026-01-01T00:00:00Z",
  "endDate": "2026-01-31T23:59:59Z",
  "targetType": "all",
  "status": "active"
}
```

**Các trường bắt buộc:**
- `code`: Mã voucher (sẽ tự động chuyển thành chữ IN HOA)
- `name`: Tên chương trình khuyến mãi
- `discountType`: Loại giảm giá (`percent` hoặc `fixed`)
- `discountValue`: Giá trị giảm (% hoặc số tiền)
- `startDate`: Ngày bắt đầu
- `endDate`: Ngày kết thúc

**Response thành công (201):**
```json
{
  "success": true,
  "message": "Tạo voucher thành công",
  "data": {
    "id": "abc123xyz"
  }
}
```

**Response lỗi (400) - Mã trùng:**
```json
{
  "success": false,
  "message": "Mã voucher 'NEWYEAR2026' đã tồn tại! Vui lòng tạo mã khác."
}
```

**Cách test với Postman:**
1. Method: `POST`
2. URL: `http://localhost:3000/api/admin/vouchers`
3. Headers: `Content-Type: application/json`
4. Body (raw JSON): Copy request body ở trên
5. Click **Send**

---


#### 22. Cập nhật Voucher
**Endpoint:** `PUT /api/admin/vouchers/:id`

**Mô tả:** Chỉnh sửa thông tin mã giảm giá

**Path Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| id | string | ID của voucher |

**Request Body:**
```json
{
  "code": "NEWYEAR2026",
  "name": "Khuyến mãi Tết Nguyên Đán 2026 - Cập nhật",
  "discountType": "percent",
  "discountValue": 25,
  "maxDiscount": 600000,
  "minSpend": 1000000,
  "usageLimit": 150,
  "startDate": "2026-01-01T00:00:00Z",
  "endDate": "2026-01-31T23:59:59Z",
  "targetType": "all",
  "status": "active"
}
```

**Response thành công (200):**
```json
{
  "success": true,
  "message": "Cập nhật voucher thành công"
}
```

**Response lỗi (400) - Mã trùng:**
```json
{
  "success": false,
  "message": "Mã voucher 'NEWYEAR2026' đã tồn tại ở một chương trình khác! Vui lòng chọn mã khác."
}
```

**Response lỗi (404):**
```json
{
  "success": false,
  "message": "Không tìm thấy mã giảm giá này!"
}
```

**Cách test với Postman:**
1. Method: `PUT`
2. URL: `http://localhost:3000/api/admin/vouchers/voucher_1`
3. Headers: `Content-Type: application/json`
4. Body (raw JSON): Copy request body ở trên
5. Click **Send**

---

#### 23. Xóa Voucher
**Endpoint:** `DELETE /api/admin/vouchers/:id`

**Mô tả:** Xóa vĩnh viễn mã giảm giá

**Path Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| id | string | ID của voucher |

**Response thành công (200):**
```json
{
  "success": true,
  "message": "Xóa voucher thành công"
}
```

**Response lỗi (404):**
```json
{
  "success": false,
  "message": "Không tìm thấy mã giảm giá này!"
}
```

**Cách test với Postman:**
1. Method: `DELETE`
2. URL: `http://localhost:3000/api/admin/vouchers/voucher_1`
3. Click **Send**

---


## 🧪 HƯỚNG DẪN TEST VỚI POSTMAN

### Bước 1: Cài đặt Postman
- Tải Postman tại: https://www.postman.com/downloads/
- Hoặc sử dụng Postman Web: https://web.postman.com/

### Bước 2: Tạo Collection mới
1. Mở Postman
2. Click **New** → **Collection**
3. Đặt tên: `Hotel Booking API`
4. Thêm biến môi trường:
   - Variable: `base_url`
   - Initial Value: `http://localhost:3000`

### Bước 3: Tạo Request
1. Click vào Collection vừa tạo
2. Click **Add Request**
3. Đặt tên request (vd: "Get All Hotels")
4. Chọn Method (GET, POST, PUT, DELETE, PATCH)
5. Nhập URL: `{{base_url}}/api/hotels`

### Bước 4: Cấu hình Headers (cho POST/PUT/PATCH)
Khi gửi dữ liệu JSON, cần thêm header:
- Key: `Content-Type`
- Value: `application/json`

### Bước 5: Cấu hình Body (cho POST/PUT/PATCH)
1. Chọn tab **Body**
2. Chọn **raw**
3. Chọn định dạng **JSON**
4. Nhập dữ liệu JSON

### Bước 6: Gửi Request
Click nút **Send** và xem kết quả ở phần **Response**

---

## 📊 BẢNG TỔNG HỢP API

| STT | Method | Endpoint | Mô tả | Phân trang |
|-----|--------|----------|-------|------------|
| 1 | GET | `/api/hotels` | Lấy danh sách khách sạn | ✅ |
| 2 | GET | `/api/hotels/search` | Tìm kiếm khách sạn | ✅ |
| 3 | POST | `/api/hotels/filter` | Lọc và sắp xếp khách sạn | ✅ |
| 4 | GET | `/api/hotels/:id` | Chi tiết khách sạn | ❌ |
| 5 | POST | `/api/bookings` | Tạo đơn đặt phòng | ❌ |
| 6 | GET | `/api/bookings` | Danh sách đơn đặt phòng | ✅ |
| 7 | PUT | `/api/bookings/:id/request-cancel` | Gửi yêu cầu hủy | ❌ |
| 8 | PUT | `/api/bookings/:id/handle-cancel` | Xử lý yêu cầu hủy | ❌ |
| 9 | POST | `/api/users/:id/search-history` | Thêm lịch sử tìm kiếm | ❌ |
| 10 | GET | `/api/users/:id/search-history` | Lấy lịch sử tìm kiếm | ✅ |
| 11 | GET | `/api/users/:id/suggestions` | Gợi ý khách sạn | ✅ |
| 12 | GET | `/api/admin/dashboard/stats` | Thống kê Dashboard | ❌ |
| 13 | GET | `/api/admin/dashboard/recent-bookings` | 5 đơn mới nhất | ❌ |
| 14 | GET | `/api/admin/users` | Danh sách Users | ✅ |
| 15 | GET | `/api/admin/users/:id` | Chi tiết User | ❌ |
| 16 | PATCH | `/api/admin/users/:id/status` | Khóa/Mở khóa User | ❌ |
| 17 | DELETE | `/api/admin/users/:id` | Xóa User | ❌ |
| 18 | GET | `/api/admin/bookings` | Danh sách Bookings (Admin) | ✅ |
| 19 | GET | `/api/admin/vouchers` | Danh sách Vouchers | ✅ |
| 20 | GET | `/api/admin/vouchers/:id` | Chi tiết Voucher | ❌ |
| 21 | POST | `/api/admin/vouchers` | Tạo Voucher | ❌ |
| 22 | PUT | `/api/admin/vouchers/:id` | Cập nhật Voucher | ❌ |
| 23 | DELETE | `/api/admin/vouchers/:id` | Xóa Voucher | ❌ |

---


## 🎯 CÁC TRƯỜNG HỢP TEST QUAN TRỌNG

### Test Case 1: Tìm kiếm khách sạn cơ bản
```
GET http://localhost:3000/api/hotels/search?city=Đà Nẵng&guests=2&rooms=1
```
**Kết quả mong đợi:** Trả về danh sách khách sạn ở Đà Nẵng có phòng chứa được 2 người

---

### Test Case 2: Lọc khách sạn theo giá và sao
```
POST http://localhost:3000/api/hotels/filter
Body:
{
  "city": "Hà Nội",
  "minPrice": 500000,
  "maxPrice": 1000000,
  "minStar": 4,
  "sortBy": "price_asc"
}
```
**Kết quả mong đợi:** Khách sạn 4-5 sao ở Hà Nội, giá 500k-1tr, sắp xếp tăng dần

---

### Test Case 3: Đặt phòng thành công
```
POST http://localhost:3000/api/bookings
Body:
{
  "hotelId": "hotel_1",
  "hotelName": "Khách sạn Hà Nội 2 Sao",
  "customerInfo": {
    "firstName": "Văn A",
    "lastName": "Nguyễn",
    "email": "vana@gmail.com",
    "phone": "0901234567",
    "country": "Việt Nam"
  },
  "checkIn": "2026-05-10T14:00:00Z",
  "checkOut": "2026-05-12T12:00:00Z",
  "bookedRooms": [
    {
      "roomTypeId": "roomtype_1",
      "quantity": 1,
      "price": 515000
    }
  ],
  "originalPrice": 1030000,
  "discount": 0,
  "totalPrice": 1030000
}
```
**Kết quả mong đợi:** Status 201, trả về bookingId

---

### Test Case 4: Khách hàng gửi yêu cầu hủy phòng
```
PUT http://localhost:3000/api/bookings/booking_1/request-cancel
Body:
{
  "reason": "Thay đổi kế hoạch du lịch"
}
```
**Kết quả mong đợi:** Status chuyển sang `Cancel_Requested`

---

### Test Case 5: Admin duyệt hủy phòng
```
PUT http://localhost:3000/api/bookings/booking_1/handle-cancel
Body:
{
  "action": "approve",
  "adminNote": "Đã duyệt yêu cầu hủy"
}
```
**Kết quả mong đợi:** Status chuyển sang `Cancelled`

---

### Test Case 6: Tạo voucher mới
```
POST http://localhost:3000/api/admin/vouchers
Body:
{
  "code": "SUMMER2026",
  "name": "Khuyến mãi mùa hè 2026",
  "discountType": "percent",
  "discountValue": 15,
  "maxDiscount": 300000,
  "minSpend": 500000,
  "usageLimit": 50,
  "startDate": "2026-06-01T00:00:00Z",
  "endDate": "2026-08-31T23:59:59Z",
  "targetType": "all",
  "status": "active"
}
```
**Kết quả mong đợi:** Status 201, trả về ID voucher mới

---

### Test Case 7: Tìm kiếm đơn hàng theo khoảng thời gian
```
GET http://localhost:3000/api/admin/bookings?startDate=2026-05-01&endDate=2026-05-31&sortBy=price_desc
```
**Kết quả mong đợi:** Danh sách đơn hàng từ 1/5 đến 31/5, sắp xếp giá giảm dần

---


## 🔍 XỬ LÝ LỖI THƯỜNG GẶP

### Lỗi 1: Cannot GET /api/hotels
**Nguyên nhân:** Server chưa chạy hoặc URL sai

**Giải pháp:**
```bash
# Kiểm tra server đang chạy
node index.js

# Kiểm tra URL đúng
http://localhost:3000/api/hotels
```

---

### Lỗi 2: 400 Bad Request
**Nguyên nhân:** Thiếu tham số bắt buộc hoặc dữ liệu không hợp lệ

**Giải pháp:**
- Kiểm tra lại Request Body
- Đảm bảo các trường bắt buộc đã được điền
- Kiểm tra định dạng dữ liệu (số, chuỗi, ngày tháng)

---

### Lỗi 3: 404 Not Found
**Nguyên nhân:** ID không tồn tại trong database

**Giải pháp:**
- Kiểm tra lại ID có đúng không
- Chạy `node seed.js` để tạo dữ liệu mẫu
- Sử dụng ID từ response của API khác

---

### Lỗi 4: 500 Internal Server Error
**Nguyên nhân:** Lỗi server hoặc Firebase

**Giải pháp:**
- Kiểm tra console log của server
- Kiểm tra file `serviceAccountKey.json` có tồn tại không
- Kiểm tra kết nối Firebase

---

### Lỗi 5: CORS Error
**Nguyên nhân:** Frontend gọi API từ domain khác

**Giải pháp:**
Backend đã cấu hình CORS trong `index.js`:
```javascript
app.use(cors());
```
Nếu vẫn lỗi, có thể cấu hình cụ thể:
```javascript
app.use(cors({
  origin: 'http://localhost:8080'
}));
```

---

## 📝 GHI CHÚ QUAN TRỌNG

### 1. Phân trang
- Hầu hết API đều hỗ trợ phân trang với `page` và `limit`
- Mặc định: `page=1`, `limit=10` (hoặc 20 cho Admin)
- Response luôn có block `pagination` chứa thông tin phân trang

### 2. Định dạng ngày tháng
- Input: ISO 8601 format (`2026-05-10T14:00:00Z`)
- Output: ISO 8601 hoặc DD/MM/YYYY (tùy API)

### 3. Trạng thái đơn hàng (Booking Status)
- `Confirmed`: Đã xác nhận
- `Pending`: Đang chờ xử lý
- `Cancel_Requested`: Khách yêu cầu hủy
- `Cancelled`: Đã hủy

### 4. Loại giảm giá (Discount Type)
- `percent`: Giảm theo phần trăm
- `fixed`: Giảm số tiền cố định

### 5. Trạng thái User
- `active`: Tài khoản hoạt động
- `locked`: Tài khoản bị khóa

### 6. Firebase Collections
- `Users`: Người dùng
- `Hotels`: Khách sạn
- `RoomTypes`: Loại phòng
- `Bookings`: Đơn đặt phòng
- `Vouchers`: Mã giảm giá
- `Reviews`: Đánh giá
- `Conversations`: Tin nhắn

---


## 🚀 TIPS & TRICKS

### 1. Import Postman Collection
Tạo file JSON với tất cả API để import vào Postman:

```json
{
  "info": {
    "name": "Hotel Booking API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Hotels",
      "item": [
        {
          "name": "Get All Hotels",
          "request": {
            "method": "GET",
            "url": "{{base_url}}/api/hotels?page=1&limit=10"
          }
        }
      ]
    }
  ]
}
```

### 2. Sử dụng Environment Variables
Trong Postman, tạo các biến:
- `base_url`: `http://localhost:3000`
- `user_id`: `user_1`
- `hotel_id`: `hotel_1`
- `booking_id`: `booking_1`

Sử dụng: `{{base_url}}/api/users/{{user_id}}/suggestions`

### 3. Test Scripts trong Postman
Thêm vào tab **Tests** để tự động kiểm tra response:

```javascript
// Kiểm tra status code
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

// Kiểm tra có data không
pm.test("Response has data", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.data).to.exist;
});

// Lưu ID vào biến
var jsonData = pm.response.json();
pm.environment.set("booking_id", jsonData.bookingId);
```

### 4. Pre-request Scripts
Tự động tạo dữ liệu ngẫu nhiên:

```javascript
// Tạo email ngẫu nhiên
pm.environment.set("random_email", "user" + Math.floor(Math.random() * 1000) + "@gmail.com");

// Tạo số điện thoại ngẫu nhiên
pm.environment.set("random_phone", "090" + Math.floor(Math.random() * 10000000));
```

### 5. Chạy Collection tự động
Sử dụng Newman (CLI tool của Postman):

```bash
# Cài đặt Newman
npm install -g newman

# Chạy collection
newman run hotel-booking-api.json -e environment.json
```

---

## 📚 TÀI LIỆU THAM KHẢO

### Express.js
- Docs: https://expressjs.com/
- Routing: https://expressjs.com/en/guide/routing.html

### Firebase Firestore
- Docs: https://firebase.google.com/docs/firestore
- Query: https://firebase.google.com/docs/firestore/query-data/queries

### Postman
- Docs: https://learning.postman.com/docs/getting-started/introduction/
- Testing: https://learning.postman.com/docs/writing-scripts/test-scripts/

---

## 🎓 KẾT LUẬN

Tài liệu này cung cấp hướng dẫn chi tiết về:
- ✅ Cài đặt và chạy backend
- ✅ 23 API endpoints với đầy đủ thông tin
- ✅ Cách test từng API với Postman
- ✅ Xử lý lỗi thường gặp
- ✅ Tips & tricks nâng cao

**Lưu ý:** 
- Đảm bảo server đang chạy trước khi test API
- Chạy `node seed.js` để có dữ liệu mẫu
- Kiểm tra console log để debug lỗi

**Liên hệ hỗ trợ:**
- Nếu gặp vấn đề, kiểm tra console log của server
- Đọc kỹ error message để xác định nguyên nhân
- Tham khảo tài liệu Firebase và Express.js

---

**Chúc bạn test API thành công! 🎉**

*Tài liệu được tạo ngày: 08/04/2026*
*Phiên bản Backend: 1.0.0*
