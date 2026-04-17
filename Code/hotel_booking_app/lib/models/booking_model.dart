import 'package:flutter/material.dart';

enum BookingStatus { confirmed, pending, cancelRequested, cancelled, completed }

class BookedRoom {
  final String roomTypeId;
  final int quantity;
  final int price;
  final String? roomName;

  BookedRoom({
    required this.roomTypeId,
    required this.quantity,
    required this.price,
    this.roomName,
  });

  factory BookedRoom.fromJson(Map<String, dynamic> j) => BookedRoom(
        roomTypeId: (j['roomTypeId'] ?? '').toString(),
        quantity: _toInt(j['quantity']),
        price: _toInt(j['price']),
        roomName: j['roomName'] as String?,
      );

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }
}

class BookingModel {
  final String id;
  final String hotelId;
  final String hotelName;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String customerCountry;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final List<BookedRoom> bookedRooms;
  final int originalPrice;
  final int discount;
  final int total;
  BookingStatus status;
  final DateTime? createdAt;
  final String? cancellationReason;
  final String? adminNote;

  BookingModel({
    required this.id,
    required this.hotelId,
    required this.hotelName,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.customerCountry,
    required this.checkIn,
    required this.checkOut,
    required this.bookedRooms,
    required this.originalPrice,
    required this.discount,
    required this.total,
    required this.status,
    required this.createdAt,
    this.cancellationReason,
    this.adminNote,
  });

  factory BookingModel.fromJson(Map<String, dynamic> j) {
    final rawRooms = (j['bookedRooms'] as List?) ?? const [];
    return BookingModel(
      id: (j['id'] ?? '').toString(),
      hotelId: (j['hotelId'] ?? '').toString(),
      hotelName: (j['hotelName'] ?? '') as String,
      customerName: (j['customerName'] ?? '') as String,
      customerPhone: (j['customerPhone'] ?? '') as String,
      customerEmail: (j['customerEmail'] ?? '') as String,
      customerCountry: (j['customerCountry'] ?? '') as String,
      checkIn: _parseDate(j['checkIn']),
      checkOut: _parseDate(j['checkOut']),
      bookedRooms: rawRooms
          .whereType<Map>()
          .map((e) => BookedRoom.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      originalPrice: _toInt(j['originalPrice']),
      discount: _toInt(j['discount']),
      total: _toInt(j['total']),
      status: _parseStatus(j['status']),
      createdAt: _parseDate(j['createdAt']),
      cancellationReason: j['cancellationReason'] as String?,
      adminNote: j['adminNote'] as String?,
    );
  }

  static BookingStatus _parseStatus(dynamic v) {
    final s = (v ?? '').toString().toLowerCase();
    switch (s) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancel_requested':
        return BookingStatus.cancelRequested;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      case 'pending':
      default:
        return BookingStatus.pending;
    }
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }

  String get statusLabel {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Đã xác nhận';
      case BookingStatus.pending:
        return 'Chờ xác nhận';
      case BookingStatus.cancelRequested:
        return 'Yêu cầu hủy';
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
      case BookingStatus.cancelRequested:
        return const Color(0xFFFF7043);
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
      case BookingStatus.cancelRequested:
        return Icons.help_outline;
      case BookingStatus.cancelled:
        return Icons.cancel_outlined;
      case BookingStatus.completed:
        return Icons.task_alt;
    }
  }

  int get nights {
    if (checkIn == null || checkOut == null) return 0;
    return checkOut!.difference(checkIn!).inDays;
  }

  int get roomCount =>
      bookedRooms.fold<int>(0, (sum, r) => sum + r.quantity);

  String get roomSummary {
    if (bookedRooms.isEmpty) return '—';
    return bookedRooms
        .map((r) =>
            '${r.quantity} x ${r.roomName ?? r.roomTypeId} (${_formatNumber(r.price)}đ)')
        .join(', ');
  }

  String get formattedTotal => '${_formatNumber(total)}đ';
  String get formattedOriginal => '${_formatNumber(originalPrice)}đ';
  String get formattedDiscount => '${_formatNumber(discount)}đ';

  static String formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
