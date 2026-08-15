import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  // Bảng màu chính xác theo ảnh
  static const Color primaryColor = Color(0xFF006A53); // Màu xanh ngọc đậm
  static const Color bgColor = Colors.white;
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textGray = Color(0xFF757575);
  static const Color circleBg = Color(0xFFE8F2EF); // Nền xám xanh cho icon tròn

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 1. BANNER XANH LỚN
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NFC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Card Manager',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Quản lý thẻ NFC thông minh',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8), // Đã sửa ở đây
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. NÚT ĐĂNG NHẬP
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
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 3. NÚT ĐĂNG KÝ
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
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text(
                    'Đăng ký',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // 4. DANH SÁCH 4 TÍNH NĂNG
              _buildFeatureItem(
                symbol: 'A',
                title: 'Quản lý thẻ NFC an toàn',
              ),
              const SizedBox(height: 14),
              _buildFeatureItem(
                symbol: 'B',
                title: 'Quét kỹ thuật thông minh',
              ),
              const SizedBox(height: 14),
              _buildFeatureItem(
                symbol: 'C',
                title: 'Lịch sử chi tiết',
              ),
              const SizedBox(height: 14),
              _buildFeatureItem(
                symbol: 'D',
                title: 'Chia sẻ thẻ dễ dàng',
              ),

              const SizedBox(height: 32),

              // 5. PALETTE MÀU TRÒN BÊN DƯỚI
              Row(
                children: [
                  _buildColorDot(const Color(0xFF2FA89C)),
                  const SizedBox(width: 12),
                  _buildColorDot(const Color(0xFFE87EA1)),
                  const SizedBox(width: 12),
                  _buildColorDot(const Color(0xFFF3B27A)),
                  const SizedBox(width: 12),
                  _buildColorDot(Colors.white, isBorder: true),
                ],
              ),

              const SizedBox(height: 20),

              // 6. TYPOGRAPHY KÝ HIỆU "Aa"
              const Text(
                'Aa',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({required String symbol, required String title}) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: circleBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              symbol,
              style: const TextStyle(
                fontSize: 11,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildColorDot(Color color, {bool isBorder = false}) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isBorder ? Border.all(color: Colors.grey.shade400, width: 1.5) : null,
      ),
    );
  }
}