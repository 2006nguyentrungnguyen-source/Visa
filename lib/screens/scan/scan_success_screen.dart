import 'dart:math';
import 'package:flutter/material.dart';

import '../../services/scan_history_store.dart';
import '../../services/notification_store.dart';

class ScanSuccessScreen extends StatefulWidget {
  const ScanSuccessScreen({super.key});

  @override
  State<ScanSuccessScreen> createState() => _ScanSuccessScreenState();
}

class _ScanSuccessScreenState extends State<ScanSuccessScreen> {
  static const Color primaryColor = Color(0xFF1C7A6B);
  static const Color bgColor = Colors.white;
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textGray = Color(0xFF8E8E93);

  static const String _cardType = 'MIFARE Classic 1K';

  // Danh sách tên mẫu để sinh ngẫu nhiên chủ thẻ khi quét (mô phỏng thẻ
  // của bất kỳ ai, không nhất thiết là người đang đăng nhập ứng dụng).
  static const List<String> _sampleNames = [
    'Nguyễn Văn An',
    'Trần Thị Bình',
    'Lê Hoàng Nam',
    'Phạm Thị Hương',
    'Hoàng Văn Đức',
    'Vũ Thị Lan',
    'Đặng Minh Tuấn',
    'Bùi Thị Mai',
    'Đỗ Văn Long',
    'Ngô Thị Thu',
    'Phan Văn Khoa',
    'Đinh Thị Ngọc',
  ];

  late final String _uid;
  late final String _scannedAt;
  late final String _holderName;
  late final DateTime _issueDate;
  late final DateTime _expiryDate;

  @override
  void initState() {
    super.initState();
    _uid = _generateUid();
    _scannedAt = _formatNow();
    _holderName = _generateHolderName();
    _issueDate = DateTime.now();
    _expiryDate = _issueDate.add(const Duration(days: 365 * 5));

    // Quét thành công -> tự động lưu ngay vào Lịch sử quét,
    // không cần chờ người dùng bấm "Lưu thông tin thẻ".
    ScanHistoryStore.add(
      ScanHistoryEntry(
        id: 'HIST_${DateTime.now().millisecondsSinceEpoch}',
        title: _cardType,
        uid: _uid,
        time: _scannedAt,
        holderName: _holderName,
        issueDate: _issueDate,
        expiryDate: _expiryDate,
      ),
    );

    // Đồng thời tạo 1 thông báo trong Trang thông báo để người dùng biết
    // vừa có một lần quét thẻ thành công.
    NotificationStore.add(
      NotificationEntry(
        id: 'NOTI_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Quét thẻ thành công',
        message: 'Đã đọc $_cardType của $_holderName • Số thẻ: $_uid',
        time: _scannedAt,
      ),
    );
  }

  String _generateUid() {
    final random = Random();
    final digits = List.generate(16, (_) => random.nextInt(10)).join();
    return RegExp(r'.{1,4}').allMatches(digits).map((m) => m.group(0)).join(' ');
  }

  String _generateHolderName() {
    final random = Random();
    return _sampleNames[random.nextInt(_sampleNames.length)];
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  String _formatNow() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '${two(now.day)}/${two(now.month)}/${now.year} - ${two(hour12)}:${two(now.minute)} $ampm';
  }

  // Hàm điều hướng quay về trang chủ
  void _goToHome(BuildContext context) {
    // Xóa sạch lịch sử navigation và quay thẳng về trang chính (/main)
    Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        // NÚT MŨI TÊN QUAY LẠI CẢNH BÁO/QUAY VỀ TRANG CHỦ
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: textDark, size: 28),
          onPressed: () => _goToHome(context), // Bấm vào nhảy về Trang Chủ
        ),
        title: const Text(
          'Quét thành công',
          style: TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Icon tích xanh
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),

              const SizedBox(height: 20),

              const Text(
                'Quét thành công!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Thông tin thẻ đã được đọc, lưu vào lịch sử quét\nvà gửi thông báo cho bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: textGray),
              ),

              const SizedBox(height: 24),

              // Thẻ hiển thị thông tin chi tiết
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _InfoRow(label: 'Chủ thẻ: $_holderName'),
                    const SizedBox(height: 10),
                    _InfoRow(label: _cardType),
                    const SizedBox(height: 10),
                    _InfoRow(label: 'Số thẻ: $_uid'),
                    const SizedBox(height: 10),
                    _InfoRow(label: 'Ngày tạo thẻ: ${_formatDate(_issueDate)}'),
                    const SizedBox(height: 10),
                    _InfoRow(label: 'Ngày hết hạn: ${_formatDate(_expiryDate)}'),
                    const SizedBox(height: 10),
                    _InfoRow(label: 'Thời gian quét: $_scannedAt'),
                  ],
                ),
              ),

              const Spacer(),

              // Nút 1: Lưu thông tin thẻ -> Về trang chủ
              // (Bản ghi lịch sử đã được lưu ngay khi quét thành công ở trên,
              // nút này chỉ xác nhận và đưa người dùng về trang chủ.)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã lưu thông tin thẻ vào lịch sử!')),
                    );
                    _goToHome(context); // Lưu xong nhảy về trang chủ
                  },
                  child: const Text(
                    'Lưu thông tin thẻ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Nút 2: Quét thẻ khác -> Bấm để quay lại trang quét
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryColor, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Quay lại màn hình quét
                  },
                  child: const Text(
                    'Quét thẻ khác',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget hỗ trợ hiển thị từng dòng thông tin có hình tròn nhỏ bên trái
class _InfoRow extends StatelessWidget {
  final String label;
  const _InfoRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF1E1E1E),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}