/// Shared models for the liveness flow.
class LivenessResult {
  final String imagePath;
  LivenessResult({required this.imagePath});
}

enum Challenge { movement, smile }
