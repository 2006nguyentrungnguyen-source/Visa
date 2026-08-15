import 'package:flutter/material.dart';

import 'screens/register_screen.dart';
import 'screens/auth_screens.dart' show LoginScreen, ForgotPasswordScreen;
import 'screens/main_tab_wrapper.dart';
import 'screens/card_screens.dart';
import 'screens/scan_nfc_screen.dart';
import 'screens/scan_success_screen.dart';
import 'screens/scan_failed_screen.dart';
import 'screens/notifications_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NFC Card App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF1C7A6B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // BẮT ĐẦU BẰNG MÀN HÌNH ĐĂNG KÝ
      initialRoute: '/register',

      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/main': (context) => const MainTabWrapper(),
        '/scan_nfc': (context) => const ScanNFCScreen(),
        '/scan_success': (context) => const ScanSuccessScreen(),
        '/scan_failed': (context) => const ScanFailedScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/card_detail': (context) => CardDetailScreen(
          card: NFCCard(
            id: '1',
            name: 'Thẻ Quản Lý',
            type: 'MIFARE Classic 1K',
            uid: '04:A2:8B:C2',
            holderName: 'Nguyễn Văn A',
            issueDate: DateTime.now(),
            expiryDate: DateTime.now().add(const Duration(days: 365 * 5)),
          ),
        ),
        '/edit_card': (context) => const EditCardScreen(),
      },
    );
  }
}