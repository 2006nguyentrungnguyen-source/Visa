import 'package:flutter/material.dart';

// Import đầy đủ các trang thực tế vào đây
import 'home_screen.dart';
import 'card_screens.dart';
import 'scan_nfc_screen.dart';
import 'scan_screens.dart'; // Chứa HistoryScreen
import 'settings_screen.dart'; // Chứa SettingsScreen

class MainTabWrapper extends StatefulWidget {
  const MainTabWrapper({super.key});

  @override
  State<MainTabWrapper> createState() => _MainTabWrapperState();
}

class _MainTabWrapperState extends State<MainTabWrapper> {
  int _currentIndex = 0;

  void _goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Thay các chữ Text() bằng các Class Màn hình thực tế
    final List<Widget> screens = [
      HomeScreen(
        onGoToCards: () => _goToTab(1), // Bấm "Thẻ của tôi" -> mở tab Thẻ
        onGoToHistory: () => _goToTab(3), // Bấm "Lịch sử" -> mở tab Lịch sử
      ),
      const CardScreen(),      // Trang Thẻ
      const ScanNFCScreen(),   // Trang Quét
      const HistoryScreen(),   // Trang Lịch sử
      const SettingsScreen(),  // Trang Cài đặt
    ];

    return Scaffold(
      // Dùng IndexedStack để giữ trạng thái của các tab khi chuyển đổi
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1C7A6B),
        unselectedItemColor: const Color(0xFF8E8E93),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_outlined),
            activeIcon: Icon(Icons.credit_card),
            label: 'Thẻ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nfc_outlined),
            activeIcon: Icon(Icons.nfc),
            label: 'Quét',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}