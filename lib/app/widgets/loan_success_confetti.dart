import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class LoanSuccessConfetti extends StatefulWidget {
  const LoanSuccessConfetti({super.key});

  @override
  State<LoanSuccessConfetti> createState() => _LoanSuccessConfettiState();
}

class _LoanSuccessConfettiState extends State<LoanSuccessConfetti> {
  final ConfettiController _confettiControllerLeft =
    ConfettiController(duration: const Duration(seconds: 3));
  final ConfettiController _confettiControllerRight =
    ConfettiController(duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _confettiControllerLeft.play();
        _confettiControllerRight.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiControllerLeft.dispose();
    _confettiControllerRight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: ConfettiWidget(
              confettiController: _confettiControllerLeft,
              blastDirection: 0.8,
              emissionFrequency: 0.12,
              numberOfParticles: 18,
              maxBlastForce: 18,
              minBlastForce: 8,
              gravity: 0.20,
              colors: const [
                Color(0xFF3B82F6),
                Color(0xFF6366F1),
                Color(0xFFF59E42),
                Color(0xFF10B981),
                Color(0xFFF43F5E),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: ConfettiWidget(
              confettiController: _confettiControllerRight,
              blastDirection: 2.4,
              emissionFrequency: 0.12,
              numberOfParticles: 18,
              maxBlastForce: 18,
              minBlastForce: 8,
              gravity: 0.20,
              colors: const [
                Color(0xFF3B82F6),
                Color(0xFF6366F1),
                Color(0xFFF59E42),
                Color(0xFF10B981),
                Color(0xFFF43F5E),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
