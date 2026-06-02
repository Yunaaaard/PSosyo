import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/data/services/qr_payment_live_scanner.dart';
import 'package:p_sosyo/app/modules/home_screen/controllers/home_controller.dart';
import 'package:p_sosyo/app/modules/home_screen/pages/scan_success_page.dart';
import 'package:p_sosyo/app/modules/home_screen/bindings/scan_success_binding.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool _scanning = false;

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

    final controller = Get.find<HomeController>();
    final imported = await controller.importLoanOrderFromQrPayload(raw);
    if (imported) {
      final selectedAmount = controller.selectedLoanOrder.value?.originalAmount ??
          controller.activeLoanOrder?.originalAmount ??
          0.0;
      // Navigate to receipt page with success binding
      await Get.to(
        () => const ScanSuccessPage(),
        binding: ScanSuccessBinding(),
        arguments: {
          'qrData': raw,
          'from': 'PSosyo User',
          'to': 'PSosyo Service',
          'referenceNo': _extractReferenceNo(raw),
          'dateTime': null,
          'amountSent': selectedAmount,
        },
      );
      return;
    }

    final retry = await _showFailureModal(
      'The scanned loan could not be imported.',
    );
    if (retry && mounted) {
      await _startScan();
    }
  }

  String _extractReferenceNo(String qrData) {
    try {
      final uri = Uri.tryParse(qrData);
      if (uri != null) {
        for (final key in ['referenceNo', 'refNo', 'ref', 'orderId', 'id']) {
          final value = uri.queryParameters[key];
          if (value != null && value.isNotEmpty) {
            return value;
          }
        }
      }
    } catch (_) {}
    return qrData;
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
