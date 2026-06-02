class ReceiptOcrResult {
  const ReceiptOcrResult({
    this.referenceNumber,
    this.phoneNumber,
    this.amount,
  });

  final String? referenceNumber;
  final String? phoneNumber;
  final double? amount;
}
