import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/owner_provider.dart';
import '../../../models/hotel/hotel_model.dart';

class Step1TypeSelection extends StatefulWidget {
  final VoidCallback onNext;
  const Step1TypeSelection({super.key, required this.onNext});

  @override
  State<Step1TypeSelection> createState() => _Step1TypeSelectionState();
}

class _Step1TypeSelectionState extends State<Step1TypeSelection> {
  int _selectedIndex = -1;
  final List<String> types = ['Khách sạn', 'Resort', 'Homestay', 'Villa', 'Căn hộ dịch vụ'];

  void _onNext() {
    if (_selectedIndex == -1) return;
    
    final provider = Provider.of<OwnerProvider>(context, listen: false);
    provider.draftHotel = Hotel(
      id: '',
      type: types[_selectedIndex],
      name: '',
      description: '',
      telephone: '',
      location: '',
      email: '',
      star: 5,
      images: [],
      amenities: [],
    );
    
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: types.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedIndex == index;
              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isSelected ? const Color(0xFF2E5AAC) : Colors.grey.shade300, width: isSelected ? 2 : 1),
                ),
                child: ListTile(
                  title: Text(types[index], style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF2E5AAC)) : null,
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedIndex != -1 ? const Color(0xFF2E5AAC) : Colors.grey.shade300,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _selectedIndex != -1 ? _onNext : null,
            child: const Text("Tiếp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}