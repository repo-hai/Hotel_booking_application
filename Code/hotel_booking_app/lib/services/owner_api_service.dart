import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/hotel/hotel_model.dart';
import '../models/room/room_type_model.dart';
import '../models/booking/booking_model.dart';
import '../models/review/review_model.dart';
import 'api_config.dart';

class OwnerApiService {
  static String get baseUrl => '${ApiConfig.baseUrl}/api/owner';

  // Lưu thông báo lỗi chi tiết nhất từ lần gọi API cuối
  String? lastError;

  // 1. Dashboard Stats
  Future<Map<String, dynamic>> getDashboardStats(String ownerId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dashboard/$ownerId'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] ?? {};
      }
      return {};
    } catch (e) {
      debugPrint("Lỗi getDashboardStats: $e");
      return {};
    }
  }

  // Get Owner Name
  Future<String?> getOwnerName(String ownerId) async {
    try {
      // Gọi qua endpoint users
      final url = '${ApiConfig.baseUrl}/api/users/$ownerId';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return body['data']['Name'] ?? body['data']['name'];
        }
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi getOwnerName: $e");
      return null;
    }
  }

  // Get Owner Profile
  Future<Map<String, dynamic>?> getOwnerProfile(String ownerId) async {
    try {
      final url = '${ApiConfig.baseUrl}/api/users/$ownerId';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return body['data'];
        }
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi getOwnerProfile: $e");
      return null;
    }
  }

  // 2. Financial Summary
  Future<int> getFinancialSummary(String ownerId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$ownerId/financial-summary'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data']['totalEarnings'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // 3. List Hotels
  Future<List<Hotel>> getHotels(String ownerId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$ownerId/hotels'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List list = body['data'] ?? [];
        return list.map((item) => Hotel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Lỗi getHotels: $e");
      return [];
    }
  }

  Future<Hotel?> createHotel(String ownerId, Hotel hotel) async {
    lastError = null;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/hotels'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          ...hotel.toJson(),
          'userId': ownerId,
          'location': hotel.location,
        }),
      );
      if (response.statusCode == 201) {
        final body = jsonDecode(response.body);
        return Hotel.fromJson(body['data']);
      }
      // Lấy message lỗi cụ thể từ server
      try {
        final errBody = jsonDecode(response.body);
        lastError = errBody['message'] ?? 'HTTP ${response.statusCode}';
      } catch (_) {
        lastError = 'HTTP ${response.statusCode}: ${response.body}';
      }
      debugPrint('Lỗi createHotel: $lastError');
      return null;
    } catch (e) {
      lastError = 'Không kết nối được server: $e';
      debugPrint('Lỗi createHotel: $lastError');
      return null;
    }
  }

  Future<bool> updateHotel(Hotel hotel) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/hotels/${hotel.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          ...hotel.toJson(),
          'location': hotel.location, // Gửi location trực tiếp theo cấu trúc database
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Lỗi updateHotel: $e");
      return false;
    }
  }

  Future<bool> deleteHotel(String hotelId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/hotels/$hotelId'));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Lỗi deleteHotel: $e");
      return false;
    }
  }

  // 4. Room Types for a Hotel
  Future<List<RoomType>> getRoomTypes(String hotelId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/hotels/$hotelId/room-types'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List list = body['data'] ?? [];
        return list.map((item) => RoomType.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<RoomType?> createRoomType(RoomType roomType) async {
    lastError = null;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/room-types'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(roomType.toJson()),
      );
      if (response.statusCode == 201) {
        final body = jsonDecode(response.body);
        return RoomType.fromJson(body['data']);
      }
      try {
        final errBody = jsonDecode(response.body);
        lastError = errBody['message'] ?? 'HTTP ${response.statusCode}';
      } catch (_) {
        lastError = 'HTTP ${response.statusCode}: ${response.body}';
      }
      debugPrint('Lỗi createRoomType: $lastError');
      return null;
    } catch (e) {
      lastError = 'Không kết nối được server: $e';
      debugPrint('Lỗi createRoomType: $lastError');
      return null;
    }
  }

  Future<bool> updateRoomType(RoomType roomType) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/room-types/${roomType.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(roomType.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Lỗi updateRoomType: $e");
      return false;
    }
  }

  Future<bool> deleteRoomType(String roomTypeId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/room-types/$roomTypeId'));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Lỗi deleteRoomType: $e");
      return false;
    }
  }

  // Upload ảnh – endpoint: POST /api/owner/upload
  Future<String?> uploadImage(XFile file) async {
    lastError = null;
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload'),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          await file.readAsBytes(),
          filename: file.name,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        return body['url'] ?? body['imageUrl'] ?? body['data']?['url'];
      }
      try {
        final errBody = jsonDecode(response.body);
        lastError = errBody['message'] ?? 'Upload thất bại (HTTP ${response.statusCode})';
      } catch (_) {
        lastError = 'Upload thất bại (HTTP ${response.statusCode})';
      }
      debugPrint('Lỗi uploadImage: $lastError');
      return null;
    } catch (e) {
      lastError = 'Không kết nối được server để upload ảnh: $e';
      debugPrint('Lỗi uploadImage: $lastError');
      return null;
    }
  }

  // 5. Bookings for a Hotel
  Future<List<Booking>> getBookings(String hotelId, {String? status}) async {
    try {
      String url = '$baseUrl/hotels/$hotelId/bookings';
      if (status != null) url += '?status=$status';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List list = body['data'] ?? [];
        return list.map((item) => Booking.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 6. Statistics (Summary)
  Future<Map<String, dynamic>> getHotelStatistics(String hotelId, {String? startDate, String? endDate}) async {
    try {
      String url = '$baseUrl/hotels/$hotelId/statistics';
      if (startDate != null) {
        url += '?startDate=$startDate';
        if (endDate != null) url += '&endDate=$endDate';
      }
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] ?? {};
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // 7. Reviews
  Future<List<Review>> getReviews(String hotelId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/hotels/$hotelId/reviews'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List list = body['data'] ?? [];
        return list.map((item) => Review.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 8. Review Summary Stats
  Future<Map<String, dynamic>> getReviewSummary(String hotelId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/hotels/$hotelId/reviews/summary'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] ?? {};
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // 9. Update Booking Status
  Future<bool> updateBookingStatus(String bookingId, String status, {String? reason, String? roomNumber}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/bookings/$bookingId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status': status,
          'rejectReason': reason,
          'assignedRoomNumber': roomNumber,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Lỗi updateBookingStatus: $e");
      return false;
    }
  }
}
