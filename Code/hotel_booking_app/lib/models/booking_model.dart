import 'package:flutter/material.dart';

enum BookingStatus { confirmed, pending, cancelled, completed }

class BookingModel {
  final int id;
  final String hotelName;
  final String roomType;
  final String guestName;
  final String guestPhone;
  final String guestEmail;
  final DateTime checkin;
  final DateTime checkout;
  final int totalPrice;
  final int roomCount;
  final int guestCount;
  final DateTime bookedAt;
  final String paymentMethod;
  final String paymentStatus;
  BookingStatus status;

  BookingModel({
    required this.id,
    required this.hotelName,
    required this.roomType,
    required this.guestName,
    required this.guestPhone,
    required this.guestEmail,
    required this.checkin,
    required this.checkout,
    required this.totalPrice,
    required this.roomCount,
    required this.guestCount,
    required this.bookedAt,
    required this.paymentMethod,
    required this.paymentStatus,
    this.status = BookingStatus.pending,
  });

  String get statusLabel {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Đã xác nhận';
      case BookingStatus.pending:
        return 'Chờ xác nhận';
      case BookingStatus.cancelled:
        return 'Đã hủy';
      case BookingStatus.completed:
        return 'Hoàn thành';
    }
  }

  Color get statusColor {
    switch (status) {
      case BookingStatus.confirmed:
        return const Color(0xFF1565C0);
      case BookingStatus.pending:
        return const Color(0xFFFFA726);
      case BookingStatus.cancelled:
        return const Color(0xFFE53935);
      case BookingStatus.completed:
        return const Color(0xFF43A047);
    }
  }

  IconData get statusIcon {
    switch (status) {
      case BookingStatus.confirmed:
        return Icons.check_circle_outline;
      case BookingStatus.pending:
        return Icons.access_time;
      case BookingStatus.cancelled:
        return Icons.cancel_outlined;
      case BookingStatus.completed:
        return Icons.task_alt;
    }
  }

  int get nights {
    return checkout.difference(checkin).inDays;
  }

  String get formattedPrice {
    final str = totalPrice.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return '${buffer}đ';
  }

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class MockBookings {
  static final List<BookingModel> all = [
    BookingModel(
      id: 1001,
      hotelName: 'Homestay Cát Bà Sea',
      roomType: 'Phòng Deluxe Đôi',
      guestName: 'Trần Anh Tuấn',
      guestPhone: '0904 123 456',
      guestEmail: 'tuan.tran@example.com',
      checkin: DateTime(2026, 4, 10),
      checkout: DateTime(2026, 4, 13),
      totalPrice: 1500000,
      roomCount: 1,
      guestCount: 2,
      bookedAt: DateTime(2026, 4, 7),
      paymentMethod: 'Thẻ tín dụng',
      paymentStatus: 'Đã thanh toán',
      status: BookingStatus.pending,
    ),
    BookingModel(
      id: 1002,
      hotelName: 'Villa Lạng Sơn 123',
      roomType: 'Villa nguyên căn',
      guestName: 'Lê Thanh Hoa',
      guestPhone: '0988 765 432',
      guestEmail: 'hoa.le@example.com',
      checkin: DateTime(2026, 4, 15),
      checkout: DateTime(2026, 4, 17),
      totalPrice: 2400000,
      roomCount: 1,
      guestCount: 4,
      bookedAt: DateTime(2026, 4, 6),
      paymentMethod: 'Chuyển khoản',
      paymentStatus: 'Đã thanh toán',
      status: BookingStatus.confirmed,
    ),
    BookingModel(
      id: 1003,
      hotelName: 'Khách sạn Sapa View',
      roomType: 'Phòng Standard',
      guestName: 'Phạm Văn Hùng',
      guestPhone: '0912 345 678',
      guestEmail: 'hung.pham@example.com',
      checkin: DateTime(2026, 3, 20),
      checkout: DateTime(2026, 3, 22),
      totalPrice: 1600000,
      roomCount: 2,
      guestCount: 3,
      bookedAt: DateTime(2026, 3, 15),
      paymentMethod: 'Ví MoMo',
      paymentStatus: 'Đã hoàn tiền',
      status: BookingStatus.cancelled,
    ),
    BookingModel(
      id: 1004,
      hotelName: 'Homestay Cát Bà Sea',
      roomType: 'Phòng Superior',
      guestName: 'Đỗ Minh Trang',
      guestPhone: '0933 111 222',
      guestEmail: 'trang.do@example.com',
      checkin: DateTime(2026, 3, 1),
      checkout: DateTime(2026, 3, 4),
      totalPrice: 2100000,
      roomCount: 1,
      guestCount: 2,
      bookedAt: DateTime(2026, 2, 25),
      paymentMethod: 'Thẻ tín dụng',
      paymentStatus: 'Đã thanh toán',
      status: BookingStatus.completed,
    ),
    BookingModel(
      id: 1005,
      hotelName: 'Khách sạn Hà Nội Grand',
      roomType: 'Phòng Suite',
      guestName: 'Nguyễn Thị Mai',
      guestPhone: '0945 678 901',
      guestEmail: 'mai.nguyen@example.com',
      checkin: DateTime(2026, 4, 20),
      checkout: DateTime(2026, 4, 23),
      totalPrice: 4500000,
      roomCount: 1,
      guestCount: 2,
      bookedAt: DateTime(2026, 4, 5),
      paymentMethod: 'Thẻ tín dụng',
      paymentStatus: 'Chờ thanh toán',
      status: BookingStatus.pending,
    ),
  ];
}
