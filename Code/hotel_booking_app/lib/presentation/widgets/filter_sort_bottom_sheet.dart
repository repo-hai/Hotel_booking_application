import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

// ─── Ánh xạ icon Firebase → tên hiển thị ─────────────────────────────────────
// Dựa trên dữ liệu thực từ hotels.json
const Map<String, String> _amenityIconToLabel = {
  'fa-wifi': 'WiFi miễn phí',
  'fa-swimming-pool': 'Hồ bơi',
  'fa-spa': 'Spa',
  'fa-glass-martini-alt': 'Quầy bar',
  'fa-dumbbell': 'Phòng gym',
};

// Loại chỗ nghỉ thực từ DB
const List<String> _propertyTypesFromDB = [
  'Khách sạn',
  'Resort',
  'Villa',
  'Homestay',
  'Căn hộ dịch vụ',
];

// ─── Model kết quả ────────────────────────────────────────────────────────────
class FilterSortResult {
  final double? minPrice;
  final double? maxPrice;
  final int? minStar;
  // Gửi icon Firebase để backend so sánh chính xác
  final List<String> requiredAmenityIcons;
  // Loại chỗ nghỉ (Khách sạn, Resort, Villa, Homestay, Căn hộ dịch vụ)
  final List<String> propertyTypes;
  final String? sortBy; // price_asc | price_desc | star_desc | star_asc
  // Các filter chỉ dùng ở client (không gửi backend)
  final List<String> requiredAmenities; // kept for backward compat

  const FilterSortResult({
    this.minPrice,
    this.maxPrice,
    this.minStar,
    this.requiredAmenityIcons = const [],
    this.propertyTypes = const [],
    this.sortBy,
    this.requiredAmenities = const [],
  });

  bool get hasActiveFilter =>
      minPrice != null ||
      maxPrice != null ||
      minStar != null ||
      requiredAmenityIcons.isNotEmpty ||
      propertyTypes.isNotEmpty ||
      sortBy != null;
}

