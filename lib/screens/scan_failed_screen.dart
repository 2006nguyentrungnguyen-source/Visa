import 'package:flutter/material.dart';

class ScanFailedScreen extends StatelessWidget {
  const ScanFailedScreen({super.key});

  static const Color primaryColor = Color(0xFF006A53);
  static const Color errorColor = Color(0xFFE53935); // Màu đỏ báo lỗi
  static const Color bgColor = Colors.white;
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textGray = Color(0xFF8E8E93);
  static const Color cardBg = Color(0xFFFFF5F5); // Nền đỏ nhạt cảnh báo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quét thất bại',
          style: TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Icon cảnh báo lỗi đỏ
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: errorColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 44,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Quét không thành công!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Không nhận diện được thẻ NFC.\nVui lòng kiểm tra lại vị trí đặt thẻ và thử lại.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: textGray,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // Khối lưu ý khi quét thẻ
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: errorColor.withOpacity(0.2), width: 1),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nguyên nhân có thể:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: errorColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Thẻ đặt quá xa cảm biến NFC của thiết bị.', style: TextStyle(fontSize: 12, color: textDark)),
                    SizedBox(height: 4),
                    Text('• Thẻ NFC không đúng định dạng hoặc đã bị hỏng.', style: TextStyle(fontSize: 12, color: textDark)),
                    SizedBox(height: 4),
                    Text('• Thiết bị bị vướng ốp lưng quá dày.', style: TextStyle(fontSize: 12, color: textDark)),
                  ],
                ),
              ),

              const Spacer(),

              // Nút 1: Thử quét lại
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/scan_nfc');
                  },
                  child: const Text(
                    'Thử quét lại',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Nút 2: Về trang chủ
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryColor, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/main');
                  },
                  child: const Text(
                    'Về trang chủ',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}