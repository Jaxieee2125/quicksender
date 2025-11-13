// trong file history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quicksender/src/presentation/providers/history_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(transferHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử truyền file'),
      ),
      body: historyAsync.when(
        data: (historyItems) {
          if (historyItems.isEmpty) {
            return const Center(child: Text('Chưa có lịch sử nào.'));
          }
          return ListView.builder(
            itemCount: historyItems.length,
            itemBuilder: (context, index) {
              final item = historyItems[index];
              // TODO: Tạo một widget đẹp hơn để hiển thị item
              return ListTile(
                leading: Icon(item.type == 'send' ? Icons.upload : Icons.download),
                title: Text('Tới: ${item.targetDeviceName}'),
                subtitle: Text('Trạng thái: ${item.status} - ${item.createdAt.toString()}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}