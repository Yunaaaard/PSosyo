import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF4A4F59),
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
    );
  }
}

class FieldShell extends StatelessWidget {
  const FieldShell({super.key, required this.child, this.isFocused = false});

  final Widget child;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFocused ? const Color(0xFF6C63FF) : const Color(0xFFDADDE3),
          width: 1.5,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.10),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : [],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.subtitle,
    this.qrWidget,
  });

  final String title;
  final String amount;
  final String subtitle;
  final Widget? qrWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE3E5EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF8A909C),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8A909C),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Center(
            child: Text(
              amount,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 35,
                color: Color(0xFF25315D),
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          if (qrWidget != null) ...[
            const SizedBox(height: 14),
            Center(child: qrWidget),
          ],
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
