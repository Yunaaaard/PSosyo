import 'package:flutter/material.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/models/liveness_models.dart';

class ChallengePills extends StatelessWidget {
  final List<Challenge> challenges;
  final int currentIndex;
  final bool challengeComplete;

  const ChallengePills({
    required this.challenges,
    required this.currentIndex,
    required this.challengeComplete,
    Key? key,
  }) : super(key: key);

  String _label(Challenge c) => c == Challenge.movement ? 'Look/Nod' : 'Smile';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(challenges.length, (i) {
        final isDone = i < currentIndex || (i == currentIndex && challengeComplete);
        final isActive = i == currentIndex && !challengeComplete;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDone
                ? const Color(0xFF7C3AED)
                : isActive
                    ? Colors.white12
                    : Colors.black45,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? Colors.white60 : Colors.transparent,
            ),
          ),
          child: Text(
            isDone ? '✓ ${_label(challenges[i])}' : _label(challenges[i]),
            style: TextStyle(
              color: isDone || isActive ? Colors.white : Colors.white38,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        );
      }),
    );
  }
}
