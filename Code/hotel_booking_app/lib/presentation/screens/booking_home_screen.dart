import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/hotel_model.dart';
import '../../data/models/search_history_model.dart';
import '../../data/services/hotel_service.dart';
import '../widgets/date_picker_bottom_sheet.dart';
import '../widgets/guest_picker_bottom_sheet.dart';
import 'location_picker_screen.dart';
import 'search_results_screen.dart';
import 'booking_history_screen.dart';
import 'hotel_detail_screen.dart';
import '../screens/client/chatbot_screen.dart';
import 'account_screen.dart';
import 'profile_view.dart';

class BookingHomeScreen extends StatefulWidget {
  const BookingHomeScreen({super.key});

  @override
  State<BookingHomeScreen> createState() => _BookingHomeScreenState();
}

class _BookingHomeScreenState extends State<BookingHomeScreen> {
  // Dữ liệu tìm kiếm
  String _selectedDestination = '';
  DateTime? _checkIn;
  DateTime? _checkOut;
  GuestSelection _guests = const GuestSelection();

  // Dữ liệu từ API
  List<SearchHistoryModel> _searchHistory = [];
  List<HotelModel> _suggestions = [];
  bool _isLoadingHistory = false;
  bool _isLoadingSuggestions = false;

  // User ID — lấy từ SharedPreferences sau khi đăng nhập
  String _userId = '';

  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _initUserId();
  }

  Future<void> _initUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId') ?? '';
    if (mounted) {
      setState(() => _userId = id);
      _loadData();
    }
  }

  Future<void> _loadData() async {
    _loadSearchHistory();
    _loadSuggestions();
  }

  Future<void> _loadSearchHistory() async {
    setState(() => _isLoadingHistory = true);
    final history = await HotelService.getSearchHistory(_userId, limit: 5);
    if (mounted) {
      setState(() {
        _searchHistory = history;
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _loadSuggestions() async {
    setState(() => _isLoadingSuggestions = true);
    final suggestions = await HotelService.getUserSuggestions(_userId);
    if (mounted) {
      setState(() {
        _suggestions = suggestions;
        _isLoadingSuggestions = false;
      });
    }
  }

  // Mở màn hình chọn vị trí
  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          searchHistory: _searchHistory,
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _selectedDestination = result;
      });
    }
  }

  // Mở bottom sheet chọn ngày
  Future<void> _openDatePicker() async {
    final result = await showModalBottomSheet<DateRangeResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DatePickerBottomSheet(
        initialCheckIn: _checkIn,
        initialCheckOut: _checkOut,
      ),
    );

    if (result != null) {
      setState(() {
        _checkIn = result.checkIn;
        _checkOut = result.checkOut;
      });
    }
  }

  // Mở bottom sheet chọn phòng & khách
  Future<void> _openGuestPicker() async {
    final result = await showModalBottomSheet<GuestSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GuestPickerBottomSheet(initial: _guests),
    );

    if (result != null) {
      setState(() => _guests = result);
    }
  }

  // Format ngày hiển thị
  String get _datesDisplay {
    if (_checkIn == null || _checkOut == null) {
      return 'Chọn ngày nhận - trả phòng';
    }
    final weekDays = ['T.2', 'T.3', 'T.4', 'T.5', 'T.6', 'T.7', 'CN'];
    final inDay = weekDays[_checkIn!.weekday - 1];
    final outDay = weekDays[_checkOut!.weekday - 1];
    return '$inDay, ${_checkIn!.day} Th${_checkIn!.month} - $outDay, ${_checkOut!.day} Th${_checkOut!.month}';
  }

  // Format khách hiển thị
  String get _guestsDisplay {
    final parts = <String>['${_guests.rooms} phòng'];
    parts.add('${_guests.adults} người lớn');
    if (_guests.children > 0) parts.add('${_guests.children} trẻ nhỏ');
    return parts.join(' - ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header xanh ─────────────────────────────────────────
          _buildHeader(),

          // ── Nội dung cuộn ───────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search form
                  _buildSearchForm(),

                  const SizedBox(height: 16),

                  // Lịch sử tìm kiếm
                  _buildSearchHistorySection(),

                  const SizedBox(height: 16),

                  // Gợi ý cho bạn
                  _buildSuggestionsSection(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Navigation ────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            children: [
              // Logo
              const Expanded(
                child: Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Chat icon
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline,
                    color: AppColors.white),
                onPressed: () {},
              ),
              // Notification icon với badge
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: AppColors.white),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── SEARCH FORM ─────────────────────────────────────────────────────────────

  Widget _buildSearchForm() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderFocus, width: 2),
        ),
        child: Column(
          children: [
            // Tab "Lưu trú"
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.bed_outlined,
                            size: 16, color: AppColors.textPrimary),
                        SizedBox(width: 6),
                        Text(
                          AppStrings.luuTru,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.divider),

            // Ô chọn điểm đến
            _buildSearchField(
              icon: Icons.search,
              text: _selectedDestination.isEmpty
                  ? AppStrings.chonDiemDen
                  : _selectedDestination,
              isPlaceholder: _selectedDestination.isEmpty,
              onTap: _openLocationPicker,
            ),

            const Divider(height: 1, color: AppColors.divider),

            // Ô chọn ngày
            _buildSearchField(
              icon: Icons.calendar_today_outlined,
              text: _datesDisplay,
              isPlaceholder: _checkIn == null,
              onTap: _openDatePicker,
            ),

            const Divider(height: 1, color: AppColors.divider),

            // Ô số phòng/người
            _buildSearchField(
              icon: Icons.person_outline,
              text: _guestsDisplay,
              onTap: _openGuestPicker,
            ),

            const Divider(height: 1, color: AppColors.divider),

            // Nút Tìm
            _buildSearchButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField({
    required IconData icon,
    required String text,
    bool isPlaceholder = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: isPlaceholder
                    ? AppColors.textHint
                    : AppColors.textPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: isPlaceholder
                      ? AppColors.textHint
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            if (_selectedDestination.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vui lòng chọn điểm đến'),
                  backgroundColor: AppColors.primaryLight,
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }

            // Lưu lịch sử tìm kiếm (await để đảm bảo lưu xong)
            await HotelService.saveSearchHistory(
              _userId,
              SearchHistoryModel(
                city: _selectedDestination,
                checkIn: _checkIn?.toIso8601String(),
                checkOut: _checkOut?.toIso8601String(),
                guests: _guests.adults + _guests.children,
                rooms: _guests.rooms,
              ),
            );

            if (!mounted) return;

            // Điều hướng sang màn hình kết quả, reload lịch sử khi quay lại
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SearchResultsScreen(
                  city: _selectedDestination,
                  checkIn: _checkIn,
                  checkOut: _checkOut,
                  guests: _guests.adults + _guests.children,
                  rooms: _guests.rooms,
                ),
              ),
            );

            // Reload lịch sử tìm kiếm sau khi quay lại
            if (mounted) _loadSearchHistory();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            elevation: 0,
          ),
          child: const Text(
            AppStrings.tim,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // ── SEARCH HISTORY ──────────────────────────────────────────────────────────

  Widget _buildSearchHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Text(
            AppStrings.lichSuTimKiem,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (_isLoadingHistory)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: AppColors.primaryLight,
                strokeWidth: 2,
              ),
            ),
          )
        else if (_searchHistory.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Chưa có lịch sử tìm kiếm',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          )
        else
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _searchHistory.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) =>
                  _buildHistoryCard(_searchHistory[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildHistoryCard(SearchHistoryModel item) {
    return InkWell(
      onTap: () {
        // Nhảy sang trang kết quả tìm kiếm với thông tin từ lịch sử
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SearchResultsScreen(
              city: item.city,
              checkIn: item.checkIn != null
                  ? DateTime.tryParse(item.checkIn!)
                  : null,
              checkOut: item.checkOut != null
                  ? DateTime.tryParse(item.checkOut!)
                  : null,
              guests: item.guests,
              rooms: item.rooms,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 44,
                height: 44,
                color: AppColors.primaryLight.withValues(alpha: 0.15),
                child: const Icon(Icons.location_city,
                    color: AppColors.primaryLight, size: 24),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${item.city} (${item.city})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SUGGESTIONS ─────────────────────────────────────────────────────────────

  Widget _buildSuggestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Text(
            AppStrings.goiYChoBan,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (_isLoadingSuggestions)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: AppColors.primaryLight,
                strokeWidth: 2,
              ),
            ),
          )
        else if (_suggestions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Chưa có gợi ý',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) =>
                _buildSuggestionCard(_suggestions[index]),
          ),
      ],
    );
  }

  Widget _buildSuggestionCard(HotelModel hotel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HotelDetailScreen(hotel: hotel),
          ),
        );
      },
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ảnh khách sạn
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child: hotel.images.isNotEmpty
                ? Image.network(
                    hotel.images.first,
                    width: 100,
                    height: 90,
                    fit: BoxFit.cover,
                    headers: const {
                      'User-Agent':
                          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                    },
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return _buildImagePlaceholder();
                    },
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
          // Thông tin
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Text(
                        hotel.city,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (hotel.rating != null)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            hotel.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '/10',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  if (hotel.minRoomPrice != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${_formatPrice(hotel.minRoomPrice!)} VND',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ), // end Container
    ); // end GestureDetector
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 100,
      height: 90,
      color: AppColors.primaryLight.withValues(alpha: 0.15),
      child: const Icon(Icons.hotel, color: AppColors.primaryLight, size: 32),
    );
  }

  // ── BOTTOM NAV ──────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentNavIndex,
      onTap: (index) {
        if (index == 1) {
          // Tab "Chatbot" → mở màn hình chatbot
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatbotScreen()),
          );
          return;
        }
        if (index == 2) {
          // Tab "Đặt chỗ" → mở lịch sử đặt phòng
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookingHistoryScreen()),
          );
          return;
        }
        if (index == 3) {
          // Tab "Tài khoản" → mở màn hình tài khoản
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileView()),
          );
          return;
        }
        setState(() => _currentNavIndex = index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.textSecondary,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: AppStrings.timKiem,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.smart_toy_outlined),
          label: 'Chatbot',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.luggage_outlined),
          label: AppStrings.datCho,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: AppStrings.taiKhoan,
        ),
      ],
    );
  }

  // ── HELPERS ─────────────────────────────────────────────────────────────────

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = formatted.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(formatted[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }
}
