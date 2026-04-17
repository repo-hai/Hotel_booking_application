import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/hotel_model.dart';
import '../models/search_history_model.dart';
import '../models/review_model.dart';
import '../models/voucher_model.dart';

class SearchResult {
  final List<HotelModel> hotels;
  final int totalItems;
  final int totalPages;
  final int currentPage;

  SearchResult({
    required this.hotels,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });
}

class HotelService {
  // Tìm kiếm khách sạn theo thành phố + số khách + số phòng
  static Future<SearchResult> searchHotels({
    required String city,
    required int guests,
    required int rooms,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.hotelsSearch}'
        '?city=${Uri.encodeComponent(city)}&guests=$guests&rooms=$rooms&page=$page&limit=$limit',
      );
      // ignore: avoid_print
      print('searchHotels URL: $uri');
      final response = await http.get(uri);
      // ignore: avoid_print
      print('searchHotels status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List list = body['data'] ?? [];
        // ignore: avoid_print
        print('searchHotels data count: ${list.length}');
        final pagination = body['pagination'] ?? {};
        return SearchResult(
          hotels: list.map((e) {
            try {
              return HotelModel.fromJson(e);
            } catch (parseErr) {
              // ignore: avoid_print
              print('Parse error for hotel: $parseErr');
              return null;
            }
          }).whereType<HotelModel>().toList(),
          totalItems: pagination['totalItems'] ?? list.length,
          totalPages: pagination['totalPages'] ?? 1,
          currentPage: pagination['currentPage'] ?? page,
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error searchHotels: $e');
    }
    return SearchResult(hotels: [], totalItems: 0, totalPages: 0, currentPage: 1);
  }

  // Lọc + sắp xếp nâng cao
  static Future<SearchResult> filterHotels({
    String? city,
    double? minPrice,
    double? maxPrice,
    int? minStar,
    List<String>? requiredAmenityIcons, // icon FB: fa-wifi, fa-spa...
    List<String>? propertyTypes,        // loại: Khách sạn, Resort, Villa...
    String? sortBy,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.hotelsFilter}?page=$page&limit=$limit',
      );
      final body = <String, dynamic>{};
      if (city != null) body['city'] = city;
      if (minPrice != null) body['minPrice'] = minPrice;
      if (maxPrice != null) body['maxPrice'] = maxPrice;
      if (minStar != null) body['minStar'] = minStar;
      if (requiredAmenityIcons != null && requiredAmenityIcons.isNotEmpty) {
        body['requiredAmenityIcons'] = requiredAmenityIcons;
      }
      if (propertyTypes != null && propertyTypes.isNotEmpty) {
        body['propertyTypes'] = propertyTypes;
      }
      if (sortBy != null) body['sortBy'] = sortBy;

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List list = responseBody['data'] ?? [];
        final pagination = responseBody['pagination'] ?? {};
        return SearchResult(
          hotels: list.map((e) => HotelModel.fromJson(e)).toList(),
          totalItems: pagination['totalItems'] ?? list.length,
          totalPages: pagination['totalPages'] ?? 1,
          currentPage: pagination['currentPage'] ?? page,
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error filterHotels: $e');
    }
    return SearchResult(hotels: [], totalItems: 0, totalPages: 0, currentPage: 1);
  }

  // Lấy gợi ý khách sạn cho user
  static Future<List<HotelModel>> getUserSuggestions(String userId) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.userSuggestions(userId)}?limit=10',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['data'] ?? [];
        return list.map((e) => HotelModel.fromJson(e)).toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error getUserSuggestions: $e');
    }
    return [];
  }

  // Lấy lịch sử tìm kiếm của user
  static Future<List<SearchHistoryModel>> getSearchHistory(
    String userId, {
    int limit = 3,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.userSearchHistory(userId)}?limit=$limit',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['data'] ?? [];
        return list.map((e) => SearchHistoryModel.fromJson(e)).toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error getSearchHistory: $e');
    }
    return [];
  }

  // Lưu lịch sử tìm kiếm
  static Future<void> saveSearchHistory(
    String userId,
    SearchHistoryModel item,
  ) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.userSearchHistory(userId)}',
      );
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error saveSearchHistory: $e');
    }
  }

  // Lấy chi tiết 1 khách sạn
  static Future<HotelModel?> getHotelDetail(String hotelId) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.hotelDetail(hotelId)}',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return HotelModel.fromJson(body['data']);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error getHotelDetail: $e');
    }
    return null;
  }

  // Lấy reviews của 1 khách sạn
  static Future<HotelReviewSummary> getHotelReviews(String hotelId, {int limit = 10}) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.hotelReviews(hotelId)}?limit=$limit',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        final reviewsList = (data['reviews'] as List<dynamic>? ?? [])
            .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList();
        final rawBreakdown = data['breakdown'] as Map<String, dynamic>? ?? {};
        final breakdown = <int, int>{};
        rawBreakdown.forEach((k, v) {
          breakdown[int.tryParse(k) ?? 0] = (v as num).toInt();
        });
        return HotelReviewSummary(
          reviews: reviewsList,
          totalReviews: (data['totalReviews'] as num?)?.toInt() ?? 0,
          averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0,
          breakdown: breakdown,
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error getHotelReviews: $e');
    }
    return HotelReviewSummary.empty();
  }

  // Lấy vouchers khả dụng cho user
  static Future<List<VoucherModel>> getAvailableVouchers({double? orderTotal}) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.vouchersAvailable(orderTotal: orderTotal)}',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List list = body['data'] ?? [];
        return list.map((e) => VoucherModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error getAvailableVouchers: $e');
    }
    return [];
  }
}
