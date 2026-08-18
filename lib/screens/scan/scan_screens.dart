import 'package:flutter/material.dart';

import '../../services/scan_history_store.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const Color primaryColor = Color(0xFF1C7A6B);
  static const Color cardBg = Color(0xFFF4F6F6);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textGray = Color(0xFF8E8E93);

  void _confirmDeleteEntry(BuildContext context, ScanHistoryEntry entry) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa lịch sử?'),
        content: Text('Xóa lần quét "${entry.title}" khỏi lịch sử?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              ScanHistoryStore.remove(entry.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa khỏi lịch sử!')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    if (ScanHistoryStore.entries.value.isEmpty) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa tất cả lịch sử?'),
        content: const Text('Toàn bộ lịch sử quét sẽ bị xóa và không thể khôi phục.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              ScanHistoryStore.clear();
            },
            child: const Text('Xóa tất cả', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, ScanHistoryEntry entry) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Chi tiết ${entry.title}'),
        content: Text(
          'Chủ thẻ: ${entry.holderName}\n'
              'Số thẻ: ${entry.uid}\n'
              'Ngày tạo thẻ: ${entry.formattedIssueDate}\n'
              'Ngày hết hạn: ${entry.formattedExpiryDate}\n'
              'Thời gian quét: ${entry.time}\n'
              'Trạng thái: ${entry.status}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _confirmDeleteEntry(context, entry);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lịch sử quét', style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          ValueListenableBuilder<List<ScanHistoryEntry>>(
            valueListenable: ScanHistoryStore.entries,
            builder: (context, history, _) {
              if (history.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined, color: textGray),
                tooltip: 'Xóa tất cả',
                onPressed: () => _confirmClearAll(context),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<ScanHistoryEntry>>(
        valueListenable: ScanHistoryStore.entries,
        builder: (context, history, _) {
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: textGray.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  const Text(
                    'Chưa có lịch sử quét nào',
                    style: TextStyle(fontSize: 16, color: textGray, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Quét một thẻ NFC để xem lịch sử ở đây.',
                    style: TextStyle(fontSize: 12, color: textGray),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = history[index];
              return Dismissible(
                key: ValueKey(entry.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) => ScanHistoryStore.remove(entry.id),
                child: GestureDetector(
                  onTap: () => _openDetail(context, entry),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.history, color: primaryColor, size: 24),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Đã đọc ${entry.title}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.time,
                                style: const TextStyle(fontSize: 12, color: textGray),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          entry.status,
                          style: const TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: textGray, size: 20),
                          onPressed: () => _confirmDeleteEntry(context, entry),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Xóa',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}