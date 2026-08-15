import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/user_session.dart';

// Tự động chia nhóm 4 số khi người dùng gõ số thẻ (dạng 1234 5678 9012 3456)
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 16 ? digits.substring(0, 16) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      buffer.write(limited[i]);
      if ((i + 1) % 4 == 0 && i != limited.length - 1) buffer.write(' ');
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// Model dữ liệu Thẻ
class NFCCard {
  final String id;
  final String name;
  final String type;
  final String uid;
  final String holderName; // Tên chủ thẻ
  final DateTime issueDate; // Ngày tạo thẻ
  final DateTime expiryDate; // Ngày hết hạn

  NFCCard({
    required this.id,
    required this.name,
    required this.type,
    required this.uid,
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

  bool get isExpired => DateTime.now().isAfter(expiryDate);
}

class CardScreen extends StatefulWidget {
  final NFCCard? userCard;
  const CardScreen({super.key, this.userCard});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  static const Color primaryColor = Color(0xFF1C7A6B);
  static const Color cardBg = Color(0xFFF4F6F6);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textGray = Color(0xFF8E8E93);

  List<NFCCard> cards = [];
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    // Lắng nghe khi thẻ trong phiên đăng nhập thay đổi (vd: vừa đăng ký xong)
    // để danh sách luôn cập nhật đúng tên/UID thật, không cần thoát vào lại tab.
    UserSession.currentCard.addListener(_syncFromSession);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    // Ưu tiên thẻ thật của người dùng đã đăng ký (UserSession)
    final sessionCard = UserSession.currentCard.value;
    // Hoặc dữ liệu thẻ truyền vào qua Tham số (Arguments) khi điều hướng
    final argCard = ModalRoute.of(context)?.settings.arguments as NFCCard?;

    final initialCard = sessionCard ?? argCard ?? widget.userCard;
    if (initialCard != null) {
      cards = [initialCard];
      // Đảm bảo UserSession cũng có thẻ này để các màn hình khác đồng bộ
      if (sessionCard == null) {
        UserSession.setCard(initialCard);
      }
    }
  }

  void _syncFromSession() {
    final sessionCard = UserSession.currentCard.value;
    if (sessionCard == null) return;
    if (cards.isNotEmpty && cards.first.id == sessionCard.id) return;
    if (!mounted) return;
    setState(() {
      cards = [sessionCard, ...cards.where((c) => c.id != sessionCard.id)];
    });
  }

  @override
  void dispose() {
    UserSession.currentCard.removeListener(_syncFromSession);
    super.dispose();
  }

  void _deleteCard(int index) {
    final removed = cards[index];
    setState(() {
      cards.removeAt(index);
    });
    // Nếu xoá đúng thẻ chính đang lưu trong phiên thì clear luôn
    if (UserSession.currentCard.value?.id == removed.id) {
      UserSession.currentCard.value = null;
    }
  }

  String _generateNfcUid() {
    final random = Random();
    final digits = List.generate(16, (_) => random.nextInt(10)).join();
    return RegExp(r'.{1,4}').allMatches(digits).map((m) => m.group(0)).join(' ');
  }

  void _confirmDeleteCard(int index) {
    final card = cards[index];
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa thẻ?'),
        content: Text('Bạn có chắc chắn muốn xóa thẻ "${card.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteCard(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa thẻ "${card.name}"!')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDate(BuildContext ctx, DateTime initialDate) {
    return showDatePicker(
      context: ctx,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Chọn ngày',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );
  }

  void _showAddCardSheet() {
    final nameController = TextEditingController();
    final holderController = TextEditingController(
      text: UserSession.displayName(fallback: ''),
    );
    final uidController = TextEditingController();
    String selectedType = 'MIFARE Classic 1K';
    DateTime issueDate = DateTime.now();
    DateTime expiryDate = DateTime.now().add(const Duration(days: 365 * 5));
    const cardTypes = [
      'MIFARE Classic 1K',
      'MIFARE Classic 4K',
      'NTAG213',
      'NTAG215',
      'NTAG216',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thêm thẻ mới',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textDark),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên thẻ',
                        hintText: 'Ví dụ: Thẻ xe, Thẻ cơ quan...',
                        filled: true,
                        fillColor: cardBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: holderController,
                      decoration: InputDecoration(
                        labelText: 'Tên chủ thẻ',
                        hintText: 'Họ và tên chủ thẻ',
                        filled: true,
                        fillColor: cardBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: uidController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_CardNumberInputFormatter()],
                      decoration: InputDecoration(
                        labelText: 'Số thẻ (16 số)',
                        hintText: 'Ví dụ: 1234 5678 9012 3456',
                        filled: true,
                        fillColor: cardBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.autorenew, color: primaryColor, size: 20),
                          tooltip: 'Tạo số ngẫu nhiên',
                          onPressed: () {
                            uidController.text = _generateNfcUid();
                            uidController.selection = TextSelection.collapsed(offset: uidController.text.length);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Để trống nếu muốn hệ thống tự sinh số thẻ ngẫu nhiên.',
                      style: TextStyle(fontSize: 11, color: textGray),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: InputDecoration(
                        labelText: 'Loại thẻ',
                        filled: true,
                        fillColor: cardBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: cardTypes
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setSheetState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            sheetContext: sheetContext,
                            label: 'Ngày tạo thẻ',
                            value: issueDate,
                            onPicked: (picked) => setSheetState(() => issueDate = picked),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateField(
                            sheetContext: sheetContext,
                            label: 'Ngày hết hạn',
                            value: expiryDate,
                            onPicked: (picked) => setSheetState(() => expiryDate = picked),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập tên thẻ!')),
                            );
                            return;
                          }
                          final holderName = holderController.text.trim();
                          if (holderName.isEmpty) {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập tên chủ thẻ!')),
                            );
                            return;
                          }
                          if (expiryDate.isBefore(issueDate)) {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              const SnackBar(content: Text('Ngày hết hạn phải sau ngày tạo thẻ!')),
                            );
                            return;
                          }
                          String uid = uidController.text.trim();
                          if (uid.isEmpty) {
                            uid = _generateNfcUid();
                          } else {
                            final digitsOnly = uid.replaceAll(' ', '');
                            if (digitsOnly.length != 16) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(content: Text('Số thẻ phải gồm đúng 16 số!')),
                              );
                              return;
                            }
                          }
                          final newCard = NFCCard(
                            id: 'CARD_${DateTime.now().millisecondsSinceEpoch}',
                            name: name,
                            type: selectedType,
                            uid: uid,
                            holderName: holderName,
                            issueDate: issueDate,
                            expiryDate: expiryDate,
                          );
                          setState(() {
                            cards.add(newCard);
                          });
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã thêm thẻ "${newCard.name}"!')),
                          );
                        },
                        child: const Text(
                          'Thêm thẻ',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateField({
    required BuildContext sheetContext,
    required String label,
    required DateTime value,
    required ValueChanged<DateTime> onPicked,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () async {
        final picked = await _pickDate(sheetContext, value);
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: cardBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(NFCCard.formatDate(value), style: const TextStyle(fontSize: 13, color: textDark)),
            const Icon(Icons.calendar_today_outlined, size: 16, color: textGray),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Thẻ của tôi',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: primaryColor),
            tooltip: 'Thêm thẻ',
            onPressed: _showAddCardSheet,
          ),
        ],
      ),
      body: cards.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card_off_outlined, size: 64, color: textGray.withOpacity(0.5)),
            const SizedBox(height: 12),
            const Text(
              'Chưa có thẻ nào',
              style: TextStyle(fontSize: 16, color: textGray, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _showAddCardSheet,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Thêm thẻ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final card = cards[index];
          return Dismissible(
            key: ValueKey(card.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              _confirmDeleteCard(index);
              return false; // Việc xoá thật sự do _confirmDeleteCard xử lý sau khi xác nhận
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            child: GestureDetector(
              onTap: () async {
                final deletedCardId = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardDetailScreen(card: card),
                  ),
                );

                if (deletedCardId != null) {
                  final idx = cards.indexWhere((c) => c.id == deletedCardId);
                  if (idx != -1) {
                    _deleteCard(idx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã xóa thẻ của ${card.name}!')),
                      );
                    }
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.credit_card, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.name, // Hiển thị đúng tên mày vừa gõ đăng ký
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${card.type} • ID: ${card.uid}', // Mã thẻ được cấp
                            style: const TextStyle(fontSize: 12, color: textGray),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Chủ thẻ: ${card.holderName} • HSD: ${card.formattedExpiryDate}',
                            style: TextStyle(
                              fontSize: 11,
                              color: card.isExpired ? Colors.red : textGray,
                              fontWeight: card.isExpired ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: textGray),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: cards.isEmpty
          ? null
          : FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: _showAddCardSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// CHI TIẾT THẺ
class CardDetailScreen extends StatelessWidget {
  final NFCCard card;
  const CardDetailScreen({super.key, required this.card});

  static const Color primaryColor = Color(0xFF1C7A6B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(card.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(card.type, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 24),
                  Text('Số thẻ: ${card.uid}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Text('Chủ thẻ: ${card.holderName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chủ thẻ:\n${card.holderName}\n\n'
                  'Số thẻ:\n${card.uid}\n\n'
                  'Loại thẻ:\n${card.type}\n\n'
                  'Ngày tạo thẻ:\n${card.formattedIssueDate}\n\n'
                  'Ngày hết hạn:\n${card.formattedExpiryDate}${card.isExpired ? " (Đã hết hạn)" : ""}',
              style: const TextStyle(height: 1.5, fontSize: 14),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _showDeleteDialog(context),
                child: const Text('Xóa thẻ', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa thẻ?'),
        content: Text('Bạn có chắc chắn muốn xóa thẻ của "${card.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context, card.id);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class EditCardScreen extends StatelessWidget {
  const EditCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa thẻ')),
      body: const Center(child: Text('Trang chỉnh sửa')),
    );
  }
}