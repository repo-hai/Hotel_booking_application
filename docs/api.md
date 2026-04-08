# Danh sách tất cả API cần thiết cho Hotel Owner - Hotel Booking App

## Context
Dựa trên toàn bộ chức năng quản lý khách sạn (quản lý khách sạn, phòng, booking, vận hành phòng, đánh giá và thống kê), liệt kê đầy đủ API cho backend.

**Base URL:** `/api/owner`

---

## 1. AUTH - Xác thực Owner (2 API)

| # | Method | Endpoint | Mô tả |
|---|--------|----------|--------|
| 1 | POST | `/api/owner/auth/login` | Đăng nhập chủ khách sạn |
| 2 | POST | `/api/owner/auth/logout` | Đăng xuất |

---

## 3. HOTELS - Quản lý khách sạn (5 API)

| # | Method | Endpoint | Mô tả |
|---|--------|----------|--------|
| 3 | POST | `/api/owner/hotels` | Tạo khách sạn mới |
| 4 | GET | `/api/owner/hotels` | Lấy danh sách khách sạn của owner |
| 5 | GET | `/api/owner/hotels/:id` | Lấy chi tiết khách sạn |
| 6 | PUT | `/api/owner/hotels/:id` | Cập nhật thông tin khách sạn |
| 7 | DELETE | `/api/owner/hotels/:id` | Xóa khách sạn |

---

## 4. ROOM TYPE - Quản lý phòng (6 API)

| # | Method | Endpoint | Mô tả |
|---|--------|----------|--------|
| 8 | POST | `/api/owner/hotels/:hotelId/room-types` | Tạo loại phòng (Deluxe, Standard...) |
| 9 | GET | `/api/owner/hotels/:hotelId/room-types` | Lấy danh sách loại phòng |
| 10 | GET | `/api/owner/room-types/:id` | Chi tiết loại phòng |
| 11 | PUT | `/api/owner/room-types/:id` | Cập nhật loại phòng |
| 12 | DELETE | `/api/owner/room-types/:id` | Xóa loại phòng |
| 13 | POST | `/api/owner/room-types/:roomTypeId/rooms` | Tạo danh sách phòng (101, 102...) |

---

## 5. ROOMS - Quản lý phòng cụ thể (4 API)

| # | Method | Endpoint | Mô tả |
|---|--------|----------|--------|
| 14 | GET | `/api/owner/room-types/:roomTypeId/rooms` | Lấy danh sách phòng theo loại |
| 15 | GET | `/api/owner/rooms/:id` | Chi tiết phòng |
| 16 | PUT | `/api/owner/rooms/:id` | Cập nhật thông tin phòng |
| 17 | DELETE | `/api/owner/rooms/:id` | Xóa phòng |

---

## 6. BOOKINGS - Quản lý booking (5 API)

| # | Method | Endpoint | Mô tả |
|---|--------|----------|--------|
| 18 | GET | `/api/owner/bookings?status=&page=&limit=` | Lấy danh sách booking |
| 19 | GET | `/api/owner/bookings/:id` | Chi tiết booking |
| 20 | PATCH | `/api/owner/bookings/:id/confirm` | Xác nhận booking |
| 21 | PATCH | `/api/owner/bookings/:id/reject` | Từ chối booking |
| 22 | PATCH | `/api/owner/bookings/:id/cancel` | Hủy booking |

---


## 7. CHECK-IN / CHECK-OUT (2 API)

| # | Method | Endpoint | Mô tả |
|---|--------|----------|--------|
| 23 | POST | `/api/owner/bookings/:id/check-in` | Khách check-in (auto assign room + update trạng thái) |
| 24 | POST | `/api/owner/bookings/:id/check-out` | Check-out |

---

## 8. REVIEWS - Xem đánh giá (2 API)

| # | Method | Endpoint | Mô tả |
|---|--------|----------|--------|
| 25 | GET | `/api/owner/reviews?hotelId=` | Lấy danh sách review |
| 26 | GET | `/api/owner/reviews/:id` | Chi tiết review |

---

## 9. ANALYTICS - Doanh thu & thống kê (1 API)

| # | Method | Endpoint | Mô tả |
|---|--------|----------|--------|
| 27 | GET | `GET /api/owner/analytics/summary?from=&to=` | Thống kê chung trong khoảng thời gian |


---

## 10. UPLOAD (1 API)

| # | Method | Endpoint | Mô tả |
|---|--------|----------|--------|
| 28 | POST | `/api/owner/upload/image` | Upload ảnh khách sạn/phòng |

---

## TỔNG KẾT: 28 API

| Module | Số API |
|--------|--------|
| Auth | 2 |
| Hotels | 5 |
| Room Types | 6 |
| Rooms | 4 |
| Bookings | 5 |
| Check-in/out | 2 |
| Reviews | 2 |
| Analytics | 1 |
| Upload | 1 |
| **Tổng** | **28** |

---
