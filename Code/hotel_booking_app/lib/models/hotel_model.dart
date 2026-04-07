import 'package:flutter/material.dart';

enum HotelStatus { pending, approved, rejected }

class HotelModel {
  final int id;
  final String name;
  final String type;
  final String address;
  final String city;
  final String ownerName;
  final String ownerPhone;
  final Color ownerAvatarColor;
  final DateTime requestDate;
  final bool hasIdDocument;
  final bool hasBusinessLicense;
  final int pricePerNight;
  final int roomCount;
  final int imageCount;
  final List<String> amenities;
  HotelStatus status;

  HotelModel({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.city,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerAvatarColor,
    required this.requestDate,
    required this.hasIdDocument,
    required this.hasBusinessLicense,
    required this.pricePerNight,
    required this.roomCount,
    required this.imageCount,
    required this.amenities,
    this.status = HotelStatus.pending,
  });

  String get ownerInitials {
    final parts = ownerName.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return ownerName.substring(0, 2).toUpperCase();
  }

  String get statusLabel {
    switch (status) {
      case HotelStatus.pending:
        return 'CHỜ DUYỆT';
      case HotelStatus.approved:
        return 'ĐÃ DUYỆT';
      case HotelStatus.rejected:
        return 'ĐÃ TỪ CHỐI';
    }
  }

  Color get statusColor {
    switch (status) {
      case HotelStatus.pending:
        return const Color(0xFFFFA726);
      case HotelStatus.approved:
        return const Color(0xFF43A047);
      case HotelStatus.rejected:
        return const Color(0xFFE53935);
    }
  }

  String get formattedPrice {
    final str = pricePerNight.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return '${buffer}đ / đêm';
  }

  String get formattedRequestDate {
    return '${requestDate.day.toString().padLeft(2, '0')}/${requestDate.month.toString().padLeft(2, '0')}/${requestDate.year}';
  }
}

class MockHotels {
  static final List<HotelModel> pending = [
    HotelModel(
      id: 1,
      name: 'Homestay Cát Bà Sea',
      type: 'Homestay',
      address: 'Đường 1/4, Thị trấn Cát Bà, Huyện Cát Hải, Hải Phòng, Việt Nam',
      city: 'Hải Phòng, Việt Nam',
      ownerName: 'Nguyễn Văn A',
      ownerPhone: '0988 123 456',
      ownerAvatarColor: const Color(0xFF00838F),
      requestDate: DateTime(2026, 2, 23),
      hasIdDocument: true,
      hasBusinessLicense: true,
      pricePerNight: 500000,
      roomCount: 5,
      imageCount: 8,
      amenities: ['Wifi miễn phí', 'Chỗ đỗ xe', 'Lễ tân 24/7'],
    ),
    HotelModel(
      id: 2,
      name: 'Villa Lạng Sơn 123',
      type: 'Villa',
      address: 'Số 123, Đường Trần Đăng Ninh, TP Lạng Sơn, Việt Nam',
      city: 'Lạng Sơn, Việt Nam',
      ownerName: 'Trần Thị B',
      ownerPhone: '0977 444 555',
      ownerAvatarColor: const Color(0xFFC62828),
      requestDate: DateTime(2026, 2, 22),
      hasIdDocument: true,
      hasBusinessLicense: false,
      pricePerNight: 1200000,
      roomCount: 8,
      imageCount: 12,
      amenities: ['Wifi miễn phí', 'Hồ bơi', 'Bãi đỗ xe', 'Bếp chung'],
    ),
    HotelModel(
      id: 3,
      name: 'Khách sạn Sapa View',
      type: 'Khách sạn',
      address: 'Số 45, Đường Fansipan, TT Sa Pa, Lào Cai, Việt Nam',
      city: 'Lào Cai, Việt Nam',
      ownerName: 'Lê Minh C',
      ownerPhone: '0912 888 999',
      ownerAvatarColor: const Color(0xFF4527A0),
      requestDate: DateTime(2026, 2, 20),
      hasIdDocument: true,
      hasBusinessLicense: true,
      pricePerNight: 800000,
      roomCount: 20,
      imageCount: 15,
      amenities: ['Wifi miễn phí', 'Nhà hàng', 'Spa', 'Lễ tân 24/7', 'Phòng gym'],
    ),
  ];

  static final List<HotelModel> processed = [];
}
