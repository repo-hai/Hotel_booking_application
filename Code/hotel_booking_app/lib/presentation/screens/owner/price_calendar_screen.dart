import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriceCalendarScreen extends StatefulWidget {
  final int initialPrice;
  const PriceCalendarScreen({super.key, this.initialPrice = 0});

  @override
  State<PriceCalendarScreen> createState() => _PriceCalendarScreenState();
}

class _PriceCalendarScreenState extends State<PriceCalendarScreen> {
  String _selectedOption = "Tất cả các ngày";
  DateTime _currentMonth = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;
  late TextEditingController _priceController;
  
  // Giả lập giá phòng theo ngày
  final Map<DateTime, int> _dayPrices = {};

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: NumberFormat("#,###").format(widget.initialPrice));
    
    // Khởi tạo giá mặc định cho 4 tháng (tháng hiện tại + 3)
    final now = DateTime.now();
    for (int m = 0; m < 4; m++) {
      final monthDate = DateTime(now.year, now.month + m, 1);
      final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
      for (int d = 1; d <= daysInMonth; d++) {
        _dayPrices[DateTime(monthDate.year, monthDate.month, d)] = widget.initialPrice;
      }
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _onDateTap(DateTime date) {
    if (_selectedOption != "Tùy chọn") return;

    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = date;
        _endDate = null;
      } else if (_startDate != null && date.isBefore(_startDate!)) {
        _startDate = date;
      } else {
        _endDate = date;
      }
    });
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2E5AAC)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _startDate!.isAfter(_endDate!)) _endDate = null;
        } else {
          _endDate = picked;
          if (_startDate != null && _endDate!.isBefore(_startDate!)) _startDate = null;
        }
      });
    }
  }

  void _applyPrice() {
    final newPriceStr = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final newPrice = int.tryParse(newPriceStr) ?? 0;

    setState(() {
      _dayPrices.forEach((date, _) {
        bool shouldUpdate = false;
        
        if (_selectedOption == "Tất cả các ngày") {
          shouldUpdate = true;
        } else if (_selectedOption == "Các ngày trong tuần") {
          shouldUpdate = date.weekday >= 1 && date.weekday <= 5;
        } else if (_selectedOption == "Các ngày cuối tuần") {
          shouldUpdate = date.weekday == 6 || date.weekday == 7;
        } else if (_selectedOption == "Tùy chọn") {
          if (_startDate != null && _endDate != null) {
            shouldUpdate = (date.isAtSameMomentAs(_startDate!) || date.isAfter(_startDate!)) &&
                           (date.isAtSameMomentAs(_endDate!) || date.isBefore(_endDate!));
          } else if (_startDate != null) {
            shouldUpdate = date.isAtSameMomentAs(_startDate!);
          }
        }

        if (shouldUpdate) {
          _dayPrices[date] = newPrice;
        }
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã cập nhật giá phòng thành công")),
    );

    // Trả giá mới về màn hình trước sau khi áp dụng
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.pop(context, newPrice);
    });
  }

  bool _isDateSelected(DateTime date) {
    if (_selectedOption == "Tất cả các ngày") return true;
    if (_selectedOption == "Các ngày trong tuần") return date.weekday >= 1 && date.weekday <= 5;
    if (_selectedOption == "Các ngày cuối tuần") return date.weekday == 6 || date.weekday == 7;
    
    if (_selectedOption == "Tùy chọn") {
      if (_startDate != null && _endDate != null) {
        return (date.isAtSameMomentAs(_startDate!) || date.isAfter(_startDate!)) &&
               (date.isAtSameMomentAs(_endDate!) || date.isBefore(_endDate!));
      }
      return date.isAtSameMomentAs(_startDate ?? DateTime(1900));
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Giá phòng theo lịch", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Áp dụng cho:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildRadioOption("Tất cả các ngày"),
            _buildRadioOption("Các ngày trong tuần"),
            _buildRadioOption("Các ngày cuối tuần"),
            _buildRadioOption("Tùy chọn"),
            const SizedBox(height: 20),
            
            if (_selectedOption == "Tùy chọn") ...[
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(context, true),
                      child: _buildDateInput("Ngày bắt đầu", _startDate == null ? "dd/mm/yyyy" : DateFormat('dd/MM/yyyy').format(_startDate!)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(context, false),
                      child: _buildDateInput("Ngày kết thúc", _endDate == null ? "dd/mm/yyyy" : DateFormat('dd/MM/yyyy').format(_endDate!)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
            ],
            
            _buildCalendarHeader(),
            const SizedBox(height: 15),
            _buildCalendarGrid(),
            const SizedBox(height: 25),
            
            Row(
              children: [
                const Text("Giá phòng", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      hintText: "0",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                const Text("VND", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyPrice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5AAC),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Áp dụng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String title) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: title,
      groupValue: _selectedOption,
      activeColor: const Color(0xFF2E5AAC),
      onChanged: (val) {
        setState(() {
          _selectedOption = val!;
          if (_selectedOption != "Tùy chọn") {
            _startDate = null;
            _endDate = null;
          }
        });
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDateInput(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: const TextStyle(fontSize: 13, color: Colors.black87)),
              const Icon(Icons.calendar_month, size: 18, color: Color(0xFF2E5AAC)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left), 
          onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1))
        ),
        Text(
          "Tháng ${_currentMonth.month} năm ${_currentMonth.year}", 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right), 
          onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1))
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfWeek = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7;
    
    final List<String> weekDays = ["CN", "T2", "T3", "T4", "T5", "T6", "T7"];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays.map((d) => Text(d, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))).toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.8,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
          ),
          itemCount: daysInMonth + firstDayOfWeek,
          itemBuilder: (context, index) {
            if (index < firstDayOfWeek) return const SizedBox();
            
            final day = index - firstDayOfWeek + 1;
            final date = DateTime(_currentMonth.year, _currentMonth.month, day);
            final isHighlighted = _isDateSelected(date);
            final price = _dayPrices[date] ?? 0;
            final formattedPrice = price >= 1000000 ? "${(price / 1000000).toStringAsFixed(1)}M" : "${(price / 1000).toStringAsFixed(0)}k";

            return GestureDetector(
              onTap: () => _onDateTap(date),
              child: Container(
                decoration: BoxDecoration(
                  color: isHighlighted ? const Color(0xFF2E5AAC).withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isHighlighted ? Border.all(color: const Color(0xFF2E5AAC), width: 1) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("$day", style: TextStyle(fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal, color: isHighlighted ? const Color(0xFF2E5AAC) : Colors.black)),
                    const SizedBox(height: 4),
                    Text(formattedPrice, style: TextStyle(fontSize: 10, color: isHighlighted ? const Color(0xFF2E5AAC) : Colors.grey)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}