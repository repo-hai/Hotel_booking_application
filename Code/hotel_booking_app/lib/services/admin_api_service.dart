import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/booking_model.dart';
import '../models/hotel_model.dart';
import '../models/user_model.dart';
import '../models/voucher_model.dart';
import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class AdminApiService {
  static String get _base => ApiConfig.baseUrl;
  static const Duration _timeout = Duration(seconds: 15);

  static Future<Map<String, dynamic>> _getJson(String path) async {
    final uri = Uri.parse('$_base$path');
    try {
      final res = await http.get(uri).timeout(_timeout);
      final body = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      if (res.statusCode >= 200 && res.statusCode < 300) return body;
      throw ApiException(
        body['message']?.toString() ?? 'Lỗi server',
        statusCode: res.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể kết nối tới server: $e');
    }
  }

  static Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_base$path');
    try {
      final headers = {'Content-Type': 'application/json; charset=utf-8'};
      final payload = body == null ? null : json.encode(body);
      http.Response res;
      switch (method) {
        case 'POST':
          res = await http.post(uri, headers: headers, body: payload).timeout(_timeout);
          break;
        case 'PUT':
          res = await http.put(uri, headers: headers, body: payload).timeout(_timeout);
          break;
        case 'PATCH':
          res = await http.patch(uri, headers: headers, body: payload).timeout(_timeout);
          break;
        case 'DELETE':
          res = await http.delete(uri, headers: headers).timeout(_timeout);
          break;
        default:
          throw ApiException('Method không hỗ trợ: $method');
      }
      final decoded = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      if (res.statusCode >= 200 && res.statusCode < 300) return decoded;
      throw ApiException(
        decoded['message']?.toString() ?? 'Lỗi server',
        statusCode: res.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Không thể kết nối tới server: $e');
    }
  }

  // ============ Dashboard ============
  static Future<DashboardStats> fetchDashboardStats() async {
    final res = await _getJson('/api/admin/dashboard/stats');
    final d = res['data'] as Map<String, dynamic>;
    return DashboardStats(
      totalUsers: (d['totalUsers'] as num? ?? 0).toInt(),
      totalHotels: (d['totalHotels'] as num? ?? 0).toInt(),
      totalBookings: (d['totalBookings'] as num? ?? 0).toInt(),
      totalVouchers: (d['totalVouchers'] as num? ?? 0).toInt(),
    );
  }

  static Future<List<RecentBooking>> fetchRecentBookings() async {
    final res = await _getJson('/api/admin/dashboard/recent-bookings');
    final list = (res['data'] as List).cast<Map<String, dynamic>>();
    return list.map(RecentBooking.fromJson).toList();
  }

  // ============ Users ============
  static Future<UsersPage> fetchUsers({
    String? type,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (type != null && type.isNotEmpty) 'type': type,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final qs = params.entries
        .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    final res = await _getJson('/api/admin/users?$qs');
    final data = res['data'] as Map<String, dynamic>;
    final users = (data['users'] as List)
        .cast<Map<String, dynamic>>()
        .map(UserModel.fromJson)
        .toList();
    return UsersPage(
      users: users,
      total: (data['total'] as num? ?? 0).toInt(),
      page: (data['page'] as num? ?? 1).toInt(),
      limit: (data['limit'] as num? ?? limit).toInt(),
    );
  }

  static Future<UserModel> fetchUserDetail(String id) async {
    final res = await _getJson('/api/admin/users/$id');
    return UserModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  static Future<void> deleteUser(String id) async {
    await _send('DELETE', '/api/admin/users/$id');
  }

  // ============ Hotels (via /api/hotels) ============
  static Future<HotelsPage> fetchHotels({int page = 1, int limit = 10}) async {
    final res = await _getJson('/api/hotels?page=$page&limit=$limit');
    final list = (res['data'] as List).cast<Map<String, dynamic>>();
    final pagination = res['pagination'] as Map<String, dynamic>? ?? {};
    return HotelsPage(
      hotels: list.map(HotelModel.fromJson).toList(),
      currentPage: (pagination['currentPage'] as num? ?? page).toInt(),
      totalPages: (pagination['totalPages'] as num? ?? 1).toInt(),
      totalItems: (pagination['totalItems'] as num? ?? list.length).toInt(),
    );
  }

  static Future<HotelModel> fetchHotelDetail(String id) async {
    final res = await _getJson('/api/hotels/$id');
    return HotelModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  // ============ Bookings ============
  static Future<BookingsPage> fetchBookings({
    String? status,
    String? search,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
    };
    final qs = params.entries
        .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    final res = await _getJson('/api/admin/bookings?$qs');
    final data = res['data'] as Map<String, dynamic>;
    final bookings = (data['bookings'] as List)
        .cast<Map<String, dynamic>>()
        .map(BookingModel.fromJson)
        .toList();
    return BookingsPage(
      bookings: bookings,
      total: (data['total'] as num? ?? 0).toInt(),
      page: (data['page'] as num? ?? 1).toInt(),
      limit: (data['limit'] as num? ?? limit).toInt(),
    );
  }

  // ============ Vouchers ============
  static Future<VouchersPage> fetchVouchers({
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final qs = params.entries
        .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    final res = await _getJson('/api/admin/vouchers?$qs');
    final data = res['data'] as Map<String, dynamic>;
    final vouchers = (data['vouchers'] as List)
        .cast<Map<String, dynamic>>()
        .map(VoucherModel.fromJson)
        .toList();
    return VouchersPage(
      vouchers: vouchers,
      total: (data['total'] as num? ?? 0).toInt(),
      page: (data['page'] as num? ?? 1).toInt(),
      limit: (data['limit'] as num? ?? limit).toInt(),
    );
  }

  static Future<VoucherModel> fetchVoucherDetail(String id) async {
    final res = await _getJson('/api/admin/vouchers/$id');
    return VoucherModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  static Future<String> createVoucher(Map<String, dynamic> body) async {
    final res = await _send('POST', '/api/admin/vouchers', body: body);
    final data = res['data'] as Map<String, dynamic>?;
    return (data?['id'] ?? '') as String;
  }

  static Future<void> updateVoucher(String id, Map<String, dynamic> body) async {
    await _send('PUT', '/api/admin/vouchers/$id', body: body);
  }

  static Future<void> deleteVoucher(String id) async {
    await _send('DELETE', '/api/admin/vouchers/$id');
  }
}

class DashboardStats {
  final int totalUsers;
  final int totalHotels;
  final int totalBookings;
  final int totalVouchers;
  DashboardStats({
    required this.totalUsers,
    required this.totalHotels,
    required this.totalBookings,
    required this.totalVouchers,
  });
}

class RecentBooking {
  final String id;
  final String hotelName;
  final String guestName;
  final String date;
  final String status;
  RecentBooking({
    required this.id,
    required this.hotelName,
    required this.guestName,
    required this.date,
    required this.status,
  });
  factory RecentBooking.fromJson(Map<String, dynamic> j) => RecentBooking(
        id: (j['id'] ?? '').toString(),
        hotelName: (j['hotelName'] ?? '') as String,
        guestName: (j['guestName'] ?? '') as String,
        date: (j['date'] ?? '') as String,
        status: (j['status'] ?? 'pending') as String,
      );
}

class UsersPage {
  final List<UserModel> users;
  final int total;
  final int page;
  final int limit;
  UsersPage({required this.users, required this.total, required this.page, required this.limit});
}

class HotelsPage {
  final List<HotelModel> hotels;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  HotelsPage({
    required this.hotels,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });
}

class BookingsPage {
  final List<BookingModel> bookings;
  final int total;
  final int page;
  final int limit;
  BookingsPage({required this.bookings, required this.total, required this.page, required this.limit});
}

class VouchersPage {
  final List<VoucherModel> vouchers;
  final int total;
  final int page;
  final int limit;
  VouchersPage({required this.vouchers, required this.total, required this.page, required this.limit});
}
