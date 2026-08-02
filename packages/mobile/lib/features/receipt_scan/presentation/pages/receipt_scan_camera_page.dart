import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/receipt_scan/domain/entities/receipt_extraction.dart';
import 'package:expense_tracker/features/receipt_scan/domain/usecases/extract_receipt.dart';

class ReceiptScanCameraPage extends StatefulWidget {
  final ExtractReceipt? extractReceipt;
  final List<String> expenseCategoryNames;

  const ReceiptScanCameraPage({
    super.key,
    this.extractReceipt,
    this.expenseCategoryNames = const [],
  });

  @override
  State<ReceiptScanCameraPage> createState() => _ReceiptScanCameraPageState();
}

class _ReceiptScanCameraPageState extends State<ReceiptScanCameraPage>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  var _initializing = true;
  var _flashOn = false;
  var _processing = false;
  String? _error;
  File? _previewImage;
  AnimationController? _sparkleController;

  ExtractReceipt get _extractReceipt =>
      widget.extractReceipt ?? di.getIt<ExtractReceipt>();

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error = 'Camera permission is required to scan receipts.';
      });

      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _initializing = false;
          _error = 'No camera available on this device.';
        });

        return;
      }

      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        fps: 30,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);

      if (!mounted) {
        await controller.dispose();

        return;
      }

      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error = 'Could not open camera.';
      });
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final next = !_flashOn;
    await controller.setFlashMode(next ? FlashMode.torch : FlashMode.off);
    if (!mounted) return;
    setState(() => _flashOn = next);
  }

  Future<void> _beginAnalysis(File file, {required String mimeType}) async {
    setState(() {
      _previewImage = file;
      _processing = true;
    });
    await _processFile(file, mimeType: mimeType);
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (_processing || controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      final file = await controller.takePicture();
      await _beginAnalysis(File(file.path), mimeType: 'image/jpeg');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to capture photo.')));
    }
  }

  Future<void> _pickGallery() async {
    if (_processing) return;

    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return;

    final mime = picked.mimeType ?? _mimeFromPath(picked.path);
    await _beginAnalysis(File(picked.path), mimeType: mime);
  }

  void _onChooseFromGallery() {
    unawaited(_pickGallery());
  }

  String _mimeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';

    return 'image/jpeg';
  }

  void _showExtractFailure() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not read receipt. Check logs for details.'),
      ),
    );
    setState(() {
      _processing = false;
      _previewImage = null;
    });
  }

  Future<void> _processFile(File file, {required String mimeType}) async {
    try {
      final bytes = await file.readAsBytes();
      final result = await _extractReceipt(
        ExtractReceiptParams(
          imageBytes: bytes,
          mimeType: mimeType,
          categoryNames: widget.expenseCategoryNames,
        ),
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          appLogger.error(
            'ReceiptScanCamera extract failure: ${failure.message}',
          );
          _showExtractFailure();
        },
        (extraction) =>
            Navigator.of(context).pop<ReceiptExtraction>(extraction),
      );
    } catch (e, s) {
      appLogger.error('ReceiptScanCamera unexpected error', e, s);
      _showExtractFailure();
    }
  }

  Widget _buildViewport() {
    if (_initializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    final error = _error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: _onChooseFromGallery,
                child: const Text('Choose from gallery'),
              ),
            ],
          ),
        ),
      );
    }

    final preview = _previewImage;
    if (preview != null) {
      return SizedBox.expand(child: Image.file(preview, fit: BoxFit.cover));
    }

    final controller = _controller;
    if (controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final previewSize = controller.value.previewSize;

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: previewSize?.height ?? 1,
        height: previewSize?.width ?? 1,
        child: CameraPreview(controller),
      ),
    );
  }

  Widget _buildGuideOverlay() {
    final mediaSize = MediaQuery.sizeOf(context);

    return IgnorePointer(
      child: Center(
        child: Container(
          width: mediaSize.width * 0.84,
          height: mediaSize.height * 0.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Stack(
            children: [
              _corner(Alignment.topLeft),
              _corner(Alignment.topRight),
              _corner(Alignment.bottomLeft),
              _corner(Alignment.bottomRight),
              Align(
                alignment: const Alignment(0, 0.05),
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: AppColors.primary.withAlpha(128),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _corner(Alignment alignment) {
    final isLeft = alignment.x < 0;
    final isTop = alignment.y < 0;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CustomPaint(
            painter: _CornerPainter(
              color: AppColors.primary,
              isLeft: isLeft,
              isTop: isTop,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlashButton() {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 16,
      right: 20,
      child: _RoundIconButton(
        icon: _flashOn ? PiconsRegular.lightning : PiconsLight.lightningSlash,
        onTap: _processing
            ? null
            : () {
                unawaited(_toggleFlash());
              },
      ),
    );
  }

  Widget _buildHint() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 120 + MediaQuery.paddingOf(context).bottom,
      child: const Text(
        'Align receipt with the frame',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 15),
      ),
    );
  }

  Widget _buildToolbar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          16 + MediaQuery.paddingOf(context).bottom,
        ),
        color: AppColors.surfaceDark,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _RoundIconButton(
              icon: PiconsRegular.image,
              onTap: _processing
                  ? null
                  : () {
                      unawaited(_pickGallery());
                    },
            ),
            _CaptureButton(
              onTap: _processing
                  ? null
                  : () {
                      unawaited(_capture());
                    },
            ),
            _RoundIconButton(
              icon: PiconsRegular.x,
              onTap: _processing ? null : () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    final sparkle = _sparkleController;

    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sparkle != null)
              FadeTransition(
                opacity: Tween<double>(begin: 0.45, end: 1).animate(
                  CurvedAnimation(parent: sparkle, curve: Curves.easeInOut),
                ),
                child: const Icon(
                  PiconsRegular.sparkle,
                  size: 28,
                  color: AppColors.primary,
                ),
              )
            else
              const Icon(
                PiconsRegular.sparkle,
                size: 28,
                color: AppColors.primary,
              ),
            const SizedBox(width: 12),
            const Text(
              'Analyzing Expense',
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sparkleController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildViewport(),
          if (!_processing) ...[
            _buildGuideOverlay(),
            _buildFlashButton(),
            _buildHint(),
            _buildToolbar(),
          ],
          if (_processing) _buildProcessingOverlay(),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2B292C),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, size: 22, color: AppColors.textPrimaryDark),
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _CaptureButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.textPrimaryDark, width: 4),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 54,
          height: 54,
          decoration: const BoxDecoration(
            color: AppColors.textPrimaryDark,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final bool isLeft;
  final bool isTop;

  _CornerPainter({
    required this.color,
    required this.isLeft,
    required this.isTop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final path = Path();
    final x = isLeft ? 0.0 : size.width;
    final y = isTop ? 0.0 : size.height;
    path.moveTo(x, isTop ? size.height : 0);
    path.lineTo(x, y);
    path.lineTo(isLeft ? size.width : 0, y);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.isLeft != isLeft ||
      oldDelegate.isTop != isTop;
}
