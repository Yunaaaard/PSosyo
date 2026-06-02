class TransactionItem {
  const TransactionItem({
    required this.title,
    required this.dateTime,
    required this.amount,
    required this.sign,
    required this.status,
    required this.logoAsset,
  });

  final String title;
  final String dateTime;
  final String amount;
  final String sign;
  final String status;
  final String logoAsset;
}
