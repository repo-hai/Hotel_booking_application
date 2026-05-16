import 'customer_booking_info_model.dart';
import 'booked_room_model.dart';
import '../payment/payment_model.dart';

class Booking {
  final String id;
  final DateTime checkin;
  final DateTime checkout;
  final int total;
  final DateTime bookedAt;
  final String? cancellationReason;
  final String status;
  final String? assignedRoomNumber;
  final int depositAmount;
  
  final String? roomTypeName;
  final CustomerBookingInfo customerInfo;
  final List<BookedRoom> bookedRooms;
  final Payment? payment;

  Booking({
    required this.id,
    required this.checkin,
    required this.checkout,
    required this.total,
    required this.bookedAt,
    this.cancellationReason,
    required this.status,
    this.assignedRoomNumber,
    this.depositAmount = 0,
    this.roomTypeName,
    required this.customerInfo,
    required this.bookedRooms,
    this.payment,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString() ?? '',
      checkin: DateTime.parse(json['checkIn'] ?? json['checkin'] ?? DateTime.now().toIso8601String()),
      checkout: DateTime.parse(json['checkOut'] ?? json['checkout'] ?? DateTime.now().add(const Duration(days: 1)).toIso8601String()),
      total: json['total'] is int ? json['total'] : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      bookedAt: DateTime.parse(json['createdAt'] ?? json['bookedAt'] ?? DateTime.now().toIso8601String()),
      cancellationReason: json['cancellationReason'] ?? json['rejectReason'],
      status: json['status'] ?? 'Pending',
      assignedRoomNumber: json['assignedRoomNumber'],
      depositAmount: json['depositAmount'] != null 
          ? (json['depositAmount'] is int ? json['depositAmount'] : int.tryParse(json['depositAmount'].toString()) ?? 0)
          : (json['total'] is int ? (json['total'] * 0.2).round() : (int.tryParse(json['total']?.toString() ?? '0') ?? 0 * 0.2).round()),
      roomTypeName: json['roomTypeName'],
      customerInfo: json['customerBookingInfo'] != null 
          ? CustomerBookingInfo.fromJson(json['customerBookingInfo'])
          : CustomerBookingInfo.fromJson({'name': json['customerName'] ?? 'Khách hàng'}),
      bookedRooms: (json['bookedRooms'] as List? ?? [])
          .map((e) => BookedRoom.fromJson(e)).toList(),
      payment: json['payment'] != null ? Payment.fromJson(json['payment']) : null,
    );
  }
}