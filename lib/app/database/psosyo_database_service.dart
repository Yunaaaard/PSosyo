import 'package:get/get.dart';
import 'package:p_sosyo/app/database/psosyo_db_helper.dart';
import 'package:p_sosyo/app/database/tables/loan_items_table.dart';
import 'package:p_sosyo/app/database/tables/loans_table.dart';
import 'package:p_sosyo/app/database/tables/payment_requests_table.dart';
import 'package:p_sosyo/app/database/tables/users_table.dart';
import 'package:p_sosyo/app/modules/home_screen/models/loan_order.dart';

class PsosyoDatabaseService extends GetxService {
  final PsosyoDbHelper _dbHelper = PsosyoDbHelper();

  late final UsersTable usersTable;
  late final LoanItemsTable loanItemsTable;
  late final LoansTable loansTable;
  late final PaymentRequestsTable paymentRequestsTable;

  Future<PsosyoDatabaseService> init() async {
    await _dbHelper.database;
    usersTable = UsersTable(() => _dbHelper.database);
    loanItemsTable = LoanItemsTable(() => _dbHelper.database);
    loansTable =
        LoansTable(() => _dbHelper.database, usersTable, loanItemsTable);
    paymentRequestsTable = PaymentRequestsTable(() => _dbHelper.database);
    return this;
  }

  Future<int> nextLoanSequence() => loansTable.nextLoanSequence();

  Future<List<LoanOrderCard>> loadActiveLoanOrders() =>
      loansTable.loadActiveLoanOrders();

  Future<bool> hasActiveLoanForPrincipal(String principalTitle) =>
      loansTable.hasActiveLoanForPrincipal(principalTitle);

  Future<LoanImportResult> importLoanOrderFromRawJson(
    String rawJson, {
    String? userPhone,
  }) =>
      loansTable.importLoanOrderFromRawJson(
        rawJson,
        userPhone: userPhone,
      );

  Future<LoanImportResult> importLoanOrderPayload(
    Map<String, dynamic> payload, {
    String? userPhone,
    String? rawPayload,
  }) =>
      loansTable.importLoanOrderPayload(
        payload,
        userPhone: userPhone,
        rawPayload: rawPayload,
      );

  Future<void> saveLoanOrderCard(
    LoanOrderCard card, {
    String? userPhone,
    String? rawPayload,
    List<LoanItemRecord> loanItems = const <LoanItemRecord>[],
  }) =>
      loansTable.saveLoanOrderCard(
        card,
        userPhone: userPhone,
        rawPayload: rawPayload,
        loanItems: loanItems,
      );

  Future<void> applyLoanPayment({
    required String loanId,
    required double paidAmount,
    required double remainingAmount,
  }) =>
      loansTable.applyLoanPayment(
        loanId: loanId,
        paidAmount: paidAmount,
        remainingAmount: remainingAmount,
      );

  Future<List<LoanItemRecord>> loadLoanItemsForLoan(String loanId) =>
      loanItemsTable.loadLoanItemsForLoan(loanId);

  Future<void> saveUserProfile({
    String? phoneNumber,
    required String fullName,
    required String email,
    required String dateOfBirth,
    required String status,
    required String gender,
    required String street,
    required String postalCode,
    required String city,
    required String country,
  }) =>
      usersTable.saveUserProfile(
        phoneNumber: phoneNumber,
        fullName: fullName,
        email: email,
        dateOfBirth: dateOfBirth,
        status: status,
        gender: gender,
        street: street,
        postalCode: postalCode,
        city: city,
        country: country,
      );

  Future<void> saveRegisteredPhone(String phoneNumber) =>
      usersTable.saveRegisteredPhone(phoneNumber);

  Future<void> savePaymentRequest(Map<String, dynamic> payload,
          {String? loanId}) =>
      paymentRequestsTable.savePaymentRequest(payload, loanId: loanId);
}
