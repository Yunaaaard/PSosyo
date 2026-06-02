import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class QrPaymentLiveScannerPage extends StatefulWidget {
  const QrPaymentLiveScannerPage({super.key});

  @override
  State<QrPaymentLiveScannerPage> createState() => _QrPaymentLiveScannerPageState();
}

class _QrPaymentLiveScannerPageState extends State<QrPaymentLiveScannerPage> {
  CameraController? _controller;
  CameraDescription? _camera;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _processing = false;
  bool _streamStarted = false;
  bool _showNote = true;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _stopCamera();
    _barcodeScanner.close();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      _camera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cameras.first);
      _controller = CameraController(_camera!, ResolutionPreset.medium, enableAudio: false, imageFormatGroup: ImageFormatGroup.yuv420);
      await _controller!.initialize();

      if (_controller != null && !_streamStarted) {
        _streamStarted = true;
        await _controller!.startImageStream(_processCameraImage);
      }

      if (mounted) setState(() {});
    } catch (e) {
      Get.back(result: null);
    }
  }

  Future<void> _stopCamera() async {
    try {
      if (_controller != null && _controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }
      await _controller?.dispose();
      _controller = null;
    } catch (_) {}
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_showNote) return;
    if (_processing || !mounted || _controller == null) return;
    _processing = true;

    try {
      final bytesBuilder = BytesBuilder(copy: false);
      for (final plane in image.planes) {
        bytesBuilder.add(plane.bytes);
      }
      final bytes = bytesBuilder.toBytes();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: ui.Size(image.width.toDouble(), image.height.toDouble()),
            rotation: InputImageRotationValue.fromRawValue(_camera?.sensorOrientation ?? 0) ??
              InputImageRotation.rotation0deg,
          format: InputImageFormatValue.fromRawValue(image.format.raw) ??
              InputImageFormat.nv21,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      final barcodes = await _barcodeScanner.processImage(inputImage);
      if (barcodes.isEmpty) {
        return;
      }

      for (final barcode in barcodes) {
        final rawValue = barcode.rawValue?.trim();
        final displayValue = barcode.displayValue?.trim();
        final raw = (rawValue != null && rawValue.isNotEmpty)
            ? rawValue
            : (displayValue != null && displayValue.isNotEmpty)
                ? displayValue
                : null;
        if (raw != null) {
          await _stopCamera();
          if (mounted) Get.back(result: raw);
          return;
        }
      }
    } catch (_) {
      // ignore frame-level errors and keep scanning
    } finally {
      _processing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller == null || !_controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Live camera preview in background
                  CameraPreview(_controller!),

                  // Dimmed overlay with clear rounded hole in center and white border
                  CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: _ScannerOverlayPainter(),
                  ),

                  // Top overlay (back button + title) drawn over the camera preview
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: SafeArea(
                      bottom: false,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        height: kToolbarHeight,
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                              onPressed: () async {
                                await _stopCamera();
                                Get.back(result: null);
                              },
                            ),
                            const Expanded(
                              child: Center(
                                child: Text('Scanner', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400)),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom note sheet (shown initially). Proceed hides the note and keeps scanning.
                  if (_showNote)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Note!',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Please scan a valid receipt from our salesman. Make sure everything is correct before you continue. Once you click the button, the payment is final and cannot be changed or reversed.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      await _stopCamera();
                                      Get.back(result: null);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      side: const BorderSide(color: Color(0xFF6B3DF0)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Color(0xFF6B3DF0)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // Hide the note and continue scanning
                                      if (mounted) setState(() => _showNote = false);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1565C0),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Proceed', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.55);

    // Draw dim layer
    final rect = Offset.zero & size;
    canvas.drawRect(rect, paint);

    // Center hole
    final holeWidth = 300.0;
    final holeHeight = 380.0;
    final holeRect = Rect.fromCenter(center: size.center(Offset.zero), width: holeWidth, height: holeHeight);
    final rrect = RRect.fromRectAndRadius(holeRect, const Radius.circular(18));

    // Clear center (make transparent)
    canvas.saveLayer(rect, Paint());
    final clearPaint = Paint()..blendMode = ui.BlendMode.clear;
    canvas.drawRRect(rrect, clearPaint);
    canvas.restore();

    // Draw white border around hole
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..isAntiAlias = true;
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
