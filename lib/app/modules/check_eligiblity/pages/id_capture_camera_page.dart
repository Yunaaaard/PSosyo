import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:p_sosyo/app/data/services/national_id_service.dart';

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

class _IdCaptureCameraPageState extends State<IdCaptureCameraPage> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isInitializing = true;
  bool _isCapturing = false;
  AnimationController? _scanlineController;
  Animation<double>? _scanlineAnimation;

  // Live scan status variables
  bool _firstNameDetected = false;
  bool _middleNameDetected = false;
  bool _lastNameDetected = false;
  bool _genderDetected = false;
  bool _dobDetected = false;

  String? _detectedFirstNameVal;
  String? _detectedMiddleNameVal;
  String? _detectedLastNameVal;
  String? _detectedGenderVal;
  String? _detectedDobVal;

  final NationalIdService _nationalIdService = NationalIdService();
  bool _isProcessingFrame = false;

  @override
  void initState() {
    super.initState();
    _scanlineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanlineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_scanlineController!);
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
        imageFormatGroup: ImageFormatGroup.yuv420,
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

      // Start processing live camera frames for ID validation feedback
      await controller.startImageStream(_processFrame);
    } catch (_) {
      if (mounted) {
        Get.snackbar(
            'Camera error', 'Failed to initialize camera. Please try again.');
        Get.back<XFile?>();
      }
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    if (!mounted || _controller == null || _isProcessingFrame || _isCapturing) return;

    _isProcessingFrame = true;
    try {
      final bytesBuilder = BytesBuilder(copy: false);
      for (final plane in image.planes) {
        bytesBuilder.add(plane.bytes);
      }
      final bytes = bytesBuilder.toBytes();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotationValue.fromRawValue(_controller!.description.sensorOrientation) ??
              InputImageRotation.rotation0deg,
          format: InputImageFormatValue.fromRawValue(image.format.raw) ??
              InputImageFormat.nv21,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      if (widget.isFront) {
        final scanResult = await _nationalIdService.scanFrontInputImage(inputImage);
        if (mounted) {
          setState(() {
            _firstNameDetected = scanResult.extractedFirstName != null && scanResult.extractedFirstName!.trim().isNotEmpty;
            _middleNameDetected = scanResult.extractedMiddleName != null && scanResult.extractedMiddleName!.trim().isNotEmpty;
            _lastNameDetected = scanResult.extractedLastName != null && scanResult.extractedLastName!.trim().isNotEmpty;
            _genderDetected = scanResult.extractedGender != null && scanResult.extractedGender!.trim().isNotEmpty;
            _dobDetected = scanResult.extractedBirthDate != null && scanResult.extractedBirthDate!.trim().isNotEmpty;

            _detectedFirstNameVal = scanResult.extractedFirstName;
            _detectedMiddleNameVal = scanResult.extractedMiddleName;
            _detectedLastNameVal = scanResult.extractedLastName;
            _detectedGenderVal = scanResult.extractedGender;
            _detectedDobVal = scanResult.extractedBirthDate;
          });
        }
      } else {
        final rawQr = await _nationalIdService.scanBackQrInputImage(inputImage);
        if (rawQr != null && rawQr.isNotEmpty) {
          final scanResult = _nationalIdService.extractAllDataFromQrRawContent(rawQr);
          if (scanResult != null && mounted) {
            setState(() {
              _firstNameDetected = scanResult.extractedFirstName != null && scanResult.extractedFirstName!.trim().isNotEmpty;
              _middleNameDetected = scanResult.extractedMiddleName != null && scanResult.extractedMiddleName!.trim().isNotEmpty;
              _lastNameDetected = scanResult.extractedLastName != null && scanResult.extractedLastName!.trim().isNotEmpty;
              _genderDetected = scanResult.extractedGender != null && scanResult.extractedGender!.trim().isNotEmpty;
              _dobDetected = scanResult.extractedBirthDate != null && scanResult.extractedBirthDate!.trim().isNotEmpty;

              _detectedFirstNameVal = scanResult.extractedFirstName;
              _detectedMiddleNameVal = scanResult.extractedMiddleName;
              _detectedLastNameVal = scanResult.extractedLastName;
              _detectedGenderVal = scanResult.extractedGender;
              _detectedDobVal = scanResult.extractedBirthDate;
            });
          }
        }
      }
    } catch (e) {
      print('Error processing camera frame: $e');
    } finally {
      await Future.delayed(const Duration(milliseconds: 350));
      _isProcessingFrame = false;
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
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }
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
    _scanlineController?.dispose();
    if (_controller != null && _controller!.value.isStreamingImages) {
      try {
        _controller!.stopImageStream();
      } catch (_) {}
    }
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildDetectionHud() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6D3DF4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ID DETAILS DETECTOR',
                    style: TextStyle(
                      color: Color(0xFFB0BEC5),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              if (_firstNameDetected && _middleNameDetected && _lastNameDetected && _genderDetected && _dobDetected)
                const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'READY',
                      style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ],
                )
              else
                const Text(
                  'SCANNING...',
                  style: TextStyle(color: Color(0xFFFFB300), fontSize: 10, fontWeight: FontWeight.w700),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHudItem('First Name', _firstNameDetected, _detectedFirstNameVal),
              _buildHudItem('Middle Name', _middleNameDetected, _detectedMiddleNameVal),
              _buildHudItem('Last Name', _lastNameDetected, _detectedLastNameVal),
              _buildHudItem('Gender', _genderDetected, _detectedGenderVal),
              _buildHudItem('DOB', _dobDetected, _detectedDobVal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHudItem(String label, bool isDetected, String? detectedValue) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDetected ? const Color(0xFFE8F5E9).withOpacity(0.2) : Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDetected ? const Color(0xFF4CAF50) : Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              isDetected ? Icons.check_rounded : Icons.hourglass_empty_rounded,
              color: isDetected ? const Color(0xFF4CAF50) : const Color(0xFF90A4AE),
              size: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isDetected && detectedValue != null) ...[
            const SizedBox(height: 2),
            Text(
              detectedValue,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF81C784),
                fontSize: 8,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
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
                      // Scanline Animation overlay
                      AnimatedBuilder(
                        animation: _scanlineAnimation!,
                        builder: (context, child) {
                          final topOffset = frameRect.top + (frameRect.height * _scanlineAnimation!.value);
                          return Positioned(
                            top: topOffset,
                            left: frameRect.left + 4,
                            width: frameRect.width - 8,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6D3DF4).withOpacity(0.8),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6D3DF4).withOpacity(0.0),
                                    const Color(0xFF6D3DF4),
                                    const Color(0xFF6D3DF4).withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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
                      // ID Detected Identifier HUD Panel
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 124,
                        child: _buildDetectionHud(),
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
