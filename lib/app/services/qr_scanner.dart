import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p_sosyo/app/services/qr_capture_camera_page.dart';
import 'package:p_sosyo/app/modules/home_screen/controllers/home_controller.dart';
import 'package:p_sosyo/app/services/id_scan_service.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool _scanning = false;
  String? _result;

  Future<void> _startScan() async {
    // Open camera capture page (returns XFile)
    final xfile = await Get.to<XFile?>(() => const QrCaptureCameraPage());
    if (xfile == null) {
      // user cancelled
      if (mounted) Get.back();
      return;
    }

    setState(() {
      _scanning = true;
      _result = null;
    });

    final service = IdScanService();
    final raw = await service.readQrRaw(xfile);

    if (raw == null) {
      setState(() {
        _scanning = false;
        _result = 'No QR detected';
      });
      return;
    }

    setState(() {
      _scanning = false;
      _result = raw;
    });

    // Try parse JSON payload
    try {
      final decoded = json.decode(raw);
      if (decoded is Map && decoded['loanId'] != null) {
        final loanId = decoded['loanId'].toString();
        final amountStr = decoded['amount']?.toString();

        final controller = Get.find<HomeController>();
        final order = controller.activeLoanOrder;
        if (order != null && order.loanId == loanId) {
          final amount = amountStr != null && amountStr.isNotEmpty
              ? double.tryParse(amountStr.replaceAll(',', '').replaceAll('₱', '').replaceAll(' ', ''))
              : order.remainingAmount;

          controller.recordLoanPaymentSuccess(order: order, amount: amount ?? order.remainingAmount);
          Get.snackbar('Payment Success', 'Loan payment was recorded.', snackPosition: SnackPosition.BOTTOM);
          Get.back();
          return;
        } else {
          Get.snackbar('Invalid QR', 'Scanned QR does not match active loan.', snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        Get.snackbar('Invalid QR', 'QR payload is not recognized.', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      // Not JSON — try simple match
      final controller = Get.find<HomeController>();
      final order = controller.activeLoanOrder;
      if (order != null && raw.contains(order.loanId)) {
        controller.recordLoanPaymentSuccess(order: order, amount: order.remainingAmount);
        Get.snackbar('Payment Success', 'Loan payment was recorded.', snackPosition: SnackPosition.BOTTOM);
        Get.back();
        return;
      }

      Get.snackbar('Scan Result', 'Scanned: $raw', snackPosition: SnackPosition.BOTTOM);
    }
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
        child: _scanning
            ? const CircularProgressIndicator()
            : _result == null
                ? const Text('Ready to scan', style: TextStyle(color: Colors.white))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Result: $_result', style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _startScan,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
