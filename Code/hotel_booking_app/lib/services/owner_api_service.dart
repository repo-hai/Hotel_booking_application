import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/hotel/hotel_model.dart';
import '../models/room/room_type_model.dart';
import '../models/booking/booking_model.dart';
import '../models/review/review_model.dart';

class OwnerApiService {
  static const String baseUrl = 'http://localhost:3000/api/owner';

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
    try {
      // Bóc tách city từ location (thường là phần cuối cùng sau dấu phẩy)
      List<String> parts = hotel.location.split(', ');
      String city = parts.length > 1 ? parts.last : hotel.location;
      String address = parts.length > 1 ? parts.sublist(0, parts.length - 1).join(', ') : hotel.location;

      final response = await http.post(
        Uri.parse('$baseUrl/hotels'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          ...hotel.toJson(),
          'userId': ownerId, // Backend yêu cầu userId thay vì ownerId
          'address': address,
          'city': city,
        }),
      );
      if (response.statusCode == 201) {
        final body = jsonDecode(response.body);
        return Hotel.fromJson(body['data']);
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi createHotel: $e");
      return null;
    }
  }

  Future<bool> updateHotel(Hotel hotel) async {
    try {
      List<String> parts = hotel.location.split(', ');
      String city = parts.length > 1 ? parts.last : hotel.location;
      String address = parts.length > 1 ? parts.sublist(0, parts.length - 1).join(', ') : hotel.location;

      final response = await http.put(
        Uri.parse('$baseUrl/hotels/${hotel.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          ...hotel.toJson(),
          'address': address,
          'city': city,
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
      return null;
    } catch (e) {
      debugPrint("Lỗi createRoomType: $e");
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

  // Upload ảnh
  Future<String?> uploadImage(XFile file) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
      request.files.add(http.MultipartFile.fromBytes('image', await file.readAsBytes(), filename: file.name));
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['url'];
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi uploadImage: $e");
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
