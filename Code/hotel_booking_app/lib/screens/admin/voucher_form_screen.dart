import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/voucher_model.dart';

class VoucherFormScreen extends StatefulWidget {
  final VoucherModel? voucher;

  const VoucherFormScreen({super.key, this.voucher});

  @override
  State<VoucherFormScreen> createState() => _VoucherFormScreenState();
}

class _VoucherFormScreenState extends State<VoucherFormScreen> {
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _discountController;
  late TextEditingController _maxDiscountController;
  late TextEditingController _minSpendController;
  late TextEditingController _usageLimitController;
  late DiscountType _discountType;
  late String _targetType;
  late bool _isActive;
  late DateTime _startDate;
  late DateTime _endDate;

  bool get isEditing => widget.voucher != null;

  @override
  void initState() {
    super.initState();
    final v = widget.voucher;
    _codeController = TextEditingController(text: v?.code ?? '');
    _nameController = TextEditingController(text: v?.name ?? '');
    _discountController = TextEditingController(
        text: v != null ? v.discountValue.toInt().toString() : '');
    _maxDiscountController = TextEditingController(
        text: v != null ? v.maxDiscount.toString() : '');
    _minSpendController = TextEditingController(
        text: v != null ? v.minSpend.toString() : '');
    _usageLimitController = TextEditingController(
        text: v != null ? v.usageLimit.toString() : '');
    _discountType = v?.discountType ?? DiscountType.percent;
    _targetType = v?.targetType ?? 'Tất cả';
    _isActive = v?.status == VoucherStatus.active;
    _startDate = v?.startDate ?? DateTime.now();
    _endDate = v?.endDate ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _discountController.dispose();
    _maxDiscountController.dispose();
    _minSpendController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Chỉnh sửa Voucher' : 'Tạo Voucher mới',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildBasicInfoCard(),
                  const SizedBox(height: 14),
                  _buildDiscountCard(),
                  const SizedBox(height: 14),
                  _buildConditionsCard(),
                  const SizedBox(height: 14),
                  _buildDateRangeCard(),
                  const SizedBox(height: 14),
                  _buildStatusCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildSectionCard(
      title: 'Thông tin cơ bản',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildFormField(
            label: 'Mã voucher',
            controller: _codeController,
            hint: 'VD: SUMMER2026',
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 14),
          _buildFormField(
            label: 'Tên voucher',
            controller: _nameController,
            hint: 'VD: Khuyến mãi Hè 2026',
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountCard() {
    return _buildSectionCard(
      title: 'Giảm giá',
      icon: Icons.local_offer_outlined,
      child: Column(
        children: [
          // Discount type toggle
          Row(
            children: [
              Expanded(
                child: _buildTypeButton(
                  'Phần trăm (%)',
                  DiscountType.percent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTypeButton(
                  'Số tiền (đ)',
                  DiscountType.fixed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildFormField(
            label: _discountType == DiscountType.percent
                ? 'Giá trị giảm (%)'
                : 'Giá trị giảm (đ)',
            controller: _discountController,
            hint: _discountType == DiscountType.percent ? 'VD: 20' : 'VD: 50000',
            keyboardType: TextInputType.number,
          ),
          if (_discountType == DiscountType.percent) ...[
            const SizedBox(height: 14),
            _buildFormField(
              label: 'Giảm tối đa (đ)',
              controller: _maxDiscountController,
              hint: 'VD: 500000',
              keyboardType: TextInputType.number,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, DiscountType type) {
    final isSelected = _discountType == type;
    return GestureDetector(
      onTap: () => setState(() => _discountType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConditionsCard() {
    return _buildSectionCard(
      title: 'Điều kiện áp dụng',
      icon: Icons.rule_outlined,
      child: Column(
        children: [
          _buildFormField(
            label: 'Đơn tối thiểu (đ)',
            controller: _minSpendController,
            hint: 'VD: 1000000',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          _buildFormField(
            label: 'Giới hạn lượt dùng',
            controller: _usageLimitController,
            hint: 'VD: 500',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          // Target type dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Đối tượng áp dụng',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.textSecondary.withOpacity(0.2),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _targetType,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary),
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    items: ['Tất cả', 'Người dùng mới', 'VIP']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _targetType = v ?? 'Tất cả'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeCard() {
    return _buildSectionCard(
      title: 'Thời gian hiệu lực',
      icon: Icons.date_range_outlined,
      child: Row(
        children: [
          Expanded(
            child: _buildDatePicker('Ngày bắt đầu', _startDate, (date) {
              setState(() => _startDate = date);
            }),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDatePicker('Ngày kết thúc', _endDate, (date) {
              setState(() => _endDate = date);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
      String label, DateTime date, ValueChanged<DateTime> onPicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
            );
            if (picked != null) onPicked(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.textSecondary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  VoucherModel.formatDate(date),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kích hoạt voucher',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isActive
                      ? 'Voucher đang hoạt động'
                      : 'Voucher đang bị tắt',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isActive ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
            activeColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: AppColors.textSecondary.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: AppColors.textSecondary.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            isEditing ? 'Lưu thay đổi' : 'Tạo Voucher',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    if (_codeController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (isEditing) {
      final v = widget.voucher!;
      v.code = _codeController.text;
      v.name = _nameController.text;
      v.discountType = _discountType;
      v.discountValue = double.tryParse(_discountController.text) ?? 0;
      v.maxDiscount = int.tryParse(_maxDiscountController.text) ?? 0;
      v.minSpend = int.tryParse(_minSpendController.text) ?? 0;
      v.usageLimit = int.tryParse(_usageLimitController.text) ?? 0;
      v.targetType = _targetType;
      v.startDate = _startDate;
      v.endDate = _endDate;
      v.status = _isActive ? VoucherStatus.active : VoucherStatus.disabled;
    } else {
      MockVouchers.all.add(VoucherModel(
        id: DateTime.now().millisecondsSinceEpoch,
        code: _codeController.text,
        name: _nameController.text,
        discountType: _discountType,
        discountValue: double.tryParse(_discountController.text) ?? 0,
        maxDiscount: int.tryParse(_maxDiscountController.text) ?? 0,
        minSpend: int.tryParse(_minSpendController.text) ?? 0,
        usageLimit: int.tryParse(_usageLimitController.text) ?? 0,
        usedCount: 0,
        startDate: _startDate,
        endDate: _endDate,
        targetType: _targetType,
        status: _isActive ? VoucherStatus.active : VoucherStatus.disabled,
      ));
    }

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.white, size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                isEditing ? 'Cập nhật thành công!' : 'Tạo voucher thành công!',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isEditing
                    ? 'Voucher đã được cập nhật trong hệ thống.'
                    : 'Voucher mới đã được thêm vào hệ thống và sẵn sàng sử dụng.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context, 'saved');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Quay lại danh sách',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline,
                    color: AppColors.danger, size: 28),
              ),
              const SizedBox(height: 20),
              const Text(
                'Xóa voucher này?',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                  children: [
                    const TextSpan(
                        text: 'Bạn có chắc chắn muốn xóa voucher '),
                    TextSpan(
                      text: widget.voucher?.code ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '? Hành động này không thể hoàn tác.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Hủy',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          MockVouchers.all
                              .removeWhere((v) => v.id == widget.voucher!.id);
                          Navigator.pop(ctx);
                          Navigator.pop(context, 'deleted');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Xóa',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
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
}
