import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/user_session.dart';
import '../../services/notification_store.dart';
import '../notification/notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onGoToCards;
  final VoidCallback? onGoToHistory;

  const HomeScreen({super.key, this.onGoToCards, this.onGoToHistory});

  // Bảng màu chuẩn tuyệt đối theo thiết kế ảnh
  static const Color primaryColor = Color(0xFF1C7A6B); // Màu xanh ngọc lục bảo đặc trưng
  static const Color bgColor = Colors.white;
  static const Color searchBg = Color(0xFFF1F3F4);
  static const Color btnBg = Color(0xFFF4F6F6);
  static const Color cardBg = Color(0xFFF4F6F6);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textGray = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER (Xin chào, <tên thật đã đăng ký> + Chuông vàng + Avatar xanh)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Xin chào,',
                        style: TextStyle(
                          fontSize: 13,
                          color: textGray,
                        ),
                      ),
                      const SizedBox(height: 2),
                      ValueListenableBuilder<String>(
                        valueListenable: UserSession.name,
                        builder: (context, _, __) {
                          return Text(
                            UserSession.displayName(fallback: 'Bạn'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Icon chuông màu vàng -> mở Trang thông báo
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                          );
                        },
                        child: ValueListenableBuilder<List<NotificationEntry>>(
                          valueListenable: NotificationStore.entries,
                          builder: (context, list, _) {
                            final unread = list.where((e) => !e.isRead).length;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(
                                  Icons.notifications,
                                  color: Color(0xFFD4A300),
                                  size: 24,
                                ),
                                if (unread > 0)
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                      child: Text(
                                        unread > 9 ? '9+' : '$unread',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Avatar tròn màu xanh ngọc hiển thị chữ cái đầu tên người dùng
                      ValueListenableBuilder<String>(
                        valueListenable: UserSession.name,
                        builder: (context, _, __) {
                          return Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              UserSession.initials(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 2. SEARCH BAR (Tìm kiếm thẻ...)
              Container(
                width: double.infinity,
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: searchBg,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: textGray, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Tìm kiếm thẻ...',
                      style: TextStyle(
                        color: textGray,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. BANNER CARD (A New Way To Travel - Khám phá thẻ NFC)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'A New Way\nTo Travel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Khám phá thẻ NFC',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8), // Đã sửa lỗi ở đây
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. THAO TÁC NHANH (4 nút)
              const Text(
                'Thao tác nhanh',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAction(
                    icon: Icons.adjust,
                    label: 'Quét thẻ',
                    onTap: () => Navigator.pushNamed(context, '/scan_nfc'),
                  ),
                  _buildQuickAction(
                    icon: Icons.article_outlined,
                    label: 'Thẻ của tôi',
                    onTap: onGoToCards ?? () {},
                  ),
                  _buildQuickAction(
                    icon: Icons.access_time,
                    label: 'Lịch sử',
                    onTap: onGoToHistory ?? () {},
                  ),
                  _buildQuickAction(
                    icon: Icons.north_east,
                    label: 'Chia sẻ',
                    onTap: () => _shareCardInfo(context),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 5. THẺ GẦN ĐÂY (Có tiêu đề + Xem tất cả) - hiển thị đúng thẻ thật
              // đang có trong phiên đăng nhập (khớp với dữ liệu nút "Chia sẻ" dùng).
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thẻ gần đây',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: onGoToCards ?? () {},
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ValueListenableBuilder(
                valueListenable: UserSession.currentCard,
                builder: (context, card, _) {
                  if (card == null) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.credit_card_off_outlined, size: 32, color: textGray.withValues(alpha: 0.6)),
                          const SizedBox(height: 8),
                          const Text(
                            'Bạn chưa có thẻ nào',
                            style: TextStyle(fontSize: 13, color: textGray, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Quét hoặc thêm một thẻ để bắt đầu.',
                            style: TextStyle(fontSize: 11, color: textGray.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildRecentCardItem(title: card.name, type: card.type);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Chia sẻ thông tin thẻ NFC hiện tại qua bảng chia sẻ của hệ điều hành
  // (SMS, Zalo, Email, Messenger...). Cần package share_plus trong pubspec.yaml.
  void _shareCardInfo(BuildContext context) {
    final card = UserSession.currentCard.value;

    if (card == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn chưa có thẻ nào để chia sẻ. Hãy quét hoặc thêm một thẻ trước!'),
        ),
      );
      return;
    }

    final text = '📇 Thông tin thẻ NFC\n'
        'Chủ thẻ: ${card.holderName}\n'
        'Tên thẻ: ${card.name}\n'
        'Loại thẻ: ${card.type}\n'
        'Số thẻ: ${card.uid}\n'
        'Ngày tạo thẻ: ${card.formattedIssueDate}\n'
        'Ngày hết hạn: ${card.formattedExpiryDate}\n\n'
        'Được chia sẻ từ NFC Card Manager';

    Share.share(text, subject: 'Thông tin thẻ NFC của tôi');
  }

  // Widget Nút thao tác nhanh
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 68,
            height: 56,
            decoration: BoxDecoration(
              color: btnBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: textDark.withValues(alpha: 0.75),
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Widget Dòng Thẻ gần đây
  Widget _buildRecentCardItem({required String title, required String type}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Khối icon vuông màu xanh ngọc
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                type,
                style: const TextStyle(
                  fontSize: 11,
                  color: textGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}