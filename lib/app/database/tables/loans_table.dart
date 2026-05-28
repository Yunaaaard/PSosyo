import 'dart:convert';
import 'package:p_sosyo/app/database/tables/loan_items_table.dart';
import 'package:p_sosyo/app/database/tables/users_table.dart';
import 'package:p_sosyo/app/modules/home_screen/models/loan_order.dart';
import 'package:p_sosyo/app/utils/principal_logo_resolver.dart';
import 'package:sqflite/sqflite.dart';

class LoanImportResult {
  const LoanImportResult._({
    required this.success,
    this.message,
    this.loanOrder,
  });

  factory LoanImportResult.success(LoanOrderCard order) {
    return LoanImportResult._(
      success: true,
      loanOrder: order,
    );
  }

  factory LoanImportResult.failure(String message) {
    return LoanImportResult._(
      success: false,
      message: message,
    );
  }

  final bool success;
  final String? message;
  final LoanOrderCard? loanOrder;
}

class LoansTable {
  LoansTable(
    this._database,
    this._usersTable,
    this._loanItemsTable,
  );

  final Future<Database> Function() _database;
  final UsersTable _usersTable;
  final LoanItemsTable _loanItemsTable;

  static const double _maxCreditLimit = 25000.0;

  static const String tableName = 'loans';

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE loans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        loan_id TEXT NOT NULL UNIQUE,
        user_id INTEGER,
        principal_title TEXT NOT NULL,
        principal_logo TEXT NOT NULL DEFAULT '',
        amount_due REAL NOT NULL,
        remaining_amount REAL NOT NULL,
        applied_date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'ACTIVE',
        raw_payload TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
      )
    ''');
  }

  Future<int> nextLoanSequence() async {
    final db = await _database();
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM loans');
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count + 1;
  }

  Future<List<LoanOrderCard>> loadActiveLoanOrders() async {
    final db = await _database();
    final rows = await db.query(
      tableName,
      where: 'status = ?',
      whereArgs: <Object?>['ACTIVE'],
      orderBy: 'datetime(created_at) DESC, id DESC',
    );

    return rows.map(_loanOrderFromRow).toList();
  }

  Future<bool> hasActiveLoanForPrincipal(String principalTitle) async {
    final db = await _database();
    final rows = await db.query(
      tableName,
      columns: <String>['loan_id'],
      where:
          'lower(principal_title) = ? AND status = ? AND remaining_amount > 0',
      whereArgs: <Object?>[_normalizePrincipalTitle(principalTitle), 'ACTIVE'],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<LoanImportResult> importLoanOrderFromRawJson(
    String rawJson, {
    String? userPhone,
  }) async {
    final dynamic decoded;
    try {
      decoded = jsonDecode(rawJson);
    } catch (_) {
      return LoanImportResult.failure(
          'The scanned QR payload is not valid JSON.');
    }

    if (decoded is! Map) {
      return LoanImportResult.failure(
          'The scanned QR payload is not a loan object.');
    }

    return importLoanOrderPayload(
      Map<String, dynamic>.from(decoded),
      userPhone: userPhone,
      rawPayload: rawJson,
    );
  }

  Future<LoanImportResult> importLoanOrderPayload(
    Map<String, dynamic> payload, {
    String? userPhone,
    String? rawPayload,
  }) async {
    final loanId = _stringValue(payload['loanId']);
    final principalTitle = _stringValue(payload['principalTitle']);
    final principalLogo = principalLogoUrlForTitle(principalTitle) ?? '';
    final appliedDate = DateTime.now();
    final dueDate = _dateValue(payload['dueDate']);
    final products = _productRows(payload['products']);
    final amountDue = _amountDueFromProducts(
      products,
      fallbackAmount: _doubleValue(payload['amountDue']),
    );

    if (loanId == null || loanId.isEmpty) {
      return LoanImportResult.failure(
          'Missing loanId in the scanned QR payload.');
    }
    if (principalTitle == null || principalTitle.isEmpty) {
      return LoanImportResult.failure(
          'Missing principalTitle in the scanned QR payload.');
    }
    if (amountDue == null || amountDue <= 0) {
      return LoanImportResult.failure(
          'Missing or invalid amountDue in the scanned QR payload.');
    }
    if (dueDate == null) {
      return LoanImportResult.failure(
          'Missing dueDate in the scanned QR payload.');
    }

    final db = await _database();
    final normalizedPrincipalTitle = _normalizePrincipalTitle(principalTitle);

    final activeBalance = await _activeOutstandingBalance(db);
    final availableCredit =
        (_maxCreditLimit - activeBalance).clamp(0, _maxCreditLimit).toDouble();
    if (amountDue > availableCredit + 0.0001) {
      return LoanImportResult.failure(
        'Loan amount exceeds the remaining credit limit of ₱${availableCredit.toStringAsFixed(2)}.',
      );
    }

    final activePrincipalRows = await db.query(
      tableName,
      columns: <String>['loan_id'],
      where:
          'lower(principal_title) = ? AND status = ? AND remaining_amount > 0',
      whereArgs: <Object?>[normalizedPrincipalTitle, 'ACTIVE'],
      limit: 1,
    );
    if (activePrincipalRows.isNotEmpty) {
      return LoanImportResult.failure(
        'You already have an active balance for $principalTitle. Pay it first before scanning another QR for the same principal.',
      );
    }

    final duplicateLoanRows = await db.query(
      tableName,
      columns: <String>['loan_id'],
      where: 'loan_id = ?',
      whereArgs: <Object?>[loanId],
      limit: 1,
    );
    if (duplicateLoanRows.isNotEmpty) {
      return LoanImportResult.failure(
        'This loan QR already exists in the local database.',
      );
    }

    final userId = await _usersTable.resolveUserId(phoneNumber: userPhone);
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await txn.insert(
        tableName,
        <String, Object?>{
          'loan_id': loanId,
          'user_id': userId,
          'principal_title': principalTitle,
          'amount_due': amountDue,
          'remaining_amount': amountDue,
          'applied_date': appliedDate.toIso8601String(),
          'due_date': dueDate.toIso8601String(),
          'status': 'ACTIVE',
          'raw_payload': rawPayload ?? jsonEncode(payload),
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      await _loanItemsTable.replaceLoanItemsInTransaction(
          txn, loanId, products);
    });

    return LoanImportResult.success(
      LoanOrderCard(
        title: principalTitle,
        loanId: loanId,
        logoAsset: principalLogo,
        appliedAt: appliedDate,
        dueAt: dueDate,
        originalAmount: amountDue,
        remainingAmount: amountDue,
      ),
    );
  }

  Future<void> saveLoanOrderCard(
    LoanOrderCard card, {
    String? userPhone,
    String? rawPayload,
    List<LoanItemRecord> loanItems = const <LoanItemRecord>[],
  }) async {
    final db = await _database();
    final now = DateTime.now().toIso8601String();
    final userId = await _usersTable.resolveUserId(phoneNumber: userPhone);

    await db.insert(
      tableName,
      <String, Object?>{
        'loan_id': card.loanId,
        'user_id': userId,
        'principal_title': card.title,
        'amount_due': card.originalAmount,
        'remaining_amount': card.remainingAmount,
        'applied_date': card.appliedAt.toIso8601String(),
        'due_date': card.dueAt.toIso8601String(),
        'status': card.remainingAmount <= 0 ? 'PAID' : 'ACTIVE',
        'raw_payload': rawPayload ?? '',
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (loanItems.isNotEmpty) {
      await _loanItemsTable.replaceLoanItems(card.loanId, loanItems);
    }
  }

  Future<void> applyLoanPayment({
    required String loanId,
    required double paidAmount,
    required double remainingAmount,
  }) async {
    final db = await _database();
    final now = DateTime.now().toIso8601String();

    if (remainingAmount <= 0) {
      await db.update(
        tableName,
        <String, Object?>{
          'remaining_amount': 0,
          'status': 'PAID',
          'updated_at': now,
        },
        where: 'loan_id = ?',
        whereArgs: <Object?>[loanId],
      );
      return;
    }

    await db.update(
      tableName,
      <String, Object?>{
        'remaining_amount': remainingAmount,
        'status': 'ACTIVE',
        'updated_at': now,
      },
      where: 'loan_id = ?',
      whereArgs: <Object?>[loanId],
    );
  }

  LoanOrderCard _loanOrderFromRow(Map<String, Object?> row) {
    final principalTitle = row['principal_title']?.toString() ?? '';
    return LoanOrderCard(
      title: principalTitle,
      loanId: row['loan_id']?.toString() ?? '',
      logoAsset: principalLogoUrlForTitle(principalTitle) ?? '',
      appliedAt: DateTime.tryParse(row['applied_date']?.toString() ?? '') ??
          DateTime.now(),
      dueAt: DateTime.tryParse(row['due_date']?.toString() ?? '') ??
          DateTime.now(),
      originalAmount: _doubleValue(row['amount_due']) ?? 0,
      remainingAmount: _doubleValue(row['remaining_amount']) ?? 0,
    );
  }

  List<LoanItemRecord> _productRows(dynamic value) {
    if (value is! List) {
      return const <LoanItemRecord>[];
    }

    return value
        .whereType<Map>()
        .map((item) {
          final map = Map<String, dynamic>.from(item);
          final unitPrice =
              _doubleValue(map['unitPrice'] ?? map['unit_price']) ?? 0;
          final quantity = _intValue(map['quantity'] ?? map['qty']) ?? 0;
          final totalPrice =
              _doubleValue(map['totalPrice'] ?? map['total_price']) ??
                  (unitPrice * quantity);

          return LoanItemRecord(
            productName: _stringValue(map['productName'] ?? map['name']) ??
                _stringValue(map['sku']) ??
                'SKU',
            sku: _stringValue(map['sku']) ?? '',
            quantity: quantity,
            unitPrice: unitPrice,
            totalPrice: totalPrice,
          );
        })
        .where((item) => item.sku.isNotEmpty || item.productName.isNotEmpty)
        .toList();
  }

  double? _amountDueFromProducts(
    List<LoanItemRecord> products, {
    double? fallbackAmount,
  }) {
    if (products.isEmpty) {
      return fallbackAmount;
    }

    final total = products.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    if (total <= 0) {
      return fallbackAmount;
    }

    return total;
  }

  String? _stringValue(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  double? _doubleValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value == null) {
      return null;
    }
    return double.tryParse(value.toString().replaceAll(',', '').trim());
  }

  int? _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value == null) {
      return null;
    }
    return int.tryParse(value.toString().trim());
  }

  DateTime? _dateValue(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return DateTime.tryParse(text);
  }

  String _normalizePrincipalTitle(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<double> _activeOutstandingBalance(Database db) async {
    final rows = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(remaining_amount), 0) AS total
      FROM loans
      WHERE status = 'ACTIVE' AND remaining_amount > 0
      ''',
    );
    final value = rows.first['total'];
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
