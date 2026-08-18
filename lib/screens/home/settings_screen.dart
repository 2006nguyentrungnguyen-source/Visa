import 'package:flutter/material.dart';

import '../../services/user_session.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Trạng thái các công tắc
  bool _notificationEnabled = true;
  bool _darkModeEnabled = false;

  // Bảng màu chuẩn UI trong hình
  static const Color primaryColor = Color(0xFF1C7A6B);
  static const Color groupHeaderBg = Color(0xFFF2F4F5);
  static const Color itemBg = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textMuted = Color(0xFF8E8E93);
  static const Color dangerColor = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: textDark, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // 1. THÔNG TIN NGƯỜI DÙNG
          ValueListenableBuilder<String>(
            valueListenable: UserSession.name,
            builder: (context, _, __) {
              return Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFE2ECE9),
                    child: Text(
                      UserSession.initials(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        UserSession.displayName(fallback: 'Người dùng'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        UserSession.email.value.isNotEmpty
                            ? UserSession.email.value
                            : 'Chưa cập nhật email',
                        style: const TextStyle(
                          fontSize: 13,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // 2. NHÓM 1: CHUNG
          _buildGroupHeader('Chung'),
          const SizedBox(height: 8),

          _buildSettingItem(
            title: 'Ngôn ngữ',
            onTap: () => _showDialog('Ngôn ngữ', 'Ứng dụng đang hỗ trợ mặc định Tiếng Việt.'),
          ),

          _buildSwitchItem(
            title: 'Thông báo',
            value: _notificationEnabled,
            onChanged: (val) {
              setState(() => _notificationEnabled = val);
            },
          ),

          _buildSwitchItem(
            title: 'Chế độ tối',
            value: _darkModeEnabled,
            onChanged: (val) {
              setState(() => _darkModeEnabled = val);
            },
          ),

          _buildSettingItem(
            title: 'Âm thanh quét',
            onTap: () => _showDialog('Âm thanh quét', 'Âm thanh sẽ phát mỗi khi quét thành công.'),
          ),

          const SizedBox(height: 20),

          // 3. NHÓM 2: BẢO MẬT
          _buildGroupHeader('Bảo mật'),
          const SizedBox(height: 8),

          _buildSettingItem(
            title: 'Đổi mật khẩu',
            onTap: () => _showDialog('Đổi mật khẩu', 'Vui lòng kiểm tra hộp thư email để nhận đường dẫn đặt lại mật khẩu.'),
          ),

          _buildSettingItem(
            title: 'Xác thực vân tay / Khuôn mặt',
            onTap: () => _showDialog('Sinh trắc học', 'Tính năng xác thực vân tay / FaceID đã được kích hoạt.'),
          ),

          const SizedBox(height: 24),

          // 4. NÚT ĐĂNG XUẤT
          InkWell(
            onTap: () => _showLogoutConfirm(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.logout, color: dangerColor, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Đăng xuất',
                    style: TextStyle(
                      color: dangerColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Header tiêu đề nhóm
  Widget _buildGroupHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: groupHeaderBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
      ),
    );
  }

  // Widget Dòng item thường (click mở tính năng/thông báo)
  Widget _buildSettingItem({required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: textDark, fontWeight: FontWeight.w400),
        ),
        trailing: const Icon(Icons.chevron_right, color: textMuted, size: 20),
        onTap: onTap,
      ),
    );
  }

  // Widget Dòng item có Switch công tắc
  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: textDark, fontWeight: FontWeight.w400),
        ),
        value: value,
        activeColor: primaryColor,
        onChanged: onChanged,
      ),
    );
  }

  // Dialog thông báo khi bấm vào
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  // Dialog xác nhận đăng xuất
  void _showLogoutConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: dangerColor),
            onPressed: () {
              Navigator.pop(context);
              UserSession.clear();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/register',
                    (route) => false,
              );
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}