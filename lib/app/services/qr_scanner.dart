import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/modules/home_screen/pages/successful_payment.dart';
import 'package:p_sosyo/app/modules/home_screen/models/loan_order.dart';
import 'package:p_sosyo/app/services/id_verification_service.dart';
import 'package:p_sosyo/app/services/qr_payment_live_scanner.dart';
import 'package:p_sosyo/app/modules/home_screen/controllers/home_controller.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool _scanning = false;

  Future<void> _showSuccessModal() async {
    await Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF7EE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF1EA35B),
                  size: 42,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Balance Card Added',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'The scanned QR payload was imported into your Psosyo balance list.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    if (Get.currentRoute != AppRoutes.homeScreen) {
                      Get.until((route) =>
                          route.settings.name == AppRoutes.homeScreen);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B3DF0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<bool> _showFailureModal(String message) async {
    var retry = false;
    await Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF0F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFFEA4335),
                  size: 42,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Scan Failed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        retry = true;
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF6B3DF0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(color: Color(0xFF6B3DF0)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        if (Get.currentRoute != AppRoutes.homeScreen) {
                          Get.until((route) =>
                              route.settings.name == AppRoutes.homeScreen);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B3DF0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
    return retry;
  }

  Future<void> _startScan() async {
    // Open live auto-scanner which returns a raw QR string
    setState(() {
      _scanning = true;
    });
    final raw = await Get.to<String?>(() => const QrPaymentLiveScannerPage());
    if (raw == null) {
      if (mounted) {
        Get.back();
      }
      return;
    }

    setState(() {
      _scanning = false;
    });

    final paymentPayload = _decodePaymentPayload(raw);
    if (paymentPayload != null) {
      final controller = Get.find<HomeController>();
      final activeLoan = controller.activeLoanOrder ?? controller.selectedLoanOrder.value;
      final amount = _extractPaymentAmount(paymentPayload);

      if (activeLoan != null && amount > 0) {
        controller.recordLoanPaymentSuccess(order: activeLoan, amount: amount);
      }

      final receipt = _buildReceiptFromPayload(
        paymentPayload,
        controller,
        fallbackLoanId: activeLoan?.loanId,
        amount: amount,
      );
      await Get.off(() => SuccessPaymentPage(receipt: receipt));
      return;
    }

    final controller = Get.find<HomeController>();
    final imported = controller.importLoanOrderFromQrPayload(raw);
    if (imported) {
      await _showSuccessModal();
      return;
    }

    final retry =
        await _showFailureModal('The QR code is missing required loan fields.');
    if (retry && mounted) {
      await _startScan();
    }
  }

  Map<String, dynamic>? _decodePaymentPayload(String rawPayload) {
    try {
      final decoded = jsonDecode(_normalizeJsonPayload(rawPayload));
      if (decoded is Map<String, dynamic>) {
        if (_looksLikePaymentPayload(decoded)) {
          return decoded;
        }
      } else if (decoded is Map) {
        final payload = Map<String, dynamic>.from(decoded);
        if (_looksLikePaymentPayload(payload)) {
          return payload;
        }
      }
    } catch (_) {
      final extracted = _extractJsonObject(rawPayload);
      if (extracted == null) {
        return null;
      }

      try {
        final decoded = jsonDecode(_normalizeJsonPayload(extracted));
        if (decoded is Map) {
          final payload = Map<String, dynamic>.from(decoded);
          if (_looksLikePaymentPayload(payload)) {
            return payload;
          }
        }
      } catch (_) {}
    }

    return null;
  }

  bool _looksLikePaymentPayload(Map<String, dynamic> payload) {
    return payload.containsKey('payment_method') &&
        payload.containsKey('status') &&
        payload.containsKey('payment_request_id');
  }

  double _extractPaymentAmount(Map<String, dynamic> payload) {
    final amountValue = payload['amount'];
    if (amountValue is num) {
      return amountValue.toDouble();
    }

    return double.tryParse(amountValue?.toString() ?? '') ?? 0;
  }

  PaymentReceiptData _buildReceiptFromPayload(
    Map<String, dynamic> payload,
    HomeController controller,
    {
    String? fallbackLoanId,
    required double amount,
  }
  ) {
    final metadata = payload['metadata'];
    final metadataMap = metadata is Map
        ? Map<String, dynamic>.from(metadata)
        : <String, dynamic>{};

    final customerName = _resolveCustomerName(metadataMap);
    final distributor = _resolveDistributor(payload, metadataMap);
    final referenceNumber = (fallbackLoanId ?? payload['reference_id'] ?? '').toString().trim();

    return PaymentReceiptData(
      customerName: customerName,
      distributor: distributor,
      referenceNumber: referenceNumber.isEmpty ? 'N/A' : referenceNumber,
      dateLabel: _formatCurrentDate(DateTime.now()),
      amount: amount,
    );
  }

  String _buildLoanReceiptQrPayload({
    required LoanOrderCard? loanOrder,
    required String distributor,
    required String customerName,
    required String referenceNumber,
  }) {
    final now = DateTime.now();
    final selectedLoan = loanOrder;
    final appliedDate = selectedLoan?.appliedAt ?? now;
    final dueDate = selectedLoan?.dueAt ?? now.add(const Duration(days: 30));
    final loanId = selectedLoan?.loanId ?? referenceNumber;
    final principalTitle = selectedLoan?.title ?? distributor;
    final principalLogo = _principalLogoUrl(principalTitle);
    final amountDue = selectedLoan?.remainingAmount ?? 0;

    final payload = <String, dynamic>{
      'loanId': loanId,
      'principalTitle': principalTitle,
      'principalLogo': principalLogo,
      'amountDue': amountDue,
      'appliedDate': _formatDateOnly(appliedDate),
      'dueDate': _formatDateOnly(dueDate),
      'products': _productsForPrincipal(principalTitle),
      'metadata': {
        'customer_name': customerName,
        'reference_number': referenceNumber,
        'distributor': distributor,
      },
    };

    return jsonEncode(payload);
  }

String _formatDateOnly(DateTime dateTime) {
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  final year = dateTime.year.toString();
  return '$year-$month-$day';
}

String _principalLogoUrl(String principalTitle) {
  final normalized = principalTitle.toLowerCase();
  if (normalized.contains('nestle')) {
    return 'https://example.com/logos/nestle-ph.png';
  }
  if (normalized.contains('monde')) {
    return 'https://example.com/logos/monde-nissin.png';
  }
  if (normalized.contains('nutri')) {
    return 'https://example.com/logos/nutriasia.png';
  }
  if (normalized.contains('cdo')) {
    return 'https://example.com/logos/cdo.png';
  }
  return 'https://example.com/logos/$normalized.png';
}

List<Map<String, dynamic>> _productsForPrincipal(String principalTitle) {
  final normalized = principalTitle.toLowerCase();

  if (normalized.contains('nestle')) {
    return const [
      {
        'productName': 'Nescafé Classic 200g',
        'sku': 'NSC-CLK-200',
        'quantity': 48,
        'unitPrice': 98,
        'totalPrice': 4704,
      },
      {
        'productName': 'Lucky Me! Pancit Canton 60g',
        'sku': 'LME-PCN-060',
        'quantity': 120,
        'unitPrice': 12,
        'totalPrice': 1440,
      },
      {
        'productName': 'Monde Mamon 10s',
        'sku': 'MND-MMN-010',
        'quantity': 60,
        'unitPrice': 75,
        'totalPrice': 4500,
      },
      {
        'productName': 'Nescafé 3-in-1 Original 28g x10',
        'sku': 'NSC-3N1-280',
        'quantity': 72,
        'unitPrice': 55,
        'totalPrice': 3960,
      },
      {
        'productName': 'SkyFlakes Crackers 800g',
        'sku': 'SKF-CRK-800',
        'quantity': 36,
        'unitPrice': 68,
        'totalPrice': 2448,
      },
      {
        'productName': 'Lucky Me! Supreme Bulalo 80g',
        'sku': 'LME-SUP-080',
        'quantity': 96,
        'unitPrice': 15,
        'totalPrice': 1440,
      },
    ];
  }

  if (normalized.contains('monde')) {
    return const [
      {
        'productName': 'Monde Mamon 10s',
        'sku': 'MND-MMN-010',
        'quantity': 60,
        'unitPrice': 75,
        'totalPrice': 4500,
      },
      {
        'productName': 'SkyFlakes Crackers 800g',
        'sku': 'SKF-CRK-800',
        'quantity': 36,
        'unitPrice': 68,
        'totalPrice': 2448,
      },
      {
        'productName': 'Lucky Me! Pancit Canton 60g',
        'sku': 'LME-PCN-060',
        'quantity': 120,
        'unitPrice': 12,
        'totalPrice': 1440,
      },
    ];
  }

  if (normalized.contains('nutri')) {
    return const [
      {
        'productName': 'NutriAsia Soy Sauce 1L',
        'sku': 'NUT-SOY-1000',
        'quantity': 40,
        'unitPrice': 64,
        'totalPrice': 2560,
      },
      {
        'productName': 'Datu Puti Vinegar 1L',
        'sku': 'DPU-VIN-1000',
        'quantity': 32,
        'unitPrice': 58,
        'totalPrice': 1856,
      },
    ];
  }

  return const [
    {
      'productName': 'Inventory Bundle',
      'sku': 'GEN-BUNDLE-001',
      'quantity': 1,
      'unitPrice': 0,
      'totalPrice': 0,
    },
  ];
}

  String _resolveCustomerName(Map<String, dynamic> metadata) {
    final fromPayload = metadata['customer_name']?.toString().trim();
    if (fromPayload != null && fromPayload.isNotEmpty) {
      return fromPayload;
    }

    if (Get.isRegistered<IdVerificationService>()) {
      final serviceName = Get.find<IdVerificationService>().getScannedName();
      if (serviceName != null && serviceName.isNotEmpty) {
        return serviceName;
      }
    }

    return 'Customer Name';
  }

  String _resolveDistributor(
    Map<String, dynamic> payload,
    Map<String, dynamic> metadata,
  ) {
    final fromMetadata = metadata['distributor']?.toString().trim();
    if (fromMetadata != null && fromMetadata.isNotEmpty) {
      return fromMetadata;
    }

    final direct = payload['distributor']?.toString().trim();
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }

    return 'Distributor';
  }

  String _formatCurrentDate(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final year = dateTime.year.toString().substring(2);
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month-$day-$year | $hour:$minute';
  }

  String? _extractJsonObject(String rawPayload) {
    final trimmed = rawPayload.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final fenceStripped = trimmed
        .replaceFirst(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'\s*```$'), '')
        .trim();

    if (fenceStripped.startsWith('{') && fenceStripped.endsWith('}')) {
      return fenceStripped;
    }

    final startIndex = fenceStripped.indexOf('{');
    if (startIndex == -1) {
      return null;
    }

    var depth = 0;
    for (var index = startIndex; index < fenceStripped.length; index++) {
      final char = fenceStripped[index];
      if (char == '{') {
        depth++;
      } else if (char == '}') {
        depth--;
        if (depth == 0) {
          return fenceStripped.substring(startIndex, index + 1);
        }
      }
    }

    return null;
  }

  String _normalizeJsonPayload(String rawPayload) {
    return rawPayload.replaceAll(RegExp(r',\s*([}\]])'), r'$1');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScan());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Scan QR'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_scanning) const CircularProgressIndicator(),
            const SizedBox(height: 14),
            Text(
              _scanning ? 'Importing Psosyo QR...' : 'Opening scanner...',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
