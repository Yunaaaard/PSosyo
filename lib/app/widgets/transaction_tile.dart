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
  });

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
    final isPending = status.toUpperCase() == 'PENDING';
    final statusColor = isPending
        ? const Color(0xFFB86A00)
        : const Color(0xFF15B66D);
    final cardBackground = isPending
        ? const LinearGradient(
            colors: <Color>[Color(0xFFFFFBF2), Color(0xFFFFF3DD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: <Color>[Colors.white, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final borderColor = isPending
        ? const Color(0xFFF1D49E)
        : const Color(0xFFF1F2F5);
    final titleColor = isPending
        ? const Color(0xFF3A2A00)
        : const Color(0xFF23232B);
    final amountColor = isPending
        ? const Color(0xFF8F5400)
        : const Color(0xFF464955);

    final double leadSize = compact ? 36 : 58;
    final double titleSize = compact ? 15 : 22;
    final double dateSize = compact ? 15 : 18;
    final double amountSize = compact ? 15 : 21;
    final double statusSize = compact ? 17 : 19;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isPending
                ? const Color(0x33D9901D)
                : Colors.black.withOpacity(0.05),
            blurRadius: isPending ? 18 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
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
              if (isPending)
                Positioned(
                  right: -3,
                  top: -3,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD9901D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateTime,
                  style: TextStyle(
                    fontSize: dateSize,
                    color: isPending
                        ? const Color(0xFF9D8658)
                        : const Color(0xFF9B9FA9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _signedPlainAmount,
                style: TextStyle(
                  fontSize: amountSize,
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPending
                      ? const Color(0xFFFFE7BD)
                      : const Color(0xFFE3F7EA),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: statusSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: statusColor,
                  ),
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
          return Image.asset(
            _fallbackAsset,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.image_not_supported_outlined,
                color: Color(0xFFB8BCC7),
              );
            },
          );
        },
      );
    }

    return Image.asset(
      logoAsset,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return Image.asset(
          _fallbackAsset,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return const Icon(
              Icons.image_not_supported_outlined,
              color: Color(0xFFB8BCC7),
            );
          },
        );
      },
    );
  }
}
