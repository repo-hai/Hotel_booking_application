import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking_history_model.dart';
import '../../core/constants/api_constants.dart';

class BookingService {
  /// Lấy userId từ SharedPreferences
  static Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  /// Lấy danh sách đặt phòng của user (lọc theo userId + status)
  static Future<List<BookingHistoryModel>> getBookings({String? status}) async {
    try {
      final userId = await _getUserId();
      if (userId == null || userId.isEmpty) return [];

      // Lọc theo userId để chỉ lấy booking của user hiện tại
      var url = '${ApiConstants.baseUrl}${ApiConstants.bookings}?userId=$userId&limit=50';
      if (status != null) url += '&status=$status';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List list = body['data'] ?? [];
        return list
            .map((e) => BookingHistoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error getBookings: $e');
    }
    return [];
  }

  /// Gửi yêu cầu hủy đặt phòng
  static Future<bool> requestCancel(String bookingId, String reason) async {
    try {
      final response = await http.put(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.bookings}/$bookingId/request-cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reason': reason}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Hủy hoàn toàn: gửi request-cancel rồi tự approve luôn
  static Future<bool> cancelBooking(String bookingId, String reason) async {
    try {
      // Bước 1: Gửi yêu cầu hủy
      final req = await http.put(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.bookings}/$bookingId/request-cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reason': reason}),
      );
      if (req.statusCode != 200) return false;

      // Bước 2: Tự approve để status → Cancelled
      final approve = await http.put(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.bookings}/$bookingId/handle-cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'approve',
          'adminNote': 'Khách hàng tự hủy: $reason',
        }),
      );
      return approve.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
