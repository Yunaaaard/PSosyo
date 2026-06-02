import 'dart:convert';
import 'package:p_sosyo/app/data/database/psosyo_database_service.dart';
import 'package:p_sosyo/app/data/models/history_entry.dart';
import 'package:p_sosyo/app/data/models/transaction_item.dart';

/// Service for rebuilding and managing loan transaction history
class LoanHistoryService {
  final PsosyoDatabaseService _database;
  final String Function(double value) formatAmount;
  final String Function(DateTime date) formatDate;

  const LoanHistoryService({
    required PsosyoDatabaseService database,
    required this.formatAmount,
    required this.formatDate,
  }) : _database = database;

  /// Rebuilds transaction history from database records
  /// Returns list of transaction items sorted by date (newest first)
  /// Also returns set of loan IDs with pending payments
  Future<({
    List<TransactionItem> transactions,
    Set<String> pendingLoanIds,
  })> rebuildTransactionHistory() async {
    try {
      final loanRows = await _database.loadAllLoanOrders();
      final paymentRows = await _database.loadPaymentRequests(limit: 100);
      
      // Build map of logo assets by loan ID
      final loanLogoById = <String, String>{
        for (final loan in loanRows)
          if (loan.loanId.trim().isNotEmpty) loan.loanId.trim(): loan.logoAsset,
      };
      
      final latestStatusByLoanId = <String, String>{};
      final items = <HistoryEntry>[];

      // Add loan orders to history
      for (final loan in loanRows) {
        items.add(
          HistoryEntry(
            sortKey: loan.appliedAt,
            item: TransactionItem(
              title: 'Loan Order',
              dateTime: formatDate(loan.appliedAt),
              amount: formatAmount(loan.originalAmount),
              sign: '- ',
              status: 'SUCCESS',
              logoAsset: loan.logoAsset,
            ),
          ),
        );
      }

      // Add payment records to history
      for (final row in paymentRows) {
        final amount = double.tryParse(row['amount']?.toString() ?? '') ?? 0.0;
        final createdAt =
            DateTime.tryParse(row['created_at']?.toString() ?? '') ??
                DateTime.now();
        final loanId = row['loan_id']?.toString().trim();
        final reference = row['reference_id']?.toString();
        final status = row['status']?.toString() ?? 'SUCCESS';
        final normalizedStatus = status.trim().toUpperCase();
        
        // Track latest status per loan ID
        if (loanId != null &&
            loanId.isNotEmpty &&
            !latestStatusByLoanId.containsKey(loanId)) {
          latestStatusByLoanId[loanId] = normalizedStatus;
        }
        
        // Determine logo asset
        final logoAsset = _safeLogoAsset(
          loanId != null && loanLogoById.containsKey(loanId.trim())
              ? loanLogoById[loanId.trim()]
              : _logoAssetFromMetadata(row['metadata_json']?.toString()),
        );
        
        // Build title
        final title = (loanId != null && loanId.isNotEmpty)
            ? 'Loan Payment - $loanId'
            : (reference != null && reference.isNotEmpty)
                ? 'Payment - $reference'
                : 'Payment';

        items.add(
          HistoryEntry(
            sortKey: createdAt,
            item: TransactionItem(
              title: title,
              dateTime: formatDate(createdAt),
              amount: formatAmount(amount),
              sign: '+ ',
              status: status,
              logoAsset: logoAsset,
            ),
          ),
        );
      }

      // Sort by date (newest first)
      items.sort((a, b) => b.sortKey.compareTo(a.sortKey));
      
      // Extract pending loan IDs
      final pendingLoanIds = latestStatusByLoanId.entries
          .where((entry) => entry.value == 'PENDING')
          .map((entry) => entry.key)
          .toSet();

      return (
        transactions: items.map((entry) => entry.item).toList(),
        pendingLoanIds: pendingLoanIds,
      );
    } catch (_) {
      // Return empty results on error
      return (transactions: <TransactionItem>[], pendingLoanIds: <String>{});
    }
  }

  /// Safely converts logo asset value to non-null string
  String _safeLogoAsset(String? value) {
    return (value ?? '').trim();
  }

  /// Extracts logo asset from metadata JSON
  String? _logoAssetFromMetadata(String? metadataJson) {
    if (metadataJson == null || metadataJson.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(metadataJson);
      if (decoded is Map) {
        final value = decoded['logo_asset']?.toString().trim();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    } catch (_) {}

    return null;
  }
}