// ─── Widget ───────────────────────────────────────────────────────────────────
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
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  // Hạng sao (null = tất cả)
  int? _minStar;

  // Loại chỗ nghỉ
  final Set<String> _propertyTypes = {};

  // Tiện nghi theo icon FB
  final Set<String> _amenityIcons = {};

  // Sắp xếp
  String? _sortBy;

  static const _sortOptions = [
    _SortOpt('price_asc', 'Giá thấp đến cao'),
    _SortOpt('price_desc', 'Giá cao đến thấp'),
    _SortOpt('star_desc', 'Sao nhiều nhất'),
    _SortOpt('star_asc', 'Sao ít nhất'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final i = widget.initial;
    if (i.minPrice != null) _minCtrl.text = i.minPrice!.toStringAsFixed(0);
    if (i.maxPrice != null) _maxCtrl.text = i.maxPrice!.toStringAsFixed(0);
    _minStar = i.minStar;
    _propertyTypes.addAll(i.propertyTypes);
    _amenityIcons.addAll(i.requiredAmenityIcons);
    _sortBy = i.sortBy;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _reset() => setState(() {
    _minCtrl.clear(); _maxCtrl.clear();
    _minStar = null; _propertyTypes.clear();
    _amenityIcons.clear(); _sortBy = null;
  });

  void _apply() {
    final minP = double.tryParse(_minCtrl.text.replaceAll('.', '').replaceAll(',', ''));
    final maxP = double.tryParse(_maxCtrl.text.replaceAll('.', '').replaceAll(',', ''));
    Navigator.pop(context, FilterSortResult(
      minPrice: minP,
      maxPrice: maxP,
      minStar: _minStar,
      requiredAmenityIcons: _amenityIcons.toList(),
      propertyTypes: _propertyTypes.toList(),
      sortBy: _sortBy,
    ));
  }

  int get _activeCount =>
      (_minCtrl.text.isNotEmpty || _maxCtrl.text.isNotEmpty ? 1 : 0) +
      (_minStar != null ? 1 : 0) +
      _propertyTypes.length +
      _amenityIcons.length +
      (_sortBy != null ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          _handle(),
          _header(),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryLight,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryLight,
            tabs: const [Tab(text: 'Bộ lọc'), Tab(text: 'Sắp xếp')],
          ),
          Expanded(child: TabBarView(
            controller: _tabController,
            children: [_filterTab(), _sortTab()],
          )),
          _bottomBar(),
        ],
      ),
    );
  }

  Widget _handle() => Container(
    margin: const EdgeInsets.only(top: 10),
    width: 40, height: 4,
    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
  );

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
    child: Row(children: [
      const Text('Lọc & Sắp xếp',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const Spacer(),
      TextButton(onPressed: _reset,
          child: const Text('Đặt lại', style: TextStyle(color: AppColors.primaryLight))),
      IconButton(icon: const Icon(Icons.close, size: 20),
          onPressed: () => Navigator.pop(context), color: AppColors.textSecondary),
    ]),
  );

  Widget _bottomBar() => Container(
    padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 12),
    decoration: BoxDecoration(color: AppColors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200))),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      if (_activeCount > 0)
        Padding(padding: const EdgeInsets.only(bottom: 6),
          child: Text('$_activeCount bộ lọc đang áp dụng',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
      SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: _apply,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight, foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text('Xem kết quả', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      )),
    ]),
  );

  // ─── TAB BỘ LỌC ──────────────────────────────────────────────────────────
  Widget _filterTab() => SingleChildScrollView(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _priceSection(),
      _div(),
      _starSection(),
      _div(),
      _propertyTypeSection(),
      _div(),
      _amenitySection(),
      const SizedBox(height: 16),
    ]),
  );

  Widget _div() => Container(height: 8, color: const Color(0xFFF5F5F5));

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary));

  // 1. Giá
  Widget _priceSection() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Ngân sách cho một đêm (VND)'),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _priceField(_minCtrl, 'Từ')),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('—', style: TextStyle(color: AppColors.textSecondary))),
        Expanded(child: _priceField(_maxCtrl, 'Đến')),
      ]),
    ]),
  );

  Widget _priceField(TextEditingController ctrl, String hint) => TextField(
    controller: ctrl,
    keyboardType: TextInputType.number,
    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primaryLight)),
    ),
  );

  // 2. Hạng sao — dựa trên star: 3, 4, 5 trong DB
  Widget _starSection() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Hạng sao'),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _starChip(null, 'Tất cả'),
        _starChip(3, '3 ★'),
        _starChip(4, '4 ★'),
        _starChip(5, '5 ★'),
      ]),
    ]),
  );

  Widget _starChip(int? star, String label) {
    final sel = _minStar == star;
    return GestureDetector(
      onTap: () => setState(() => _minStar = sel ? null : star),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? AppColors.primaryLight : AppColors.white,
          border: Border.all(color: sel ? AppColors.primaryLight : AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 13, fontWeight: sel ? FontWeight.bold : FontWeight.normal,
          color: sel ? AppColors.white : AppColors.textPrimary,
        )),
      ),
    );
  }

  // 3. Loại chỗ nghỉ — dùng đúng type từ DB
  Widget _propertyTypeSection() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Loại chỗ nghỉ'),
      const SizedBox(height: 8),
      ..._propertyTypesFromDB.map((t) => _checkRow(
        t, t, _propertyTypes.contains(t),
        (v) => setState(() { if (v) _propertyTypes.add(t); else _propertyTypes.remove(t); }),
      )),
    ]),
  );

  // 4. Tiện nghi — dùng icon FB từ dữ liệu thực
  Widget _amenitySection() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Tiện nghi chỗ nghỉ'),
      const SizedBox(height: 8),
      ..._amenityIconToLabel.entries.map((e) => _checkRow(
        e.key, e.value, _amenityIcons.contains(e.key),
        (v) => setState(() { if (v) _amenityIcons.add(e.key); else _amenityIcons.remove(e.key); }),
      )),
    ]),
  );

  Widget _checkRow(String key, String label, bool checked, void Function(bool) onChange) =>
    InkWell(
      onTap: () => onChange(!checked),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(children: [
          Expanded(child: Text(label,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
          SizedBox(width: 24, height: 24, child: Checkbox(
            value: checked,
            onChanged: (v) => onChange(v ?? false),
            activeColor: AppColors.primaryLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: AppColors.border, width: 1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          )),
        ]),
      ),
    );

  // ─── TAB SẮP XẾP ─────────────────────────────────────────────────────────
  Widget _sortTab() => ListView(
    padding: const EdgeInsets.symmetric(vertical: 8),
    children: _sortOptions.map((opt) {
      final sel = _sortBy == opt.value;
      return InkWell(
        onTap: () => setState(() => _sortBy = sel ? null : opt.value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Expanded(child: Text(opt.label, style: TextStyle(
              fontSize: 15,
              color: sel ? AppColors.primaryLight : AppColors.textPrimary,
              fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
            ))),
            sel
                ? const Icon(Icons.check_circle, color: AppColors.primaryLight, size: 20)
                : const Icon(Icons.radio_button_unchecked, color: AppColors.border, size: 20),
          ]),
        ),
      );
    }).toList(),
  );
}

class _SortOpt {
  final String value;
  final String label;
  const _SortOpt(this.value, this.label);
}
