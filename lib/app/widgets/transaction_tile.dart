import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:p_sosyo/app/utils/peso_formatter.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.title,
    required this.dateTime,
    required this.amount,
    required this.status,
    this.compact = false,
  }) : assert(status == 'SUCCESS', 'TransactionTile only accepts SUCCESS status');

  final String title;
  final String dateTime;
  final String amount;
  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    const assetName = 'assets/icons/success.svg';
    const bgColor = Color(0xFFD6F5E5);
    const statusColor = Color(0xFF15B66D);

    final double leadSize = compact ? 30 : 72;
    final double iconSize = compact ? 15 : 28;
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
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                assetName,
                width: iconSize,
                height: iconSize,
              ),
            ),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '-',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF464955),
                    ),
                  ),
                  PesoFormatter.buildPesoText(
                    amount: amount,
                    fontSize: amountSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF464955),
                  ),
                ],
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
}
