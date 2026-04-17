import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';

class UserDetailScreen extends StatefulWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late UserModel _user;
  bool _loadingDetail = true;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final fresh = await AdminApiService.fetchUserDetail(_user.id);
      if (!mounted) return;
      setState(() {
        _user = fresh;
        _loadingDetail = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingDetail = false);
    }
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
        title: const Text(
          'Thông tin Tài khoản',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: _loadingDetail
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: 20),
                  _buildContactInfoSection(),
                  const SizedBox(height: 16),
                  _buildPersonalInfoSection(),
                  if (_user.role == UserRole.user) ...[
                    const SizedBox(height: 16),
                    _buildMembershipSection(),
                  ],
                  const SizedBox(height: 24),
                  _buildDeleteButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: AppColors.white,
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: _user.avatarColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: _user.avatarColor.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                _user.initials,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _user.avatarColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _user.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _user.roleLabel,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return _card(
      title: 'Thông tin liên hệ',
      children: [
        _buildReadOnlyField(label: 'Họ và tên', value: _user.name),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          label: 'Số điện thoại',
          value: _user.phone.isEmpty ? 'Chưa cập nhật' : _user.phone,
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          label: 'Email',
          value: _user.email.isEmpty ? 'Chưa cập nhật' : _user.email,
          suffixIcon: Icons.lock_outline,
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          label: 'Địa chỉ',
          value: _user.location.isEmpty ? 'Chưa cập nhật' : _user.location,
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return _card(
      title: 'Thông tin cá nhân',
      children: [
        _buildReadOnlyField(
          label: 'Giới tính',
          value: _user.gender.isEmpty ? 'Chưa cập nhật' : _user.gender,
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          label: 'Ngày sinh',
          value: _user.dateOfBirth ?? 'Chưa cập nhật',
        ),
      ],
    );
  }

  Widget _buildMembershipSection() {
    return _card(
      title: 'Thông tin thành viên',
      children: [
        _buildReadOnlyField(
          label: 'Hạng thành viên',
          value: _user.membershipLabel,
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          label: 'Điểm tích lũy',
          value: '${_user.point} điểm',
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          label: 'Tổng chi tiêu',
          value: _user.formattedTotalSpent,
        ),
      ],
    );
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    IconData? suffixIcon,
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.textSecondary.withOpacity(0.15),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.textPrimary),
                ),
              ),
              if (suffixIcon != null)
                Icon(suffixIcon, size: 18, color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: _deleting ? null : _handleDelete,
          icon: _deleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: AppColors.danger,
                    strokeWidth: 2.5,
                  ),
                )
              : const Icon(Icons.delete_outline, size: 20),
          label: const Text(
            'Xóa tài khoản',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  void _handleDelete() {
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
                'Xóa tài khoản này?',
                style: TextStyle(
                  fontSize: 20,
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
                        text:
                            'Bạn có chắc chắn muốn xóa vĩnh viễn tài khoản của '),
                    TextSpan(
                      text: _user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '?'),
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
                            color: AppColors.textSecondary.withOpacity(0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _performDelete();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Xóa vĩnh viễn',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
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

  Future<void> _performDelete() async {
    setState(() => _deleting = true);
    try {
      await AdminApiService.deleteUser(_user.id);
      if (!mounted) return;
      Navigator.pop(context, 'deleted');
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    }
  }
}
