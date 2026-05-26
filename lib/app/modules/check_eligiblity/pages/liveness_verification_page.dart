import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/liveness_controller.dart';
import 'package:p_sosyo/app/widgets/countdown_badge.dart';
import 'package:p_sosyo/app/widgets/challenge_pills.dart';
import 'package:p_sosyo/app/widgets/instruction_card.dart';


class LivenessVerificationPage extends StatelessWidget {
  const LivenessVerificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LivenessController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: ctrl.cameraController != null && ctrl.cameraInitialized.value
              ? _buildLivenessUI(ctrl)
              : const Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildLivenessUI(LivenessController ctrl) {
    return Obx(() => Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(ctrl.cameraController!),

        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Get.back(result: null),
              ),
              if (!ctrl.timedOut.value) CountdownBadge(seconds: ctrl.secondsLeft.value),
            ],
          ),
        ),

        Positioned(
          top: 72,
          left: 24,
          right: 24,
          child: ChallengePills(
            challenges: ctrl.challenges,
            currentIndex: ctrl.currentChallengeIndex.value,
            challengeComplete: ctrl.challengeComplete.value,
          ),
        ),

        Positioned(
          bottom: 32,
          left: 24,
          right: 24,
          child: InstructionCard(
            message: ctrl.timedOut.value
                ? 'Time\'s up. Try again.'
                : ctrl.succeeded.value
                    ? '✅ Capturing selfie…'
                    : ctrl.statusMessage.value,
            isSuccess: ctrl.succeeded.value,
            isError: ctrl.timedOut.value,
            showRetry: ctrl.timedOut.value,
            onRetry: ctrl.retry,
          ),
        ),
      ],
    ));
  }
}

