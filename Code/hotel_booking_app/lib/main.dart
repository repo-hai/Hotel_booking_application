import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/admin/admin_main_screen.dart';
import 'screens/client/chatbot_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Booking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const _DevLauncher(),
    );
  }
}

/// Trang tạm để chọn vào Admin hoặc Chatbot khi dev
class _DevLauncher extends StatelessWidget {
  const _DevLauncher();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hotel, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Hotel Booking App',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 40),
            _buildButton(
              context,
              icon: Icons.admin_panel_settings,
              label: 'Trang Admin',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AdminMainScreen())),
            ),
            const SizedBox(height: 16),
            _buildButton(
              context,
              icon: Icons.smart_toy_outlined,
              label: 'Chatbot Tư vấn',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ChatbotScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 220,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label,
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
