import 'package:flutter/material.dart';

class InstructionCard extends StatelessWidget {
  final String message;
  final bool isSuccess;
  final bool isError;
  final bool showRetry;
  final VoidCallback? onRetry;

  const InstructionCard({
    required this.message,
    required this.isSuccess,
    required this.isError,
    required this.showRetry,
    this.onRetry,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: isSuccess
            ? const Color(0xFF7C3AED).withOpacity(0.92)
            : isError
                ? Colors.red.shade800.withOpacity(0.92)
                : Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSuccess
              ? const Color(0xFF7C3AED)
              : isError
                  ? Colors.red
                  : Colors.white24,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (showRetry) ...[
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ],
      ),
    );
  }
}
