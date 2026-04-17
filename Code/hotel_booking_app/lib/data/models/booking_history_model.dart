/// Model đại diện cho 1 đơn đặt phòng trong lịch sử
class BookingHistoryModel {
  final String id;
  final String hotelId;
  final String hotelName;
  final String hotelAddress;
  final String hotelCity;
  final List<String> hotelImages;
  final int hotelStar;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String? checkIn;
  final String? checkOut;
  final double total;
  final double originalPrice;
  final double discount;
  final String status; // Confirmed, Cancel_Requested, Cancelled, Completed
  final String? createdAt;
  final List<Map<String, dynamic>> bookedRooms;

  const BookingHistoryModel({
    required this.id,
    required this.hotelId,
    required this.hotelName,
    required this.hotelAddress,
    required this.hotelCity,
    required this.hotelImages,
    required this.hotelStar,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    this.checkIn,
    this.checkOut,
    required this.total,
    required this.originalPrice,
    required this.discount,
    required this.status,
    this.createdAt,
    required this.bookedRooms,
  });

  factory BookingHistoryModel.fromJson(Map<String, dynamic> json) {
    return BookingHistoryModel(
      id: json['id'] ?? '',
      hotelId: json['hotelId'] ?? '',
      hotelName: json['hotelName'] ?? 'Khách sạn',
      hotelAddress: json['hotelAddress'] ?? json['customerCountry'] ?? '',
      hotelCity: json['hotelCity'] ?? '',
      hotelImages: List<String>.from(json['hotelImages'] ?? []),
      hotelStar: json['hotelStar'] ?? 0,
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      checkIn: json['checkIn'],
      checkOut: json['checkOut'],
      total: (json['total'] as num?)?.toDouble() ?? 0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ??
          ((json['total'] as num?)?.toDouble() ?? 0) * 1.1,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? 'Confirmed',
      createdAt: json['createdAt'],
      bookedRooms: List<Map<String, dynamic>>.from(
        (json['bookedRooms'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map)),
      ),
    );
  }

  /// Phân loại tab
  bool get isActive =>
      status == 'Confirmed' || status == 'Pending' || status == 'Cancel_Requested';
  bool get isPast =>
      status == 'Completed';
  bool get isCancelled =>
      status == 'Cancelled';

  String get statusLabel {
    switch (status) {
      case 'Pending':
        return 'Đang chờ xác nhận từ chỗ nghỉ';
      case 'Confirmed':
        return 'Đã xác nhận';
      case 'Cancel_Requested':
        return 'Đang chờ duyệt hủy';
      case 'Cancelled':
        return 'Đã hủy';
      case 'Completed':
        return 'Đã hoàn thành';
      default:
        return status;
    }
  }
}
