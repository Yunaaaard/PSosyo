import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.title,
    required this.dateTime,
    required this.amount,
    required this.sign,
    required this.status,
    required this.logoAsset,
    this.compact = false,
  }) : assert(status == 'SUCCESS', 'TransactionTile only accepts SUCCESS status');

  final String title;
  final String dateTime;
  final String amount;
  final String sign;
  final String status;
  final String logoAsset;
  final bool compact;

  static const String _fallbackAsset = 'assets/images/PSosyo-Logo.png';

  String get _signedPlainAmount {
    final cleaned = amount.replaceAll(',', '').trim();
    final parsed = double.tryParse(cleaned);

    String plainAmount;
    if (parsed == null) {
      plainAmount = cleaned;
    } else if (parsed % 1 == 0) {
      plainAmount = parsed.toInt().toString();
    } else {
      plainAmount = parsed
          .toStringAsFixed(2)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    }

    return '${sign.trim()}$plainAmount';
  }

  @override
  Widget build(BuildContext context) {
    const statusColor = Color(0xFF15B66D);

    final double leadSize = compact ? 36 : 58;
    final double titleSize = compact ? 15 : 22;
    final double dateSize = compact ? 15 : 18;
    final double amountSize = compact ? 15 : 21;
    final double statusSize = compact ? 17 : 19;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: leadSize,
            height: leadSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(compact ? 9 : 12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: compact ? 5 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(compact ? 5 : 8),
            child: _buildLogoImage(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF23232B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateTime,
                  style: TextStyle(
                    fontSize: dateSize,
                    color: const Color(0xFF9B9FA9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _signedPlainAmount,
                style: TextStyle(
                  fontSize: amountSize,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF464955),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                status,
                style: TextStyle(
                  fontSize: statusSize,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoImage() {
    final uri = Uri.tryParse(logoAsset);
    final isNetworkLogo = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https');

    if (isNetworkLogo) {
      return Image.network(
        logoAsset,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFFB8BCC7),
          );
        },
      );
    }

    return Image.asset(
      logoAsset,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return const Icon(
          Icons.image_not_supported_outlined,
          color: Color(0xFFB8BCC7),
        );
      },
    );
  }
}
