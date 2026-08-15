import 'dart:async';
import 'package:flutter/material.dart';

class ScanNFCScreen extends StatefulWidget {
  const ScanNFCScreen({super.key});

  @override
  State<ScanNFCScreen> createState() => _ScanNFCScreenState();
}

class _ScanNFCScreenState extends State<ScanNFCScreen> {
  Timer? _timer;
  bool _isScanning = false;

  static const Color primaryColor = Color(0xFF1C7A6B);
  static const Color bgColor = Colors.white;
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textGray = Color(0xFF8E8E93);

  // Hàm kích hoạt quét (Chỉ chạy khi bấm nút)
  void _startScanning() {
    setState(() {
      _isScanning = true;
    });

    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        // Quét xong 2.5s thì chuyển sang trang thành công
        Navigator.pushNamed(context, '/scan_success');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Quét thẻ NFC',
          style: TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Vùng hiệu ứng Quét NFC
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8F2EF),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _isScanning ? Icons.nfc : Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                _isScanning
                    ? 'Đưa thẻ NFC lại gần điện thoại...'
                    : 'Chạm vào nút bên dưới để bắt đầu quét',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: textGray,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 12),

              if (_isScanning) ...[
                const Text(
                  'Đang xử lý dữ liệu...',
                  style: TextStyle(
                    fontSize: 14,
                    color: textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              ],

              const Spacer(),

              // Nút bấm Quét
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isScanning ? null : _startScanning,
                  child: Text(
                    _isScanning ? 'ĐANG QUÉT...' : 'BẮT ĐẦU QUÉT THẺ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}