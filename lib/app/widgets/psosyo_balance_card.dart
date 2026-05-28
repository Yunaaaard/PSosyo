import 'package:flutter/material.dart';
import 'package:p_sosyo/app/utils/peso_formatter.dart';
import 'package:p_sosyo/app/widgets/dashed_line.dart';

class PsosyoBalanceCard extends StatelessWidget {
  const PsosyoBalanceCard({
    super.key,
    required this.title,
    required this.loanId,
    required this.logoAsset,
    required this.appliedDateTime,
    required this.dueDateTime,
    required this.amountDue,
    required this.onPayNow,
  });

  final String title;
  final String loanId;
  final String logoAsset;
  final String appliedDateTime;
  final String dueDateTime;
  final String amountDue;
  final VoidCallback onPayNow;

  static const String _fallbackAsset = 'assets/images/PSosyo-Logo.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: _buildLogoImage(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF202029),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loanId,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9397A2),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9397A2),
                        fontFamily: 'Poppins',
                      ),
                      children: [
                        const TextSpan(text: 'Applied:  '),
                        TextSpan(
                          text: appliedDateTime,
                          style: const TextStyle(
                            color: Color(0xFF7D818D),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9397A2),
                        fontFamily: 'Poppins',
                      ),
                      children: [
                        const TextSpan(text: 'Due:  '),
                        TextSpan(
                          text: dueDateTime,
                          style: const TextStyle(
                              color: Color(0xFFFF4D4F), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const DashedLine(),
          const SizedBox(height: 14),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Amount Due:',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9A9DA7),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  PesoFormatter.buildPesoText(
                    amount: amountDue,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF6B3DF0),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 200,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B3DF0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: onPayNow,
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
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
    final asset = logoAsset.trim();
    if (asset.isEmpty) {
      return Image.asset(_fallbackAsset, fit: BoxFit.contain);
    }

    final uri = Uri.tryParse(asset);
    final isNetworkLogo =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    if (isNetworkLogo) {
      return Image.network(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return Image.asset(_fallbackAsset, fit: BoxFit.contain);
        },
      );
    }

    return Image.asset(
      asset,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return Image.asset(_fallbackAsset, fit: BoxFit.contain);
      },
    );
  }
}
