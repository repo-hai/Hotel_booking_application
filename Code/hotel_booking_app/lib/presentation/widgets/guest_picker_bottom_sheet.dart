import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GuestSelection {
  final int rooms;
  final int adults;
  final int children;
  final bool withPets;

  const GuestSelection({
    this.rooms = 1,
    this.adults = 2,
    this.children = 0,
    this.withPets = false,
  });
}

class GuestPickerBottomSheet extends StatefulWidget {
  final GuestSelection initial;

  const GuestPickerBottomSheet({
    super.key,
    required this.initial,
  });

  @override
  State<GuestPickerBottomSheet> createState() => _GuestPickerBottomSheetState();
}

class _GuestPickerBottomSheetState extends State<GuestPickerBottomSheet> {
  late int _rooms;
  late int _adults;
  late int _children;
  late bool _withPets;

  @override
  void initState() {
    super.initState();
    _rooms = widget.initial.rooms;
    _adults = widget.initial.adults;
    _children = widget.initial.children;
    _withPets = widget.initial.withPets;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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

          // Title
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Chọn phòng và khách',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Phòng
          _buildCounterRow(
            label: 'Phòng',
            value: _rooms,
            min: 1,
            max: 10,
            onDecrement: () => setState(() => _rooms--),
            onIncrement: () => setState(() => _rooms++),
          ),

          _buildDivider(),

          // Người lớn
          _buildCounterRow(
            label: 'Người lớn',
            value: _adults,
            min: 1,
            max: 20,
            onDecrement: () => setState(() => _adults--),
            onIncrement: () => setState(() => _adults++),
          ),

          _buildDivider(),

          // Trẻ em
          _buildCounterRow(
            label: 'Trẻ em',
            value: _children,
            min: 0,
            max: 10,
            onDecrement: () => setState(() => _children--),
            onIncrement: () => setState(() => _children++),
          ),

          _buildDivider(),

          // Mang theo thú cưng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Mang theo thú cưng',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Switch(
                  value: _withPets,
                  onChanged: (v) => setState(() => _withPets = v),
                  activeColor: AppColors.primaryLight,
                ),
              ],
            ),
          ),

          // Nút Xác nhận
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(
                  context,
                  GuestSelection(
                    rooms: _rooms,
                    adults: _adults,
                    children: _children,
                    withPets: _withPets,
                  ),
                ),
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
                  'Xác nhận',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterRow({
    required String label,
    required int value,
    required int min,
    required int max,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    final canDecrement = value > min;
    final canIncrement = value < max;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Label
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Counter box
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nút trừ
                _buildCounterButton(
                  icon: Icons.remove,
                  onTap: canDecrement ? onDecrement : null,
                  isLeft: true,
                ),

                // Số
                SizedBox(
                  width: 44,
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
                _buildCounterButton(
                  icon: Icons.add,
                  onTap: canIncrement ? onIncrement : null,
                  isLeft: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isLeft,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: isLeft
              ? const Border(right: BorderSide(color: AppColors.border))
              : const Border(left: BorderSide(color: AppColors.border)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.primaryLight : Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 20, endIndent: 20);
  }
}
