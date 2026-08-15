import '../screens/card_screens.dart';

/// Thông tin một tài khoản đã đăng ký (lưu tạm trong bộ nhớ ứng dụng).
class AuthAccount {
  final String name;
  final String email;
  final String phone;
  final String password;
  final NFCCard card;

  AuthAccount({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.card,
  });
}

/// Kho lưu tài khoản đơn giản để bắt người dùng phải đăng nhập lại
/// sau khi đăng ký, thay vì tự động vào thẳng Trang chủ.
class AuthStore {
  AuthStore._();

  static final Map<String, AuthAccount> _accounts = {};

  static String _key(String email) => email.trim().toLowerCase();

  static void register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required NFCCard card,
  }) {
    _accounts[_key(email)] = AuthAccount(
      name: name,
      email: email,
      phone: phone,
      password: password,
      card: card,
    );
  }

  /// Trả về tài khoản nếu email + mật khẩu khớp, ngược lại trả về null.
  static AuthAccount? validate(String email, String password) {
    final account = _accounts[_key(email)];
    if (account != null && account.password == password) {
      return account;
    }
    return null;
  }

  static bool exists(String email) => _accounts.containsKey(_key(email));
}