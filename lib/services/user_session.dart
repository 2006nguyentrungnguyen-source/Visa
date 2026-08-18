import 'package:flutter/foundation.dart';

import '../screens/home/card_screens.dart';

/// Lưu trữ thông tin của người dùng hiện tại (sau khi đăng ký/đăng nhập)
/// để mọi màn hình (Trang chủ, Thẻ của tôi, Cài đặt...) đều hiển thị
/// đúng tên và thẻ thật, thay vì dữ liệu mẫu "Nguyễn Văn A".
class UserSession {
  UserSession._();

  /// Thẻ NFC chính (được tạo khi đăng ký) của người dùng hiện tại.
  static final ValueNotifier<NFCCard?> currentCard = ValueNotifier<NFCCard?>(null);

  /// Thông tin cơ bản của người dùng.
  static final ValueNotifier<String> name = ValueNotifier<String>('');
  static final ValueNotifier<String> email = ValueNotifier<String>('');
  static final ValueNotifier<String> phone = ValueNotifier<String>('');

  /// Tên hiển thị: nếu chưa có (chưa đăng nhập) thì trả về chuỗi mặc định.
  static String displayName({String fallback = 'Người dùng'}) {
    final n = name.value.trim();
    return n.isEmpty ? fallback : n;
  }

  /// Chữ cái đầu để hiển thị trong avatar tròn.
  static String initials() {
    final n = name.value.trim();
    if (n.isEmpty) return '?';
    return n[0].toUpperCase();
  }

  static void setUser({
    required String name,
    String email = '',
    String phone = '',
  }) {
    UserSession.name.value = name;
    UserSession.email.value = email;
    UserSession.phone.value = phone;
  }

  static void setCard(NFCCard card) {
    currentCard.value = card;
  }

  /// Xoá toàn bộ thông tin phiên (dùng khi đăng xuất).
  static void clear() {
    currentCard.value = null;
    name.value = '';
    email.value = '';
    phone.value = '';
  }
}