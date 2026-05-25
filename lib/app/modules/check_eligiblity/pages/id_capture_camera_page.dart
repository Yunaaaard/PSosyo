import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IdCaptureCameraPage extends StatefulWidget {
  const IdCaptureCameraPage({
    super.key,
    required this.isFront,
    this.idType,
  });

  final bool isFront;
  final String? idType;

  @override
  State<IdCaptureCameraPage> createState() => _IdCaptureCameraPageState();
}

class _IdCaptureCameraPageState extends State<IdCaptureCameraPage> {
  CameraController? _controller;
  bool _isInitializing = true;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          Get.snackbar(
              'Camera unavailable', 'No camera was detected on this device.');
          Get.back<XFile?>();
        }
        return;
      }

      final preferred = cameras
          .where((c) => c.lensDirection == CameraLensDirection.back)
          .toList();
      final selected = preferred.isNotEmpty ? preferred.first : cameras.first;

      final controller = CameraController(
        selected,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isInitializing = false;
      });
    } catch (_) {
      if (mounted) {
        Get.snackbar(
            'Camera error', 'Failed to initialize camera. Please try again.');
        Get.back<XFile?>();
      }
    }
  }

  Future<void> _capture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final shot = await _controller!.takePicture();
      if (mounted) {
        Get.back<XFile?>(result: shot);
      }
    } catch (_) {
      if (mounted) {
        Get.snackbar(
            'Capture failed', 'Unable to capture image. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guideTitle = widget.isFront
        ? 'Align front of ID inside the frame'
        : 'Align back of ID inside the frame';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isInitializing || _controller == null
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth * 0.88;
                  final height = width / 1.586;
                  final frameRect = Rect.fromCenter(
                    center: Offset(
                        constraints.maxWidth / 2, constraints.maxHeight / 2),
                    width: width,
                    height: height,
                  );

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: CameraPreview(_controller!),
                      ),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _CardOverlayPainter(frameRect: frameRect),
                        ),
                      ),
                      Positioned(
                        top: 24,
                        left: 20,
                        right: 20,
                        child: Column(
                          children: [
                            Text(
                              guideTitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Place all card edges inside the highlighted outline.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFE0E0E0),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 24,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ControlButton(
                              icon: Icons.close_rounded,
                              onTap: () => Get.back<XFile?>(),
                            ),
                            GestureDetector(
                              onTap: _capture,
                              child: Container(
                                width: 82,
                                height: 82,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 4),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isCapturing
                                        ? const Color(0xFFBBBBBB)
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            _ControlButton(
                              icon: Icons.help_outline_rounded,
                              onTap: () {
                                Get.snackbar(
                                  'Tip',
                                  'Keep the ID flat, well-lit, and fully inside the frame.',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.20),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

class _CardOverlayPainter extends CustomPainter {
  _CardOverlayPainter({required this.frameRect});

  final Rect frameRect;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutout = Path()
      ..addRRect(
        RRect.fromRectAndRadius(frameRect, const Radius.circular(18)),
      );

    final overlay = Path.combine(PathOperation.difference, full, cutout);
    canvas.drawPath(
      overlay,
      Paint()..color = Colors.black.withOpacity(0.55),
    );

    final borderPaint = Paint()
      ..color = const Color(0xFF6D3DF4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(18)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CardOverlayPainter oldDelegate) {
    return oldDelegate.frameRect != frameRect;
  }
}
