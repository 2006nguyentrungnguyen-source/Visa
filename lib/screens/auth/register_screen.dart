import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../home/card_screens.dart';
import '../../services/auth_store.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  static const Color primaryColor = Color(0xFF1C7A6B);
  static const Color textDark = Color(0xFF1E1E1E);

  // Hàm sinh mã thẻ ngẫu nhiên khi đăng ký
  String _generateNfcUid() {
    final random = Random();
    final digits = List.generate(16, (_) => random.nextInt(10)).join();
    return RegExp(r'.{1,4}').allMatches(digits).map((m) => m.group(0)).join(' ');
  }

  // Email: bắt buộc có cả chữ và số ở phần trước @, và phải kết thúc bằng @gmail.com
  static final RegExp _emailRegex =
  RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z0-9._%+-]+@gmail\.com$');

  // Số điện thoại: đúng 10 chữ số
  static final RegExp _phoneRegex = RegExp(r'^\d{10}$');

  // Mật khẩu: tối thiểu 6 ký tự, có ít nhất 1 chữ hoa, 1 số, 1 ký tự đặc biệt
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{}|;:,.<>?~]).{6,}$',
  );

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleRegister() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      _showSnack('Vui lòng nhập Họ và tên!');
      return;
    }

    if (email.isEmpty) {
      _showSnack('Vui lòng nhập Email!');
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      _showSnack('Email phải có cả chữ và số, và kết thúc bằng @gmail.com!');
      return;
    }

    if (phone.isEmpty) {
      _showSnack('Vui lòng nhập Số điện thoại!');
      return;
    }

    if (!_phoneRegex.hasMatch(phone)) {
      _showSnack('Số điện thoại phải gồm đúng 10 chữ số!');
      return;
    }

    if (password.isEmpty || password.length < 6) {
      _showSnack('Mật khẩu phải có ít nhất 6 ký tự!');
      return;
    }

    if (!_passwordRegex.hasMatch(password)) {
      _showSnack('Mật khẩu phải có chữ hoa, số và ký tự đặc biệt!');
      return;
    }

    if (password != confirmPassword) {
      _showSnack('Mật khẩu xác nhận không khớp!');
      return;
    }

    if (!_agreeToTerms) {
      _showSnack('Bạn cần đồng ý với điều khoản sử dụng!');
      return;
    }

    // Tạo đối tượng thẻ chính chủ với Họ tên người dùng vừa nhập
    final now = DateTime.now();
    final userCard = NFCCard(
      id: 'USER_CARD_MAIN',
      name: name,
      type: 'Thẻ Quản Lý NFC',
      uid: _generateNfcUid(),
      holderName: name,
      issueDate: now,
      expiryDate: now.add(const Duration(days: 365 * 5)), // Mặc định 5 năm, có thể chỉnh lại ở màn "Thêm thẻ"
    );

    // Lưu tài khoản (chưa đăng nhập) - người dùng phải qua màn Đăng nhập
    // và nhập đúng email/mật khẩu thì mới vào được Trang chủ.
    AuthStore.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      card: userCard,
    );

    // Chuyển sang màn Đăng nhập, mang theo email để điền sẵn
    Navigator.pushReplacementNamed(
      context,
      '/login',
      arguments: {'email': email, 'justRegistered': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Đăng ký',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark),
              ),
              const SizedBox(height: 4),
              const Text('Tạo tài khoản mới', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 24),

              // Họ và tên
              _buildInputField(
                controller: _nameController,
                label: 'Họ và tên',
                hint: 'Nhập họ và tên',
              ),
              const SizedBox(height: 16),

              // Email
              _buildInputField(
                controller: _emailController,
                label: 'Email',
                hint: 'Ví dụ: nguyenvana123@gmail.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Số điện thoại
              _buildInputField(
                controller: _phoneController,
                label: 'Số điện thoại',
                hint: 'Nhập đúng 10 chữ số',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
              const SizedBox(height: 16),

              // Mật khẩu
              _buildInputField(
                controller: _passwordController,
                label: 'Mật khẩu',
                hint: 'Ít nhất 6 ký tự, có chữ hoa, số, ký tự đặc biệt',
                isPassword: true,
                obscureText: _obscurePassword,
                onToggleVisibility: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              const SizedBox(height: 16),

              // Xác nhận mật khẩu
              _buildInputField(
                controller: _confirmPasswordController,
                label: 'Xác nhận mật khẩu',
                hint: 'Xác nhận mật khẩu',
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
              const SizedBox(height: 12),

              // Checkbox Điều khoản
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreeToTerms,
                      activeColor: primaryColor,
                      onChanged: (val) {
                        setState(() => _agreeToTerms = val ?? false);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Tôi đồng ý với ', style: TextStyle(fontSize: 13)),
                  const Text(
                    'điều khoản sử dụng',
                    style: TextStyle(fontSize: 13, color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nút Đăng ký
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _handleRegister,
                  child: const Text(
                    'Đăng ký',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Chuyển sang Đăng nhập
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản? ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: onToggleVisibility,
            )
                : null,
          ),
        ),
      ],
    );
  }
}