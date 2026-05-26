import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Scan QR'),
      ),
      body: _controller == null || !_controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          'Scan QR',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Point the camera at the payment QR code. It will scan automatically.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24, width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CameraPreview(_controller!),
                              Center(
                                child: Container(
                                  width: 250,
                                  height: 250,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white70, width: 2),
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          await _stopCamera();
                          Get.back(result: null);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cancel Scan'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
