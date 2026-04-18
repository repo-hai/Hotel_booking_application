import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/owner_provider.dart';
import 'owner_home_screen.dart';
import 'statistics_home_screen.dart';

class OwnerAccountScreen extends StatefulWidget {
  const OwnerAccountScreen({super.key});

  @override
  State<OwnerAccountScreen> createState() => _OwnerAccountScreenState();
}

class _OwnerAccountScreenState extends State<OwnerAccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OwnerProvider>(context, listen: false).refreshDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OwnerProvider>(context);
    final profile = provider.ownerProfile;
    final isLoading = provider.isLoading;

    final name = profile['Name'] ?? profile['name'] ?? provider.ownerName;
    final email = profile['Email'] ?? profile['email'] ?? 'Chưa cập nhật email';
    final phone = profile['Phone'] ?? profile['phone'] ?? 'Chưa cập nhật số điện thoại';
    final role = profile['Role'] ?? profile['role'] ?? 'Chủ khách sạn';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Tài khoản của tôi", 
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoading && profile.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.refreshDashboard(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF2E5AAC), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF2E5AAC).withValues(alpha: 0.1),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'O',
                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF2E5AAC)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      role,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                    
                    _buildInfoCard("Email", email, Icons.email_outlined),
                    const SizedBox(height: 15),
                    _buildInfoCard("Số điện thoại", phone, Icons.phone_outlined),
                    const SizedBox(height: 30),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Logout action placeholder
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chức năng đăng xuất chưa được hỗ trợ trong bản demo.')),
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.pink),
                        label: const Text("Đăng xuất", style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.withValues(alpha: 0.1),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2E5AAC).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF2E5AAC), size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2E5AAC),
      unselectedItemColor: Colors.grey,
      currentIndex: 3,
      onTap: (index) {
        if (index == 0) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (index == 1) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StatisticsHomeScreen()));
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Trang chủ"),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Thống kê"),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Tin nhắn"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Tài khoản"),
      ],
    );
  }
}
