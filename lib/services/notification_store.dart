import 'package:flutter/foundation.dart';

/// Một thông báo trong Trang thông báo (vd: quét thẻ thành công).
class NotificationEntry {
  final String id;
  final String title;
  final String message;
  final String time;
  bool isRead;

  NotificationEntry({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });
}

/// Kho lưu thông báo dùng chung: nơi tạo thông báo (vd: sau khi quét thẻ
/// thành công) và Trang thông báo (hiển thị + đánh dấu đã đọc + xóa).
class NotificationStore {
  NotificationStore._();

  static final ValueNotifier<List<NotificationEntry>> entries =
  ValueNotifier<List<NotificationEntry>>([]);

  static int get unreadCount => entries.value.where((e) => !e.isRead).length;

  /// Thêm 1 thông báo mới lên đầu danh sách.
  static void add(NotificationEntry entry) {
    entries.value = [entry, ...entries.value];
  }

  static void markAsRead(String id) {
    entries.value = entries.value.map((e) {
      if (e.id == id) e.isRead = true;
      return e;
    }).toList();
  }

  static void markAllAsRead() {
    entries.value = entries.value.map((e) {
      e.isRead = true;
      return e;
    }).toList();
  }

  static void remove(String id) {
    entries.value = entries.value.where((e) => e.id != id).toList();
  }

  static void clear() {
    entries.value = [];
  }
}