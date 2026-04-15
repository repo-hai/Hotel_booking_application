import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/search_history_model.dart';
import '../../data/services/hotel_service.dart';

class LocationPickerScreen extends StatefulWidget {
  final List<SearchHistoryModel> searchHistory;

  const LocationPickerScreen({
    super.key,
    required this.searchHistory,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Danh sách thành phố gợi ý khi gõ
  final List<String> _allCities = [
    'Hà Nội',
    'Hồ Chí Minh',
    'Đà Nẵng',
    'Nha Trang',
    'Đà Lạt',
    'Phú Quốc',
    'Vũng Tàu',
    'Hội An',
    'Huế',
    'Hạ Long',
    'Sapa',
    'Mũi Né',
    'Cần Thơ',
    'Lạng Sơn',
    'Hải Phòng',
    'Ninh Bình',
    'Quy Nhơn',
    'Phan Thiết',
  ];

  List<String> _filteredCities = [];
  bool _isSearching = false;
  bool _showAllHistory = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _filteredCities = _allCities
            .where(
              (city) => city.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      } else {
        _filteredCities = [];
      }
    });
  }

  void _selectCity(String city) {
    // Trả về tên thành phố đã chọn cho màn hình trước
    Navigator.pop(context, city);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyToShow = _showAllHistory
        ? widget.searchHistory
        : widget.searchHistory.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search Bar ──────────────────────────────────────────
            _buildSearchBar(),

            // ── Nội dung cuộn ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isSearching) ...[
                      // Xung quanh vị trí hiện tại
                      _buildNearbyLocation(),

                      const SizedBox(height: 8),

                      // Lịch sử tìm kiếm
                      if (widget.searchHistory.isNotEmpty) ...[
                        _buildSectionTitle(AppStrings.lichSuTimKiem),
                        ...historyToShow.map(_buildHistoryItem),
                        if (widget.searchHistory.length > 3)
                          _buildXemThem(),
                      ],
                    ] else ...[
                      // Kết quả gợi ý khi đang gõ
                      if (_filteredCities.isEmpty)
                        _buildNoResult()
                      else
                        ..._filteredCities.map(_buildSuggestionItem),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── WIDGETS ────────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderFocus, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.white,
      ),
      child: Row(
        children: [
          // Nút back
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          // TextField
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: AppStrings.nhapDiemDen,
                hintStyle: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // Nút xóa text
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
              onPressed: () {
                _searchController.clear();
                _focusNode.requestFocus();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNearbyLocation() {
    return InkWell(
      onTap: () {
        // TODO: Lấy vị trí GPS hiện tại
        _selectCity('Vị trí hiện tại');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.my_location,
                color: AppColors.primaryLight,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              AppStrings.xungQuanhViTri,
              style: TextStyle(
                color: AppColors.primaryLight,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildHistoryItem(SearchHistoryModel item) {
    return InkWell(
      onTap: () => _selectCity(item.city),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.history,
                color: AppColors.primaryLight,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.city} (${item.city})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.subtitle.isNotEmpty)
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXemThem() {
    return InkWell(
      onTap: () => setState(() => _showAllHistory = !_showAllHistory),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Text(
          _showAllHistory ? 'Thu gọn' : AppStrings.xemThem,
          style: const TextStyle(
            color: AppColors.primaryLight,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String city) {
    return InkWell(
      onTap: () => _selectCity(city),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Việt Nam',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResult() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              'Không tìm thấy "${_searchController.text}"',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
