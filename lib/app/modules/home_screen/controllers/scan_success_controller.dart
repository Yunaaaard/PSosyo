import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:p_sosyo/app/database/psosyo_database_service.dart';
import 'package:p_sosyo/app/modules/home_screen/models/scan_success_receipt_model.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/services/user_phone_service.dart';

class ScanSuccessController extends GetxController {
  ScanSuccessController({
    required this.qrData,
    this.from,
    this.to,
    this.referenceNo,
    this.dateTime,
    this.amountSent = 1834.08,
  }) : receipt = ScanSuccessReceiptModel.fromQrData(
          qrData: qrData,
          from: from,
          to: to,
          referenceNo: referenceNo,
          dateTime: dateTime,
          amountSent: amountSent,
        );

  final String qrData;
  final String? from;
  final String? to;
  final String? referenceNo;
  final String? dateTime;
  final double amountSent;
  final ScanSuccessReceiptModel receipt;
  final RxString senderName = ''.obs;

  late final PsosyoDatabaseService _databaseService;
  late final UserPhoneService _userPhoneService;

  @override
  void onInit() {
    super.onInit();
    _databaseService = Get.find<PsosyoDatabaseService>();
    _userPhoneService = Get.find<UserPhoneService>();
    senderName.value = from?.trim().isNotEmpty == true ? from!.trim() : 'Psosyo User';
    _loadLocalSenderName();
  }

  Future<void> _loadLocalSenderName() async {
    var registeredPhone = _userPhoneService.getRegisteredPhone();
    if (registeredPhone.isEmpty) {
      registeredPhone = (await _databaseService.loadLatestRegisteredPhone()) ?? '';
      if (registeredPhone.isNotEmpty) {
        _userPhoneService.setRegisteredPhone(registeredPhone);
      }
    }
    final localName = await _databaseService.loadUserFullName(phoneNumber: registeredPhone);
    if (localName != null && localName.trim().isNotEmpty) {
      senderName.value = localName.trim();
    }
  }

  String get loanId => receipt.loanId;

  String get recipientName => receipt.principalTitle;

  String get principalLogo => receipt.principalLogo;

  double get amountDueFromQr => receipt.amountDueFromQr;

  String get appliedDate => receipt.appliedDate;

  String get dueDate => receipt.dueDate;

  List<dynamic>? get products => receipt.products;

  String get formattedAppliedDate {
    if (appliedDate.isEmpty) {
      return '';
    }

    try {
      return DateFormat('MM-dd-yy').format(DateTime.parse(appliedDate));
    } catch (_) {
      return appliedDate;
    }
  }

  String get formattedDueDate {
    if (dueDate.isEmpty) {
      return '';
    }

    try {
      return DateFormat('MM-dd-yy').format(DateTime.parse(dueDate));
    } catch (_) {
      return dueDate;
    }
  }

  String get formattedDateTime {
    final String? value = dateTime;
    if (value == null || value.isEmpty) {
      return DateFormat('MM-dd-yy | HH:mm').format(DateTime.now());
    }

    final DateTime? parsed = DateTime.tryParse(value);
    return parsed != null ? DateFormat('MM-dd-yy | HH:mm').format(parsed) : value;
  }

  String get displayReferenceNo => formatReferenceNo(referenceNo ?? qrData);

  String formatReferenceNo(String value) {
    final Uri? uri = Uri.tryParse(value);
    final String? queryReference = _referenceFromUri(uri);
    final String source = queryReference ?? value;
    final String digitsOnly = source.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return value;
    }

    final Iterable<String> chunks = RegExp(r'.{1,4}')
        .allMatches(digitsOnly)
        .map((Match match) => match.group(0) ?? '');
    return chunks.join(' ');
  }

  String? _referenceFromUri(Uri? uri) {
    if (uri == null) {
      return null;
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return null;
    }

    for (final String key in <String>['referenceNo', 'refNo', 'ref', 'orderId', 'id']) {
      final String? value = uri.queryParameters[key];
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    final String pathDigits = uri.path.replaceAll(RegExp(r'[^0-9]'), '');
    if (pathDigits.isNotEmpty) {
      return pathDigits;
    }

    final String queryDigits = uri.query.replaceAll(RegExp(r'[^0-9]'), '');
    if (queryDigits.isNotEmpty) {
      return queryDigits;
    }

    return null;
  }

  String formatMoney(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match.group(1)},',
        );
  }

  void goHome() {
    Get.offNamed(AppRoutes.homeScreen);
  }
}
