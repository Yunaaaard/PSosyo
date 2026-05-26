import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
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
                'Payment Successful',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your loan payment has been recorded successfully.',
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
                      Get.until((route) => route.settings.name == AppRoutes.homeScreen);
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
                'Payment Failed',
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
                        'Scan Again',
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
                          Get.until((route) => route.settings.name == AppRoutes.homeScreen);
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

    final controller = Get.find<HomeController>();
    final order = controller.activeLoanOrder;

    // First try JSON parsing
    try {
      final decoded = json.decode(raw);
      final info = _extractLoanInfoFromPayload(decoded, raw);
      final loanId = info?['loanId']?.toString();
      final amountValue = info?['amount'];

      if (order != null && loanId != null) {
        final matches = order.loanId.toLowerCase().trim() == loanId.toLowerCase().trim() ||
            raw.toLowerCase().contains(order.loanId.toLowerCase());

        if (matches) {
          final amount = _normalizeAmountValue(amountValue) ?? order.remainingAmount;
          final processed = await controller.processPayment(
            order: order,
            amount: amount,
            allowLocalFallback: true,
          );
          if (processed) {
            if (Get.currentRoute != AppRoutes.homeScreen) {
              Get.until((route) => route.settings.name == AppRoutes.homeScreen);
            }
            Future<void>.delayed(Duration.zero, _showSuccessModal);
            return;
          }
          return;
        } else {
          final retry = await _showFailureModal('Scanned QR does not match active loan.');
          if (retry && mounted) {
            await _startScan();
          }
          return;
        }
      }

      final retry = await _showFailureModal('QR payload is not recognized.');
      if (retry && mounted) {
        await _startScan();
      }
      return;
    } catch (_) {
      // Not JSON — fallthrough to simple match
    }

    // Simple raw string fallback
    if (order != null && raw.toLowerCase().contains(order.loanId.toLowerCase())) {
      final processed = await controller.processPayment(
        order: order,
        amount: order.remainingAmount,
        allowLocalFallback: true,
      );
      if (processed) {
        await _showSuccessModal();
        return;
      }
      return;
    }
    final retry = await _showFailureModal('Scanned QR does not match active loan.');
    if (retry && mounted) {
      await _startScan();
    }
  }

  Map<String, dynamic>? _extractLoanInfoFromPayload(dynamic payload, String raw) {
    try {
      if (payload is Map) {
        String? foundLoanId;
        dynamic foundAmount;

        void searchMap(Map map) {
          map.forEach((key, value) {
            final k = key.toString().toLowerCase();
            if (foundLoanId == null && (k == 'loanid' || k == 'loan_id' || k == 'id' || k == 'loan')) {
              if (value != null) foundLoanId = value.toString();
            }
            if (foundAmount == null && (k == 'amount' || k == 'amt' || k == 'value' || k == 'total')) {
              foundAmount = value;
            }
            if (value is Map) searchMap(value);
            if (value is List) value.whereType<Map>().forEach(searchMap);
          });
        }

        searchMap(payload);

        // Fallback: regex extraction
        if (foundLoanId == null) {
          final orderGuess = RegExp(r'AL-\d{3}[A-Z]{3,}');
          final match = orderGuess.firstMatch(raw);
          if (match != null) foundLoanId = match.group(0);
        }

        if (foundLoanId != null) return {'loanId': foundLoanId, 'amount': foundAmount};
      }
    } catch (_) {}
    return null;
  }

  double? _normalizeAmountValue(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final s = value.toString();
    final cleaned = s.replaceAll(',', '').replaceAll('₱', '').replaceAll(' ', '');
    return double.tryParse(cleaned);
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
            const Text(
              'Opening scanner...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
