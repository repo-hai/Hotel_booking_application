import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/owner_api_service.dart';
import '../models/hotel/hotel_model.dart';
import '../models/room/room_type_model.dart';
import '../models/room/room_model.dart';
import '../models/booking/booking_model.dart';
import '../models/review/review_model.dart';

class OwnerProvider with ChangeNotifier {
  final OwnerApiService _apiService = OwnerApiService();
  final String ownerId = "owner_demo_01"; // Default demo owner ID

  // Dashboard Stats
  Map<String, dynamic> _dashboardStats = {};
  Map<String, dynamic> get dashboardStats => _dashboardStats;

  // List of Hotels
  List<Hotel> _hotels = [];
  List<Hotel> get hotels => _hotels;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Current Hotel Details (For detail screens)
  Map<String, dynamic> _hotelStats = {};
  Map<String, dynamic> get hotelStats => _hotelStats;

  List<RoomType> _roomTypes = [];
  List<RoomType> get roomTypes => _roomTypes;

  List<Booking> _bookings = [];
  List<Booking> get bookings => _bookings;

  List<Review> _reviews = [];
  List<Review> get reviews => _reviews;

  Map<String, dynamic> _reviewSummary = {};
  Map<String, dynamic> get reviewSummary => _reviewSummary;

  // Draft items for Add/Edit wizard
  Hotel? draftHotel;
  RoomType? draftRoomType;

  // --- Actions ---

  Future<void> refreshDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      final stats = await _apiService.getDashboardStats(ownerId);
      final list = await _apiService.getHotels(ownerId);
      
