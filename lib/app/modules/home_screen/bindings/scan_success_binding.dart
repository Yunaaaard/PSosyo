import 'package:get/get.dart';
import '../controllers/scan_success_controller.dart';

class ScanSuccessBinding extends Bindings {
  @override
  void dependencies() {
    final dynamic args = Get.arguments;

    String qrData = '';
    String? from;
    String? to;
    String? referenceNo;
    String? dateTime;
    double amountSent = 0.0;

    if (args is Map<String, dynamic>) {
      qrData = args['qrData'] as String? ?? qrData;
      from = args['from'] as String?;
      to = args['to'] as String?;
      referenceNo = args['referenceNo'] as String?;
      dateTime = args['dateTime'] as String?;
      amountSent = args['amountSent'] as double? ?? 0.0;
    } else if (args is String) {
      qrData = args;
    }

    Get.put(
      ScanSuccessController(
        qrData: qrData,
        from: from,
        to: to,
        referenceNo: referenceNo,
        dateTime: dateTime,
        amountSent: amountSent,
      ),
    );
  }
}
