import 'package:flutter/foundation.dart';

/// Một lần quét thẻ NFC đã lưu vào lịch sử.
class ScanHistoryEntry {
  final String id;
  final String title; // Tên/loại thẻ đã quét
  final String uid; // Số thẻ (16 số)
  final String time; // Thời gian quét
  final String status;
  final String holderName; // Tên chủ thẻ
  final DateTime issueDate; // Ngày tạo thẻ
  final DateTime expiryDate; // Ngày hết hạn

  ScanHistoryEntry({
    required this.id,
    required this.title,
    required this.uid,
    required this.time,
    this.status = 'Thành công',
    required this.holderName,
    required this.issueDate,
    required this.expiryDate,
  });

  static String formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  String get formattedIssueDate => formatDate(issueDate);
  String get formattedExpiryDate => formatDate(expiryDate);
}

/// Kho lưu lịch sử quét dùng chung giữa màn hình Quét NFC (khi quét thành công)
/// và màn hình Lịch sử quét (hiển thị + cho phép xóa).
class ScanHistoryStore {
  ScanHistoryStore._();

  static final ValueNotifier<List<ScanHistoryEntry>> entries =
  ValueNotifier<List<ScanHistoryEntry>>([]);

  /// Thêm 1 lần quét mới lên đầu danh sách.
  static void add(ScanHistoryEntry entry) {
    entries.value = [entry, ...entries.value];
  }

  static void remove(String id) {
    entries.value = entries.value.where((e) => e.id != id).toList();
  }

  static void clear() {
    entries.value = [];
  }
}