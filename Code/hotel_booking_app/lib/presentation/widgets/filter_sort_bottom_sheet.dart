import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

// ── Model kết quả bộ lọc ────────────────────────────────────────────────────

class FilterSortResult {
  final double? minPrice;
  final double? maxPrice;
  final int? minStar;
  final List<String> requiredAmenities;
  final String? sortBy;
  // Bộ lọc phổ biến
  final bool includeBreakfast;
  final bool ratingAbove8;
  final bool noPrePayment;
  final bool roomService;
  // Loại chỗ nghỉ
  final Set<String> propertyTypes;
  // Điểm đánh giá tối thiểu (5,6,7,8,9)
  final int? minRating;
  // Tiện nghi chỗ nghỉ
  final Set<String> hotelAmenities;
  // Tiện nghi phòng
  final Set<String> roomAmenities;
  // Khoảng cách
  final int? maxDistanceKm;
  // Phòng & giường
  final int bedrooms;
  final int singleBeds;
  final int doubleBeds;
  final int bathrooms;

  const FilterSortResult({
    this.minPrice,
    this.maxPrice,
    this.minStar,
    this.requiredAmenities = const [],
    this.sortBy,
    this.includeBreakfast = false,
    this.ratingAbove8 = false,
    this.noPrePayment = false,
    this.roomService = false,
    this.propertyTypes = const {},
    this.minRating,
    this.hotelAmenities = const {},
    this.roomAmenities = const {},
    this.maxDistanceKm,
    this.bedrooms = 0,
    this.singleBeds = 0,
    this.doubleBeds = 0,
    this.bathrooms = 0,
  });

  bool get hasActiveFilter =>
      minPrice != null ||
      maxPrice != null ||
      minStar != null ||
      requiredAmenities.isNotEmpty ||
      sortBy != null ||
      includeBreakfast ||
      ratingAbove8 ||
      noPrePayment ||
      roomService ||
      propertyTypes.isNotEmpty ||
      minRating != null ||
      hotelAmenities.isNotEmpty ||
      roomAmenities.isNotEmpty ||
      maxDistanceKm != null ||
      bedrooms > 0 ||
      singleBeds > 0 ||
      doubleBeds > 0 ||
      bathrooms > 0;
}

// ── StatefulWidget ───────────────────────────────────────────────────────────

class FilterSortBottomSheet extends StatefulWidget {
  final FilterSortResult initial;
  const FilterSortBottomSheet({super.key, required this.initial});

  @override
  State<FilterSortBottomSheet> createState() => _FilterSortBottomSheetState();
}

