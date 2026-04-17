import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/hotel_model.dart';
import '../../data/models/booking_customer_info.dart';
import 'booking_detail_screen.dart';

class GuestInfoScreen extends StatefulWidget {
  final HotelModel hotel;
  final List<Map<String, dynamic>> selectedRooms; // [{room, quantity}]
  final double totalPrice;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int guests;
  final int nights;

  const GuestInfoScreen({
    super.key,
    required this.hotel,
    required this.selectedRooms,
    required this.totalPrice,
    this.checkIn,
    this.checkOut,
    this.guests = 2,
    this.nights = 1,
  });

  @override
  State<GuestInfoScreen> createState() => _GuestInfoScreenState();
}

class _GuestInfoScreenState extends State<GuestInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String _selectedCountry = 'Việt Nam';
  bool _saveAsDefault = false;

  // Danh sách quốc gia phổ biến
  static const List<String> _countries = [
    'Việt Nam',
    'Hoa Kỳ',
    'Nhật Bản',
    'Hàn Quốc',
    'Trung Quốc',
    'Thái Lan',
    'Singapore',
    'Pháp',
    'Đức',
    'Anh',
    'Úc',
    'Canada',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedInfo();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // Tải thông tin đã lưu từ SharedPreferences
  Future<void> _loadSavedInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _firstNameCtrl.text = prefs.getString('guest_firstName') ?? '';
        _lastNameCtrl.text = prefs.getString('guest_lastName') ?? '';
        _emailCtrl.text = prefs.getString('guest_email') ?? '';
        _phoneCtrl.text = prefs.getString('guest_phone') ?? '';
        _selectedCountry =
            prefs.getString('guest_country') ?? 'Việt Nam';
      });
    } catch (_) {}
  }

  // Lưu thông tin mặc định
  Future<void> _saveDefaultInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('guest_firstName', _firstNameCtrl.text.trim());
      await prefs.setString('guest_lastName', _lastNameCtrl.text.trim());
      await prefs.setString('guest_email', _emailCtrl.text.trim());
      await prefs.setString('guest_phone', _phoneCtrl.text.trim());
      await prefs.setString('guest_country', _selectedCountry);
    } catch (_) {}
  }

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

  void _onNext() async {
    if (!_formKey.currentState!.validate()) return;

    if (_saveAsDefault) {
      await _saveDefaultInfo();
    }

    final info = BookingCustomerInfo(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      country: _selectedCountry,
      phone: _phoneCtrl.text.trim(),
      saveAsDefault: _saveAsDefault,
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingDetailScreen(
          hotel: widget.hotel,
          customerInfo: info,
          selectedRooms: widget.selectedRooms,
          totalPrice: widget.totalPrice,
          checkIn: widget.checkIn,
          checkOut: widget.checkOut,
          guests: widget.guests,
          nights: widget.nights,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField(
                      label: 'Tên',
                      required: true,
                      controller: _firstNameCtrl,
                      hint: 'Nhập tên của bạn',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Họ',
                      required: true,
                      controller: _lastNameCtrl,
                      hint: 'Nhập họ của bạn',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Email',
                      required: true,
                      controller: _emailCtrl,
                      hint: 'example@email.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                        if (!v.contains('@')) return 'Email không hợp lệ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildCountryDropdown(),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Điện thoại',
                      required: true,
                      controller: _phoneCtrl,
                      hint: '0xxxxxxxxx',
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Vui lòng nhập số điện thoại' : null,
                    ),
                    const SizedBox(height: 24),
                    // Checkbox lưu mặc định
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _saveAsDefault,
                            onChanged: (v) =>
                                setState(() => _saveAsDefault = v ?? false),
                            activeColor: AppColors.primaryLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Lưu thông tin này làm mặc định',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Điền thông tin của bạn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required bool required,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: required
                ? const [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    )
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primaryLight, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, __) {
                if (value.text.isEmpty) return const SizedBox();
                final isValid = validator == null || validator(value.text) == null;
                return Icon(
                  isValid ? Icons.check_circle_outline : Icons.error_outline,
                  color: isValid ? Colors.green : Colors.red,
                  size: 20,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Vùng/quốc gia',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(text: '*', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCountry,
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    items: _countries
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCountry = v);
                    },
                  ),
                ),
              ),
              const Icon(Icons.check_circle_outline,
                  color: Colors.green, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_formatPrice(widget.totalPrice)} VND',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Text(
            'Đã bao gồm thuế và phí',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Bước tiếp theo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