      _dashboardStats = stats;
      _hotels = list;
    } catch (e) {
      debugPrint("Lỗi refreshDashboard: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHotelDetails(String hotelId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final stats = await _apiService.getHotelStatistics(hotelId);
      final rTypes = await _apiService.getRoomTypes(hotelId);
      
      _hotelStats = stats;
      _roomTypes = rTypes;
    } catch (e) {
      debugPrint("Lỗi fetchHotelDetails: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBookings(String hotelId, {String? status}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookings = await _apiService.getBookings(hotelId, status: status);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchReviews(String hotelId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _reviews = await _apiService.getReviews(hotelId);
      _reviewSummary = await _apiService.getReviewSummary(hotelId);
      return _reviewSummary;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchHotelStatistics(String hotelId, {String? startDate, String? endDate}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final stats = await _apiService.getHotelStatistics(hotelId, startDate: startDate, endDate: endDate);
      return stats;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật giá hạng phòng trong local state để đồng bộ UI
  void updateRoomTypePrice(String roomTypeId, int newPrice) {
    final index = _roomTypes.indexWhere((rt) => rt.id == roomTypeId);
    if (index != -1) {
      _roomTypes[index] = _roomTypes[index].copyWith(price: newPrice);
      notifyListeners();
      // Optionally call specific patch API for price here if needed
    }
  }

  // Thêm hạng phòng mới
  Future<bool> createRoomType(RoomType newRoom) async {
    _isLoading = true;
    notifyListeners();
    final result = await _apiService.createRoomType(newRoom);
    if (result != null) {
      _roomTypes.add(result);
      _isLoading = false;
      notifyListeners();
      return true;
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Cập nhật trạng thái của một phòng vật lý cụ thể
  Future<bool> updateRoomStatus(String roomTypeId, String roomId, String newStatus) async {
    final rtIndex = _roomTypes.indexWhere((rt) => rt.id == roomTypeId);
    if (rtIndex != -1) {
      final roomIndex = _roomTypes[rtIndex].rooms.indexWhere((r) => r.id == roomId);
      if (roomIndex != -1) {
        // Tạo bản sao mới của danh sách phòng với trạng thái đã đổi
        List<Room> updatedRooms = List.from(_roomTypes[rtIndex].rooms);
        updatedRooms[roomIndex] = Room(
          id: updatedRooms[roomIndex].id,
          roomNumber: updatedRooms[roomIndex].roomNumber,
          status: newStatus,
        );

        final updatedRoomType = _roomTypes[rtIndex].copyWith(rooms: updatedRooms);
        
        // Cập nhật local state trước để UI phản hồi nhanh
        _roomTypes[rtIndex] = updatedRoomType;
        notifyListeners();

        // Gửi cập nhật lên Server
        final success = await _apiService.updateRoomType(updatedRoomType);
        if (!success) {
          // Nếu lỗi thì hoàn tác (rollback) lại dữ liệu cũ - Ở bản demo này tạm thời bỏ qua rollback phức tạp
          debugPrint("Lỗi cập nhật trạng thái phòng lên Server");
        }
        return success;
      }
    }
    return false;
  }

  // Cập nhật toàn bộ thông tin hạng phòng
  Future<bool> updateRoomType(RoomType updatedRoom) async {
    _isLoading = true;
    notifyListeners();
    final success = await _apiService.updateRoomType(updatedRoom);
    if (success) {
      final index = _roomTypes.indexWhere((rt) => rt.id == updatedRoom.id);
      if (index != -1) {
        _roomTypes[index] = updatedRoom;
      }
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }

  // Xóa hạng phòng khỏi local state và backend
  Future<bool> deleteRoomType(String roomTypeId) async {
    _isLoading = true;
    notifyListeners();
    final success = await _apiService.deleteRoomType(roomTypeId);
    if (success) {
      _roomTypes.removeWhere((rt) => rt.id == roomTypeId);
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }

  // Cập nhật trạng thái đơn đặt phòng & Tự động gán phòng
  Future<String?> updateBookingStatus(String bookingId, String status, {String? reason}) async {
    try {
      String? assignedRoom;

      // Nếu là Xác nhận, thực hiện logic tự động gán phòng
      if (status == "Confirmed") {
        final booking = _bookings.firstWhere((b) => b.id == bookingId);
        if (booking.bookedRooms.isNotEmpty) {
          final roomTypeId = booking.bookedRooms[0].id.toString(); // Lấy ID hạng phòng đã đặt
          
          // Tìm trong RoomType xem có phòng nào Available không
          final rtIndex = _roomTypes.indexWhere((rt) => rt.id.toString() == roomTypeId);
          if (rtIndex != -1) {
            final availableRoom = _roomTypes[rtIndex].rooms.firstWhere(
              (r) => r.status == "Available",
              orElse: () => Room(id: "", roomNumber: "NONE", status: "")
            );

            if (availableRoom.roomNumber == "NONE") {
              return "Hết phòng vật lý khả dụng cho hạng phòng này!";
            }
            assignedRoom = availableRoom.roomNumber;
          }
        }
      }

      final success = await _apiService.updateBookingStatus(
        bookingId, 
        status, 
        reason: reason, 
        roomNumber: assignedRoom
      );

      if (success) {
        // Cập nhật local state
        final index = _bookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          _bookings[index] = Booking(
            id: _bookings[index].id,
            checkin: _bookings[index].checkin,
            checkout: _bookings[index].checkout,
            total: _bookings[index].total,
            bookedAt: _bookings[index].bookedAt,
            status: status,
            cancellationReason: reason,
            assignedRoomNumber: assignedRoom,
            customerInfo: _bookings[index].customerInfo,
            bookedRooms: _bookings[index].bookedRooms,
            payment: _bookings[index].payment,
          );
          
          // Tự động xóa khỏi danh sách hiện tại để UI lọc lại (vì Tab hiển thị theo Status)
          _bookings.removeAt(index);
          notifyListeners();
        }
        return null; // Thành công
      }
      return "Không thể cập nhật trạng thái lên Server.";
    } catch (e) {
      debugPrint("Lỗi updateBookingStatus: $e");
      return "Lỗi hệ thống: $e";
    }
  }

  // Upload image proxy
  Future<String?> uploadImage(XFile file) async {
    return await _apiService.uploadImage(file);
  }

  // --- Hotel Methods ---

  Future<bool> createHotel() async {
    if (draftHotel == null) return false;
    _isLoading = true;
    notifyListeners();
    final result = await _apiService.createHotel(ownerId, draftHotel!);
    if (result != null) {
      _hotels.add(result);
      _isLoading = false;
      notifyListeners();
      return true;
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateHotel(Hotel updatedHotel) async {
    _isLoading = true;
    notifyListeners();
    final success = await _apiService.updateHotel(updatedHotel);
    if (success) {
      final index = _hotels.indexWhere((h) => h.id == updatedHotel.id);
      if (index != -1) {
        _hotels[index] = updatedHotel;
      }
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> deleteHotel(String hotelId) async {
    _isLoading = true;
    notifyListeners();
    final success = await _apiService.deleteHotel(hotelId);
    if (success) {
      _hotels.removeWhere((h) => h.id == hotelId);
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }
}
