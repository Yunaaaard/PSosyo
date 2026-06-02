import 'package:p_sosyo/app/data/models/loan_order.dart';

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
