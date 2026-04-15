class ApiConstants {
  // Web (Chrome/Edge): dùng localhost
  // Android Emulator: dùng 10.0.2.2
  // Thiết bị thật: dùng IP máy tính, ví dụ 192.168.1.5
  static const String baseUrl = 'http://localhost:3000';

  // Hotels
  static const String hotels = '/api/hotels';
  static const String hotelsSearch = '/api/hotels/search';
  static const String hotelsFilter = '/api/hotels/filter';
  static String hotelDetail(String id) => '/api/hotels/$id';

  // Bookings
  static const String bookings = '/api/bookings';

  // Users
  static String userSearchHistory(String userId) => '/api/users/$userId/search-history';
  static String userSuggestions(String userId) => '/api/users/$userId/suggestions';

  // Admin
  static const String adminStats = '/api/admin/dashboard/stats';
  static const String adminRecentBookings = '/api/admin/dashboard/recent-bookings';
}
