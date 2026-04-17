import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/hotel_model.dart';
import '../../data/services/hotel_service.dart';
import '../widgets/filter_sort_bottom_sheet.dart';
import 'hotel_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String city;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int guests;
  final int rooms;

  const SearchResultsScreen({
    super.key,
    required this.city,
    this.checkIn,
    this.checkOut,
    this.guests = 2,
    this.rooms = 1,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  // Danh sách khách sạn
  final List<HotelModel> _hotels = [];

  // Trạng thái tải
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // Phân trang
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  static const int _pageSize = 10;

  // Bộ lọc & sắp xếp hiện tại
  FilterSortResult _filter = const FilterSortResult();

  // Scroll controller để phát hiện cuộn đến cuối
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _currentPage < _totalPages) {
      _loadNextPage();
    }
  }

  // ── Tải trang đầu (hoặc khi đổi bộ lọc) ───────────────────────────────────

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hotels.clear();
      _currentPage = 1;
    });

    await _fetchPage(1);

    if (mounted) setState(() => _isLoading = false);
  }

  // ── Tải thêm trang tiếp theo ───────────────────────────────────────────────

  Future<void> _loadNextPage() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;
    setState(() => _isLoadingMore = true);

    await _fetchPage(_currentPage + 1);

    if (mounted) setState(() => _isLoadingMore = false);
  }

  // ── Gọi API (tìm kiếm hoặc lọc tùy theo trạng thái bộ lọc) ───────────────

  Future<void> _fetchPage(int page) async {
    try {
      SearchResult result;

      if (_filter.hasActiveFilter) {
        // Dùng API filter nâng cao
        result = await HotelService.filterHotels(
          city: widget.city,
          minPrice: _filter.minPrice,
          maxPrice: _filter.maxPrice,
          minStar: _filter.minStar,
          requiredAmenityIcons: _filter.requiredAmenityIcons,
          propertyTypes: _filter.propertyTypes,
          sortBy: _filter.sortBy,
          page: page,
          limit: _pageSize,
        );
      } else {
        // Dùng API tìm kiếm cơ bản
        result = await HotelService.searchHotels(
          city: widget.city,
          guests: widget.guests,
          rooms: widget.rooms,
          page: page,
          limit: _pageSize,
        );
      }

      if (mounted) {
        setState(() {
          _hotels.addAll(result.hotels);
          _totalPages = result.totalPages;
          _totalItems = result.totalItems;
          _currentPage = result.currentPage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại.');
      }
    }
  }

  // ── Mở bộ lọc ─────────────────────────────────────────────────────────────

  Future<void> _openFilter() async {
    final result = await showModalBottomSheet<FilterSortResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSortBottomSheet(initial: _filter),
    );

    if (result != null) {
      setState(() => _filter = result);
      _loadFirstPage();
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)} tr';
    }
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

  String get _datesSubtitle {
    if (widget.checkIn == null || widget.checkOut == null) {
      return '${widget.guests} khách · ${widget.rooms} phòng';
    }
    final nights = widget.checkOut!.difference(widget.checkIn!).inDays;
    return '${widget.checkIn!.day}/${widget.checkIn!.month} - '
        '${widget.checkOut!.day}/${widget.checkOut!.month} · '
        '$nights đêm · ${widget.guests} khách';
  }

  String get _activeSortLabel {
    switch (_filter.sortBy) {
      case 'price_asc': return 'Giá thấp đến cao';
      case 'price_desc': return 'Giá cao đến thấp';
      case 'star_desc': return 'Sao nhiều nhất';
      case 'star_asc': return 'Sao ít nhất';
      default: return AppStrings.locVaSapXep;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(),
          _buildFilterBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ── APP BAR ────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
          child: Row(
            children: [
              // Nút back
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.white),
                onPressed: () => Navigator.pop(context),
              ),
              // Thông tin tìm kiếm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.city,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _datesSubtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Nút tìm kiếm lại
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── FILTER BAR ─────────────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    final hasFilter = _filter.hasActiveFilter;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Nút lọc & sắp xếp
          Expanded(
            child: GestureDetector(
              onTap: _openFilter,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: hasFilter
                      ? AppColors.primaryLight.withValues(alpha: 0.1)
                      : AppColors.background,
                  border: Border.all(
                    color: hasFilter
                        ? AppColors.primaryLight
                        : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tune,
                      size: 16,
                      color: hasFilter
                          ? AppColors.primaryLight
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _activeSortLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color: hasFilter
                              ? AppColors.primaryLight
                              : AppColors.textSecondary,
                          fontWeight: hasFilter
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasFilter) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Số kết quả
          if (!_isLoading)
            Text(
              '$_totalItems ${AppStrings.khachSan}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  // ── BODY ───────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryLight,
          strokeWidth: 2,
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_hotels.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      color: AppColors.primaryLight,
      onRefresh: _loadFirstPage,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: _hotels.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          if (index == _hotels.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: AppColors.primaryLight,
                  strokeWidth: 2,
                ),
              ),
            );
          }
          return _buildHotelCard(_hotels[index]);
        },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 56, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadFirstPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hotel, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            const Text(
              AppStrings.khongTimThayKhachSan,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.thuLayLaiHoacDoiDieuKien,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_filter.hasActiveFilter)
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => _filter = const FilterSortResult());
                  _loadFirstPage();
                },
                icon: const Icon(Icons.filter_alt_off,
                    color: AppColors.primaryLight),
                label: const Text(
                  'Xóa bộ lọc',
                  style: TextStyle(color: AppColors.primaryLight),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryLight),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── HOTEL CARD ─────────────────────────────────────────────────────────────

  Widget _buildHotelCard(HotelModel hotel) {
    double? lowestPrice = hotel.minRoomPrice;
    if (lowestPrice == null && hotel.rooms.isNotEmpty) {
      lowestPrice = hotel.rooms
          .map((r) => r.price)
          .reduce((a, b) => a < b ? a : b);
    }
    final originalPrice =
        lowestPrice != null ? lowestPrice * 1.15 : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HotelDetailScreen(
              hotel: hotel,
              checkIn: widget.checkIn,
              checkOut: widget.checkOut,
              guests: widget.guests,
              rooms: widget.rooms,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ảnh ──────────────────────────────────────────────
            _buildHotelImage(hotel),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Tên + sao + loại ─────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotel.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (hotel.type.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                hotel.type,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStarBadge(hotel.star),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ── Địa chỉ ──────────────────────────────────
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          hotel.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // ── Mô tả ngắn ───────────────────────────────
                  if (hotel.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      hotel.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 8),

                  // ── Tiện nghi ─────────────────────────────────
                  if (hotel.amenities.isNotEmpty)
                    _buildAmenitiesRow(hotel.amenities),

                  const SizedBox(height: 8),

                  // ── Badge không cần thanh toán trước ─────────
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 13, color: Colors.green),
                      const SizedBox(width: 4),
                      const Text(
                        'Không cần thanh toán trước',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 8),

                  // ── Giá ──────────────────────────────────────
                  if (lowestPrice != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Giá cho 1 đêm, 2 người lớn',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            if (originalPrice != null) ...[
                              Text(
                                '${_formatPrice(originalPrice)} VND',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              '${_formatPrice(lowestPrice)} VND',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFCC0000),
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Đã bao gồm thuế và phí',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelImage(HotelModel hotel) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      child: hotel.images.isNotEmpty
          ? Image.network(
              hotel.images.first,
              width: double.infinity,
              height: 180,
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
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        color: Color(0xFFE8EEF7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: const Icon(Icons.hotel, size: 48, color: AppColors.primaryLight),
    );
  }

  Widget _buildStarBadge(int star) {
    if (star <= 0) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 12, color: AppColors.accent),
          const SizedBox(width: 2),
          Text(
            '$star',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B6914),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesRow(List<AmenityModel> amenities) {
    // Map cả icon cũ (wifi) lẫn icon mới từ Firebase (fa-wifi)
    final iconMap = <String, IconData>{
      'wifi': Icons.wifi,
      'fa-wifi': Icons.wifi,
      'pool': Icons.pool,
      'fa-swimming-pool': Icons.pool,
      'parking': Icons.local_parking,
      'fa-parking': Icons.local_parking,
      'gym': Icons.fitness_center,
      'fa-dumbbell': Icons.fitness_center,
      'restaurant': Icons.restaurant,
      'fa-utensils': Icons.restaurant,
      'spa': Icons.spa,
      'fa-spa': Icons.spa,
      'ac': Icons.ac_unit,
      'fa-snowflake': Icons.ac_unit,
      'breakfast': Icons.free_breakfast,
      'fa-bread-slice': Icons.free_breakfast,
      'fa-glass-martini-alt': Icons.local_bar,
      'elevator': Icons.elevator,
      'fa-elevator': Icons.elevator,
    };

    final toShow = amenities.take(4).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: toShow.map((a) {
        final iconData = iconMap[a.icon] ?? Icons.check_circle_outline;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, size: 13, color: AppColors.primaryLight),
            const SizedBox(width: 3),
            Text(
              a.name,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        );
      }).toList(),
    );
  }
}
