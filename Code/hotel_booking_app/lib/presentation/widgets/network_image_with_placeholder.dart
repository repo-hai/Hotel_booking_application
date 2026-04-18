import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../services/api_config.dart';

/// Widget ảnh network có placeholder loading và error đẹp.
/// Thay thế Image.network trực tiếp dùng via.placeholder.com.
class NetworkImageWithPlaceholder extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;
  final Color? placeholderColor;

  const NetworkImageWithPlaceholder({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.image_not_supported_outlined,
    this.placeholderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = url == null || url!.isEmpty;

    Widget imageWidget;

    if (isEmpty) {
      imageWidget = _buildPlaceholder();
    } else {
      String finalUrl = url!;

      // Chạy trên Android Emulator: Đổi localhost thành 10.0.2.2
      if (!kIsWeb) {
        try {
          if (Platform.isAndroid) {
            finalUrl = finalUrl.replaceAll('localhost', '10.0.2.2');
          }
        } catch (_) {}
      } else {
        // Chạy trên Flutter Web: Giải quyết lỗi CORS cho ảnh gọi từ domain bên ngoài
        // Sử dụng api proxy nội bộ thay vì corsproxy.io để tránh lỗi 403
        if (finalUrl.startsWith('http') && !finalUrl.contains('localhost')) {
          finalUrl = '${ApiConfig.baseUrl}/api/owner/proxy-image?url=${Uri.encodeComponent(finalUrl)}';
        }
      }

      imageWidget = Image.network(
        finalUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: placeholderColor ?? const Color(0xFF2E5AAC),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading image $finalUrl: $error');
          return _buildPlaceholder(error: true);
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }
    return imageWidget;
  }

  Widget _buildPlaceholder({bool error = false}) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            error ? Icons.broken_image_outlined : placeholderIcon,
            color: Colors.grey.shade400,
            size: (height != null && height! < 60) ? 20 : 36,
          ),
          if (height == null || height! >= 80)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                error ? 'Không tải được ảnh' : 'Chưa có ảnh',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
