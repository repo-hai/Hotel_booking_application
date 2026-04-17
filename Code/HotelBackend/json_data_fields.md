# Tong hop truong du lieu trong cac file JSON

Tai lieu nay liet ke cac truong thong tin (field) cua tung loai data trong thu muc `Code/hotel_booking_app/HotelBackend/data`.

## 1) hotels.json

### 1.1 Hotel object
| Truong | Kieu du lieu | Mo ta ngan |
|---|---|---|
| ID | number | ID khach san |
| type | string | Loai co so luu tru (Khach san, Resort, Villa, Homestay, Can ho dich vu, ...) |
| name | string | Ten co so luu tru |
| description | string | Mo ta tong quan |
| telephone | string | So dien thoai |
| location | string | Dia diem |
| email | string | Email lien he |
| star | number | So sao danh gia |
| images | array<object> | Danh sach hinh anh |
| amenities | array<object> | Danh sach tien ich |

### 1.2 Hotel.images[] object
| Truong | Kieu du lieu | Mo ta ngan |
|---|---|---|
| ID | number | ID hinh anh |
| url | string | Duong dan hinh anh |

### 1.3 Hotel.amenities[] object
| Truong | Kieu du lieu | Mo ta ngan |
|---|---|---|
| ID | number | ID tien ich |
| name | string | Ten tien ich |
| icon | string | Ma icon hien thi |

## 2) roomType.json

### 2.1 RoomType object
| Truong | Kieu du lieu | Mo ta ngan |
|---|---|---|
| ID | number | ID loai phong |
| hotelID | number | ID khach san so huu loai phong |
| name | string | Ten loai phong |
| area | number | Dien tich (m2) |
| price | number | Gia phong |
| description | string | Mo ta loai phong |
| bedType | string | Loai giuong |
| capacity | number | So khach toi da |
| bedNum | number | So luong giuong |
| images | array<object> | Danh sach hinh phong |
| policies | array<object> | Danh sach chinh sach ap dung |
| amenities | array<object> | Danh sach tien ich phong |
| rooms | array<object> | Danh sach phong vat ly |

### 2.2 RoomType.images[] object
| Truong | Kieu du lieu | Mo ta ngan |
|---|---|---|
| ID | number | ID hinh anh |
| url | string | Duong dan hinh anh |

### 2.3 RoomType.policies[] object
| Truong | Kieu du lieu | Mo ta ngan |
|---|---|---|
| ID | number | ID chinh sach |
| name | string | Ten chinh sach |

### 2.4 RoomType.amenities[] object
| Truong | Kieu du lieu | Mo ta ngan |
|---|---|---|
| ID | number | ID tien ich |
| name | string | Ten tien ich |
| icon | string | Ma icon hien thi |

### 2.5 RoomType.rooms[] object
| Truong | Kieu du lieu | Mo ta ngan |
|---|---|---|
| ID | number | ID phong vat ly |
| roomNumber | string | So/ma phong |
| status | string | Trang thai phong (Available, Occupied, Cleaning, ...) |

## 3) user.json

### 3.1 User object
| Truong | Kieu du lieu | Mo ta ngan |
|---|---|---|
| ID | number | ID nguoi dung |
| Email | string | Email dang nhap |
| Password | string | Mat khau da hash |
| Phone | string | So dien thoai |
| Name | string | Ho ten |
| Location | string | Dia chi/khu vuc |
| Gender | string | Gioi tinh |
| DateOfBirth | string (date) | Ngay sinh (YYYY-MM-DD) |
| MembershipLevel | string \| null | Hang thanh vien |
| Point | number \| null | Diem tich luy |
| TotalSpent | number \| null | Tong chi tieu |
| Role | string | Vai tro (admin, owner, user, ...) |
| SearchingHistory | array<object> (optional) | Lich su tim kiem |
| CustomerBookingInfo | array<object> (optional) | Danh sach thong tin dat phong cua khach |

### 3.2 User.SearchingHistory[] object
| Truong | Kieu du lieu | Mo ta ngan |
|---|---|---|
| ID | number | ID ban ghi lich su |
| Location | string | Dia diem tim kiem |
| Checkin | string (date) | Ngay nhan phong |
| Checkout | string (date) | Ngay tra phong |
| RoomNum | number | So phong can dat |
| Capacity | number | So nguoi |

### 3.3 User.CustomerBookingInfo[] object
| Truong | Kieu du lieu | Mo ta ngan |
|---|---|---|
| ID | number | ID thong tin dat phong |
| Name | string | Ten nguoi dat |
| Email | string | Email lien he |
| Phone | string | So dien thoai |
| Country | string | Quoc gia |
| IsDefault | boolean | Co phai thong tin mac dinh khong |

## 4) vouchers.json

### 4.1 Voucher object
| Truong | Kieu du lieu | Mo ta ngan |
|---|---|---|
| ID | number | ID voucher |
| Code | string | Ma voucher |
| DiscountType | string | Loai giam gia (Percentage, ...) |
| Value | number | Gia tri giam (vd: 0.1 = 10%) |
| MaxDiscountValue | number | Muc giam toi da |
| MinSpend | number | Dieu kien chi tieu toi thieu |
| UsageLimit | number | So luot su dung toi da |
| Status | string | Trang thai voucher (Active, Expired, ...) |
| TargetType | string | Nhom khach hang ap dung |
| startDate | string (date) | Ngay bat dau |
| endDate | string (date) | Ngay ket thuc |
| UsageHistory | array<object> | Lich su su dung voucher |

### 4.2 Voucher.UsageHistory[] object
| Truong | Kieu du lieu | Mo ta ngan |
|---|---|---|
| ID | number | ID ban ghi su dung |
| UsedAt | string (date) | Ngay su dung |

---

Ghi chu:
- Du lieu trong cac file la danh sach (array) cac object.
- Mot so truong co the vang mat hoac null tuy theo vai tro/ngu canh (vi du: SearchingHistory, MembershipLevel).
- Kieu date dang duoc luu duoi dang string theo dinh dang `YYYY-MM-DD`.
