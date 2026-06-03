import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import 'booking_home_screen.dart';
import 'booking_history_screen.dart';
import 'client/chatbot_screen.dart';
import 'login.dart';
import 'forgot_password.dart';

class ProfileView extends StatefulWidget {
  /// isOwner: true = hiển thị từ owner app (không có bottom nav user)
  final bool isOwner;
  const ProfileView({super.key, this.isOwner = false});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String? _userId;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null || userId.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      _userId = userId;
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/users/$userId'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _userData = body['data'] ?? body;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _get(String key, [String fallback = '---']) {
    if (_userData == null) return fallback;
    return _userData![key]?.toString().isNotEmpty == true
        ? _userData![key].toString()
        : fallback;
  }

  String get _initials {
    final name = _get('Name', '');
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Đăng xuất',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('userId');
              await prefs.remove('role');
              await prefs.remove('password');
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const MyLoginPage(title: 'Đăng nhập'),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _openEditSheet() {
    if (_userData == null || _userId == null) return;

    final nameCtrl = TextEditingController(text: _get('Name', ''));
    final phoneCtrl = TextEditingController(text: _get('Phone', ''));
    final locationCtrl = TextEditingController(text: _get('Location', ''));
    final dobCtrl = TextEditingController(text: _get('DateOfBirth', ''));
    String selectedGender = _get('Gender', 'Nam');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sửa thông tin',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _editField('Họ và tên', nameCtrl, Icons.person_outline),
                      const SizedBox(height: 16),
                      _editField('Số điện thoại', phoneCtrl, Icons.phone_outlined,
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      _editField('Địa chỉ', locationCtrl, Icons.location_on_outlined),
                      const SizedBox(height: 16),
                      _editField('Ngày sinh', dobCtrl, Icons.cake_outlined,
                          hint: 'YYYY-MM-DD'),
                      const SizedBox(height: 16),
                      const Text('Giới tính',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Nam', 'Nữ', 'Khác'].map((g) {
                          final isSelected = selectedGender == g;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () => setSheetState(() => selectedGender = g),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryLight
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryLight
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(g,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    )),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  setSheetState(() => isSaving = true);
                                  try {
                                    final body = {
                                      'Name': nameCtrl.text.trim(),
                                      'Phone': phoneCtrl.text.trim(),
                                      'Location': locationCtrl.text.trim(),
                                      'DateOfBirth': dobCtrl.text.trim(),
                                      'Gender': selectedGender,
                                    };
                                    final response = await http.put(
                                      Uri.parse(
                                          '${ApiConstants.baseUrl}/api/users/$_userId'),
                                      headers: {
                                        'Content-Type': 'application/json'
                                      },
                                      body: jsonEncode(body),
                                    );
                                    if (!ctx.mounted) return;
                                    if (response.statusCode == 200) {
                                      Navigator.pop(ctx);
                                      _loadProfile();
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                              'Cập nhật thông tin thành công!'),
                                          backgroundColor: Colors.green,
                                        ));
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Cập nhật thất bại. Vui lòng thử lại!'),
                                        backgroundColor: Colors.red,
                                      ));
                                    }
                                  } catch (_) {
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Lỗi kết nối. Vui lòng thử lại!'),
                                        backgroundColor: Colors.red,
                                      ));
                                    }
                                  } finally {
                                    if (ctx.mounted) {
                                      setSheetState(() => isSaving = false);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Lưu thay đổi',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editField(String label, TextEditingController ctrl, IconData icon,
      {TextInputType? keyboardType, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: AppColors.primaryLight),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: AppColors.primaryLight, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryLight, strokeWidth: 2))
                : RefreshIndicator(
                    color: AppColors.primaryLight,
                    onRefresh: _loadProfile,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildAvatarCard(),
                          const SizedBox(height: 16),
                          _buildInfoCard(),
                          const SizedBox(height: 16),
                          if (!widget.isOwner) _buildMenuCard(),
                          if (!widget.isOwner) const SizedBox(height: 16),
                          _buildChangePasswordButton(),
                          const SizedBox(height: 12),
                          _buildLogoutButton(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: widget.isOwner ? null : _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Row(
            children: [
              if (Navigator.canPop(context))
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              const Expanded(
                child: Text(
                  'Tài khoản',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _openEditSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined,
                          color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('Sửa',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarCard() {
    final name = _get('Name', 'Người dùng');
    final role = _get('Role', 'Khách hàng');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryLight,
            child: Text(_initials,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          const SizedBox(height: 12),
          Text(name,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(role,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Thông tin cá nhân',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
          ),
          const Divider(height: 1, color: AppColors.divider),
          _infoRow(Icons.email_outlined, 'Email', _get('Email')),
          const Divider(height: 1, color: AppColors.divider, indent: 52),
          _infoRow(Icons.phone_outlined, 'Số điện thoại', _get('Phone')),
          const Divider(height: 1, color: AppColors.divider, indent: 52),
          _infoRow(Icons.location_on_outlined, 'Địa chỉ', _get('Location')),
          const Divider(height: 1, color: AppColors.divider, indent: 52),
          _infoRow(Icons.cake_outlined, 'Ngày sinh', _get('DateOfBirth')),
          const Divider(height: 1, color: AppColors.divider, indent: 52),
          _infoRow(Icons.wc_outlined, 'Giới tính', _get('Gender')),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryLight),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          _menuItem(Icons.luggage_outlined, 'Lịch sử đặt phòng',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const BookingHistoryScreen()))),
          const Divider(height: 1, color: AppColors.divider, indent: 52),
          _menuItem(Icons.smart_toy_outlined, 'Chatbot AI',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ChatbotScreen()))),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String label,
      {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryLight),
            const SizedBox(width: 16),
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.textPrimary))),
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildChangePasswordButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MyForgotPasswordPage(),
            ),
          );
        },
        icon: const Icon(Icons.lock_outline, color: AppColors.primaryLight, size: 20),
        label: const Text(
          'Đổi mật khẩu',
          style: TextStyle(
            color: AppColors.primaryLight,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primaryLight),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _confirmLogout,
        icon: const Icon(Icons.logout, color: Colors.red, size: 20),
        label: const Text('Đăng xuất',
            style: TextStyle(
                color: Colors.red,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 3,
      onTap: (index) {
        if (index == 0) {
          // Tìm kiếm → về BookingHomeScreen, không dùng pop để tránh về login
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const BookingHomeScreen()),
            (route) => false,
          );
        }
        if (index == 1) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const ChatbotScreen()));
        }
        if (index == 2) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(
                  builder: (_) => const BookingHistoryScreen()));
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.textSecondary,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.search), label: 'Tìm kiếm'),
        BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined), label: 'Chatbot'),
        BottomNavigationBarItem(
            icon: Icon(Icons.luggage_outlined), label: 'Đặt chỗ'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Tài khoản'),
      ],
    );
  }
}
