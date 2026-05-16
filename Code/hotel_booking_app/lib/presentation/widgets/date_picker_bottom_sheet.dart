import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// Class kết quả trả về thay vì Map để tránh lỗi generic trên web
class DateRangeResult {
  final DateTime checkIn;
  final DateTime checkOut;
  const DateRangeResult({required this.checkIn, required this.checkOut});
}

class DatePickerBottomSheet extends StatefulWidget {
  final DateTime? initialCheckIn;
  final DateTime? initialCheckOut;

  const DatePickerBottomSheet({
    super.key,
    this.initialCheckIn,
    this.initialCheckOut,
  });

  @override
  State<DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<DatePickerBottomSheet> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  late DateTime _displayMonth;

  // Tên thứ trong tuần (bắt đầu T.2)
  static const List<String> _weekDays = [
    'T.2', 'T.3', 'T.4', 'T.5', 'T.6', 'T.7', 'CN'
  ];

  @override
  void initState() {
    super.initState();
    _checkIn = widget.initialCheckIn;
    _checkOut = widget.initialCheckOut;
    _displayMonth = DateTime(
      (_checkIn ?? DateTime.now()).year,
      (_checkIn ?? DateTime.now()).month,
    );
  }

  // Tổng số đêm
  int get _nights {
    if (_checkIn == null || _checkOut == null) return 0;
    return _checkOut!.difference(_checkIn!).inDays;
  }

  // Tên tháng hiển thị
  String get _monthTitle =>
      'Tháng ${_displayMonth.month}  ${_displayMonth.year}';

  void _onDayTap(DateTime day) {
    setState(() {
      if (_checkIn == null || (_checkIn != null && _checkOut != null)) {
        // Bắt đầu chọn mới
        _checkIn = day;
        _checkOut = null;
      } else {
        // Đã có check-in, chọn check-out
        if (day.isBefore(_checkIn!)) {
          _checkOut = _checkIn;
          _checkIn = day;
        } else if (day == _checkIn) {
          // Tap lại ngày check-in → reset
          _checkIn = null;
        } else {
          _checkOut = day;
        }
      }
    });
  }

  void _prevMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
    });
  }

  bool _isInRange(DateTime day) {
    if (_checkIn == null || _checkOut == null) return false;
    return day.isAfter(_checkIn!) && day.isBefore(_checkOut!);
  }

  bool _isCheckIn(DateTime day) =>
      _checkIn != null && _isSameDay(day, _checkIn!);

  bool _isCheckOut(DateTime day) =>
      _checkOut != null && _isSameDay(day, _checkOut!);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isPast(DateTime day) {
    final today = DateTime.now();
    return day.isBefore(DateTime(today.year, today.month, today.day));
  }

  // Tạo danh sách ngày trong tháng (có padding đầu tháng)
  List<DateTime?> _buildCalendarDays() {
    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    // weekday: 1=T2, 7=CN → offset để T2 ở cột đầu
    final offset = (firstDay.weekday - 1) % 7;
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;

    final List<DateTime?> days = <DateTime?>[];
    for (int i = 0; i < offset; i++) {
      days.add(null);
    }
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_displayMonth.year, _displayMonth.month, i));
    }
    return days;
  }

  String _formatSummary() {
    if (_checkIn == null) return 'Chọn ngày nhận phòng';
    if (_checkOut == null) return 'Chọn ngày trả phòng';
    return '${_checkIn!.day} Th${_checkIn!.month} - ${_checkOut!.day} Th${_checkOut!.month} ($_nights đêm)';
  }

  @override
  Widget build(BuildContext context) {
    final calendarDays = _buildCalendarDays();

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
              'Chọn lịch',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const Divider(height: 20),

          // Header ngày trong tuần
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _weekDays
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Điều hướng tháng + tên tháng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _prevMonth,
                  color: AppColors.textSecondary,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      _monthTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          // Grid ngày
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: calendarDays.length,
              itemBuilder: (_, index) {
                final day = calendarDays[index];
                if (day == null) return const SizedBox();
                return _buildDayCell(day);
              },
            ),
          ),

          const SizedBox(height: 8),

          // Summary text
          Text(
            _formatSummary(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          // Nút Xác nhận
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_checkIn != null && _checkOut != null)
                    ? () => Navigator.pop(
                          context,
                          DateRangeResult(
                            checkIn: _checkIn!,
                            checkOut: _checkOut!,
                          ),
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  disabledBackgroundColor: Colors.grey[300],
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

  Widget _buildDayCell(DateTime day) {
    final isCI = _isCheckIn(day);
    final isCO = _isCheckOut(day);
    final inRange = _isInRange(day);
    final past = _isPast(day);

    Color bgColor = Colors.transparent;
    Color textColor = past ? Colors.grey[400]! : AppColors.textPrimary;
    BorderRadius radius = BorderRadius.circular(24);

    if (isCI || isCO) {
      bgColor = AppColors.primaryLight;
      textColor = AppColors.white;
      if (isCI && _checkOut != null) {
        radius = const BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        );
      }
      if (isCO && _checkIn != null) {
        radius = const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        );
      }
    } else if (inRange) {
      bgColor = AppColors.primaryLight.withValues(alpha: 0.15);
      radius = BorderRadius.zero;
    }

    return GestureDetector(
      onTap: past ? null : () => _onDayTap(day),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: radius,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: (isCI || isCO)
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
