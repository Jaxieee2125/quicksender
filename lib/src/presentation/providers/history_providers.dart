// trong file history_providers.dart
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quicksender/src/data/database/app_database.dart';
import 'package:quicksender/src/presentation/providers/database_providers.dart';

// Provider này sẽ cung cấp một Stream danh sách các mục lịch sử
final transferHistoryProvider = StreamProvider<List<TransferHistoryData>>((ref) {
  final db = ref.watch(databaseProvider);
  // Lắng nghe sự thay đổi của bảng transferHistory và sắp xếp theo ngày tạo mới nhất
  return (db.select(db.transferHistory)
        ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
      .watch();
});