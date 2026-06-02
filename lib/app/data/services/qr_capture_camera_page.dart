import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/widgets/app_snackbar.dart';

class QrCaptureCameraPage extends StatefulWidget {
  const QrCaptureCameraPage({super.key});

  @override
  State<QrCaptureCameraPage> createState() => _QrCaptureCameraPageState();
}

class _QrCaptureCameraPageState extends State<QrCaptureCameraPage> {
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
          AppSnackbar.error(
            title: 'Camera unavailable',
            message: 'No camera was detected on this device.',
            position: SnackPosition.TOP,
            duration: const Duration(seconds: 5),
          );
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
        ResolutionPreset.medium,
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
        AppSnackbar.error(
          title: 'Camera error',
          message: 'Failed to initialize camera. Please try again.',
          position: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
        Get.back<XFile?>();
      }
    }
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) {
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
        AppSnackbar.error(
          title: 'Capture failed',
          message: 'Unable to capture image. Please try again.',
          position: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isInitializing || _controller == null
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Stack(
                children: [
                  Positioned.fill(child: CameraPreview(_controller!)),
                  Positioned.fill(child: CustomPaint(painter: _QrOverlayPainter())),
                  Positioned(
                    top: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: const [
                        Text(
                          'Align QR code inside the frame',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Position the QR code in the center and press the capture button.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 14, fontWeight: FontWeight.w400),
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
                        _ControlButton(icon: Icons.close_rounded, onTap: () => Get.back<XFile?>()),
                        GestureDetector(
                          onTap: _capture,
                          child: Container(
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isCapturing ? const Color(0xFFBBBBBB) : Colors.white,
                              ),
                            ),
                          ),
                        ),
                        _ControlButton(icon: Icons.help_outline_rounded, onTap: () {
                          AppSnackbar.info(
                            title: 'Tip',
                            message: 'Ensure QR is well-lit and fully inside the frame.',
                            position: SnackPosition.TOP,
                            duration: const Duration(seconds: 4),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
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
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.20), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

class _QrOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width * 0.7;
    final height = width;
    final frameRect = Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: width, height: height);

    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutout = Path()..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(12)));
    final overlay = Path.combine(PathOperation.difference, full, cutout);
    canvas.drawPath(overlay, Paint()..color = Colors.black.withOpacity(0.55));

    final borderPaint = Paint()..color = const Color(0xFF6D3DF4)..style = PaintingStyle.stroke..strokeWidth = 3;
    canvas.drawRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(12)), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
