class LoanItemRecord {
  const LoanItemRecord({
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
}