class _FilterSortBottomSheetState extends State<FilterSortBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Giá
  final TextEditingController _minPriceCtrl = TextEditingController();
  final TextEditingController _maxPriceCtrl = TextEditingController();

  // Bộ lọc phổ biến
  bool _includeBreakfast = false;
  bool _ratingAbove8 = false;
  bool _noPrePayment = false;
  bool _roomService = false;
  bool _showMorePopular = false;

  // Loại chỗ nghỉ
  final Set<String> _propertyTypes = {};

  // Điểm đánh giá
  int? _minRating;

  // Tiện nghi chỗ nghỉ
  final Set<String> _hotelAmenities = {};
  bool _showMoreHotelAmenities = false;

  // Tiện nghi phòng
  final Set<String> _roomAmenities = {};
  bool _showMoreRoomAmenities = false;

  // Khoảng cách
  int? _maxDistanceKm;

  // Phòng & giường
  int _bedrooms = 0;
  int _singleBeds = 0;
  int _doubleBeds = 0;
  int _bathrooms = 0;

  // Sắp xếp
  String? _selectedSort;

  static const List<_SortOption> _sortOptions = [
    _SortOption(value: 'price_asc', label: AppStrings.giaThapDenCao),
    _SortOption(value: 'price_desc', label: AppStrings.giaCaoDenThap),
    _SortOption(value: 'star_desc', label: AppStrings.saoNhieuNhat),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final i = widget.initial;
    if (i.minPrice != null) _minPriceCtrl.text = i.minPrice!.toStringAsFixed(0);
    if (i.maxPrice != null) _maxPriceCtrl.text = i.maxPrice!.toStringAsFixed(0);
    _includeBreakfast = i.includeBreakfast;
    _ratingAbove8 = i.ratingAbove8;
    _noPrePayment = i.noPrePayment;
    _roomService = i.roomService;
    _propertyTypes.addAll(i.propertyTypes);
    _minRating = i.minRating;
    _hotelAmenities.addAll(i.hotelAmenities);
    _roomAmenities.addAll(i.roomAmenities);
    _maxDistanceKm = i.maxDistanceKm;
    _bedrooms = i.bedrooms;
    _singleBeds = i.singleBeds;
    _doubleBeds = i.doubleBeds;
    _bathrooms = i.bathrooms;
    _selectedSort = i.sortBy;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _minPriceCtrl.clear();
      _maxPriceCtrl.clear();
      _includeBreakfast = false;
      _ratingAbove8 = false;
      _noPrePayment = false;
      _roomService = false;
      _propertyTypes.clear();
      _minRating = null;
      _hotelAmenities.clear();
      _roomAmenities.clear();
      _maxDistanceKm = null;
      _bedrooms = 0;
      _singleBeds = 0;
      _doubleBeds = 0;
      _bathrooms = 0;
      _selectedSort = null;
    });
  }

  void _apply() {
    final minP = double.tryParse(_minPriceCtrl.text.replaceAll('.', ''));
    final maxP = double.tryParse(_maxPriceCtrl.text.replaceAll('.', ''));
    Navigator.pop(
      context,
      FilterSortResult(
        minPrice: minP,
        maxPrice: maxP,
        requiredAmenities: [..._hotelAmenities, ..._roomAmenities],
        sortBy: _selectedSort,
        includeBreakfast: _includeBreakfast,
        ratingAbove8: _ratingAbove8,
        noPrePayment: _noPrePayment,
        roomService: _roomService,
        propertyTypes: Set.from(_propertyTypes),
        minRating: _minRating,
        hotelAmenities: Set.from(_hotelAmenities),
        roomAmenities: Set.from(_roomAmenities),
        maxDistanceKm: _maxDistanceKm,
        bedrooms: _bedrooms,
        singleBeds: _singleBeds,
        doubleBeds: _doubleBeds,
        bathrooms: _bathrooms,
      ),
    );
  }

  // Đếm số bộ lọc đang bật
  int get _activeFilterCount {
    int count = 0;
    if (_minPriceCtrl.text.isNotEmpty || _maxPriceCtrl.text.isNotEmpty) count++;
    if (_includeBreakfast) count++;
    if (_ratingAbove8) count++;
    if (_noPrePayment) count++;
    if (_roomService) count++;
    count += _propertyTypes.length;
    if (_minRating != null) count++;
    count += _hotelAmenities.length;
    count += _roomAmenities.length;
    if (_maxDistanceKm != null) count++;
    if (_bedrooms > 0) count++;
    if (_singleBeds > 0) count++;
    if (_doubleBeds > 0) count++;
    if (_bathrooms > 0) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                const Text(
                  AppStrings.locVaSapXep,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _reset,
                  child: const Text(
                    AppStrings.datLai,
                    style: TextStyle(color: AppColors.primaryLight, fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryLight,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryLight,
            tabs: const [
              Tab(text: AppStrings.boLoc),
              Tab(text: AppStrings.sapXep),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFilterTab(),
                _buildSortTab(),
              ],
            ),
          ),

          // Bottom bar: số kết quả + nút xem
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final count = _activeFilterCount;
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '$count bộ lọc đang áp dụng',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Xem kết quả',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB BỘ LỌC ─────────────────────────────────────────────────────────────

  Widget _buildFilterTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceSection(),
          _buildDivider(),
          _buildPopularFiltersSection(),
          _buildDivider(),
          _buildPropertyTypeSection(),
          _buildDivider(),
          _buildRatingSection(),
          _buildDivider(),
          _buildHotelAmenitiesSection(),
          _buildDivider(),
          _buildRoomAmenitiesSection(),
          _buildDivider(),
          _buildDistanceSection(),
          _buildDivider(),
          _buildRoomBedsSection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 8, color: const Color(0xFFF5F5F5));
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  // 1. Ngân sách
  Widget _buildPriceSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Ngân sách cho một đêm'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPriceInput(
                  controller: _minPriceCtrl,
                  label: 'TỐI THIỂU',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPriceInput(
                  controller: _maxPriceCtrl,
                  label: 'TỐI ĐA',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInput({
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: const TextStyle(color: AppColors.textHint),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.primaryLight),
            ),
            suffixText: 'VND',
            suffixStyle: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  // 2. Bộ lọc phổ biến
  Widget _buildPopularFiltersSection() {
    final allItems = [
      _CheckItem('breakfast', 'Bao gồm bữa sáng', _includeBreakfast,
          (v) => setState(() => _includeBreakfast = v)),
      _CheckItem('rating8', 'Rất tốt: 8 điểm trở lên', _ratingAbove8,
          (v) => setState(() => _ratingAbove8 = v)),
      _CheckItem('noprepay', 'Không cần thanh toán trước', _noPrePayment,
          (v) => setState(() => _noPrePayment = v)),
      _CheckItem('roomservice', 'Dịch vụ phòng', _roomService,
          (v) => setState(() => _roomService = v)),
    ];
    final shown = _showMorePopular ? allItems : allItems.take(4).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Các bộ lọc phổ biến'),
          const SizedBox(height: 8),
          ...shown.map(_buildCheckRow),
          if (allItems.length > 4)
            _buildXemThem(
              _showMorePopular,
              () => setState(() => _showMorePopular = !_showMorePopular),
            ),
        ],
      ),
    );
  }

  // 3. Loại chỗ nghỉ
  Widget _buildPropertyTypeSection() {
    final types = [
      'Khách sạn',
      'Căn hộ',
      'Nhà nghỉ bình dân',
      'Homestay',
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Loại chỗ nghỉ'),
          const SizedBox(height: 8),
          ...types.map((t) => _buildCheckRow(_CheckItem(
                t,
                t,
                _propertyTypes.contains(t),
                (v) => setState(() {
                  if (v) {
                    _propertyTypes.add(t);
                  } else {
                    _propertyTypes.remove(t);
                  }
                }),
              ))),
        ],
      ),
    );
  }

  // 4. Điểm đánh giá
  Widget _buildRatingSection() {
    final ratings = [
      _RatingItem(5, 'Trung bình: 5 điểm trở lên'),
      _RatingItem(6, 'Dễ chịu: 6 điểm trở lên'),
      _RatingItem(7, 'Tốt: 7 điểm trở lên'),
      _RatingItem(8, 'Rất tốt: 8 điểm trở lên'),
      _RatingItem(9, 'Tuyệt vời: 9 điểm trở lên'),
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Điểm đánh giá'),
          const SizedBox(height: 8),
          ...ratings.map((r) => _buildCheckRow(_CheckItem(
                'rating_${r.value}',
                r.label,
                _minRating == r.value,
                (v) => setState(() => _minRating = v ? r.value : null),
              ))),
        ],
      ),
    );
  }

  // 5. Tiện nghi chỗ nghỉ
  Widget _buildHotelAmenitiesSection() {
    final all = [
      'Hồ bơi',
      'Chỗ đỗ xe',
      'Chỗ đỗ xe miễn phí',
      'Thang máy',
      'Nhà hàng',
      'Spa',
      'Phòng gym',
      'Quầy bar',
    ];
    final shown = _showMoreHotelAmenities ? all : all.take(4).toList();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Tiện nghi chỗ nghỉ'),
          const SizedBox(height: 8),
          ...shown.map((a) => _buildCheckRow(_CheckItem(
                a,
                a,
                _hotelAmenities.contains(a),
                (v) => setState(() {
                  if (v) {
                    _hotelAmenities.add(a);
                  } else {
                    _hotelAmenities.remove(a);
                  }
                }),
              ))),
          if (all.length > 4)
            _buildXemThem(
              _showMoreHotelAmenities,
              () => setState(
                  () => _showMoreHotelAmenities = !_showMoreHotelAmenities),
            ),
        ],
      ),
    );
  }

  // 6. Tiện nghi phòng
  Widget _buildRoomAmenitiesSection() {
    final all = [
      'Phòng tắm riêng',
      'Điều hòa không khí',
      'Tầm nhìn khung cảnh',
      'WiFi miễn phí',
      'Tivi màn hình phẳng',
      'Bếp / Bếp nhỏ',
      'Máy giặt',
      'Ban công',
    ];
    final shown = _showMoreRoomAmenities ? all : all.take(4).toList();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Tiện nghi phòng'),
          const SizedBox(height: 8),
          ...shown.map((a) => _buildCheckRow(_CheckItem(
                a,
                a,
                _roomAmenities.contains(a),
                (v) => setState(() {
                  if (v) {
                    _roomAmenities.add(a);
                  } else {
                    _roomAmenities.remove(a);
                  }
                }),
              ))),
          if (all.length > 4)
            _buildXemThem(
              _showMoreRoomAmenities,
              () => setState(
                  () => _showMoreRoomAmenities = !_showMoreRoomAmenities),
            ),
        ],
      ),
    );
  }

  // 7. Khoảng cách
  Widget _buildDistanceSection() {
    final distances = [
      _DistanceItem(1, 'Dưới 1km'),
      _DistanceItem(3, 'Dưới 3km'),
      _DistanceItem(5, 'Dưới 5km'),
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Khoảng cách từ trung tâm thành phố'),
          const SizedBox(height: 8),
          ...distances.map((d) => _buildCheckRow(_CheckItem(
                'dist_${d.km}',
                d.label,
                _maxDistanceKm == d.km,
                (v) => setState(() => _maxDistanceKm = v ? d.km : null),
              ))),
        ],
      ),
    );
  }

  // 8. Phòng & giường
  Widget _buildRoomBedsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Phòng và giường'),
          const SizedBox(height: 12),
          _buildCounterRow(
            label: 'Phòng ngủ',
            value: _bedrooms,
            onDecrement: _bedrooms > 0
                ? () => setState(() => _bedrooms--)
                : null,
            onIncrement: () => setState(() => _bedrooms++),
          ),
          const Divider(height: 1, color: AppColors.divider),
          _buildCounterRow(
            label: 'Giường đơn',
            value: _singleBeds,
            onDecrement: _singleBeds > 0
                ? () => setState(() => _singleBeds--)
                : null,
            onIncrement: () => setState(() => _singleBeds++),
          ),
          const Divider(height: 1, color: AppColors.divider),
          _buildCounterRow(
            label: 'Giường đôi',
            value: _doubleBeds,
            onDecrement: _doubleBeds > 0
                ? () => setState(() => _doubleBeds--)
                : null,
            onIncrement: () => setState(() => _doubleBeds++),
          ),
          const Divider(height: 1, color: AppColors.divider),
          _buildCounterRow(
            label: 'Phòng tắm',
            value: _bathrooms,
            onDecrement: _bathrooms > 0
                ? () => setState(() => _bathrooms--)
                : null,
            onIncrement: () => setState(() => _bathrooms++),
          ),
        ],
      ),
    );
  }

  // ── Shared widgets ──────────────────────────────────────────────────────────

  Widget _buildCheckRow(_CheckItem item) {
    return InkWell(
      onTap: () => item.onChanged(!item.checked),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: item.checked,
                onChanged: (v) => item.onChanged(v ?? false),
                activeColor: AppColors.primaryLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: AppColors.border, width: 1.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXemThem(bool expanded, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          expanded ? 'Thu gọn' : 'Xem thêm',
          style: const TextStyle(
            color: AppColors.primaryLight,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCounterRow({
    required String label,
    required int value,
    required VoidCallback? onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Row(
            children: [
              // Nút trừ
              GestureDetector(
                onTap: onDecrement,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: onDecrement != null
                          ? AppColors.primaryLight
                          : AppColors.border,
                    ),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: onDecrement != null
                        ? AppColors.primaryLight
                        : AppColors.border,
                  ),
                ),
              ),
              // Số
              SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              // Nút cộng
              GestureDetector(
                onTap: onIncrement,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryLight),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 16,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── TAB SẮP XẾP ────────────────────────────────────────────────────────────

  Widget _buildSortTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: _sortOptions.map(_buildSortTile).toList(),
    );
  }

  Widget _buildSortTile(_SortOption option) {
    final selected = _selectedSort == option.value;
    return InkWell(
      onTap: () => setState(() {
        _selectedSort = selected ? null : option.value;
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 15,
                  color: selected
                      ? AppColors.primaryLight
                      : AppColors.textPrimary,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  color: AppColors.primaryLight, size: 20)
            else
              const Icon(Icons.radio_button_unchecked,
                  color: AppColors.border, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Data classes ─────────────────────────────────────────────────────────────

class _CheckItem {
  final String key;
  final String label;
  final bool checked;
  final void Function(bool) onChanged;
  const _CheckItem(this.key, this.label, this.checked, this.onChanged);
}

class _RatingItem {
  final int value;
  final String label;
  const _RatingItem(this.value, this.label);
}

class _DistanceItem {
  final int km;
  final String label;
  const _DistanceItem(this.km, this.label);
}

class _SortOption {
  final String value;
  final String label;
  const _SortOption({required this.value, required this.label});
}
