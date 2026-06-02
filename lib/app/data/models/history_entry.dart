import 'package:p_sosyo/app/data/models/transaction_item.dart';

class HistoryEntry {
  const HistoryEntry({required this.sortKey, required this.item});

  final DateTime sortKey;
  final TransactionItem item;
}
