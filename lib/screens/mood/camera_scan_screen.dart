import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../providers/mood_provider.dart';
import '../../services/mood_service.dart';

class CameraScanScreen extends ConsumerStatefulWidget {
  const CameraScanScreen({super.key});

  @override
  ConsumerState<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends ConsumerState<CameraScanScreen> {
  bool _isAnalyzing = false;

  Future<void> _scan() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if (pickedFile == null) return;
    if (!mounted) return;
    setState(() => _isAnalyzing = true);
    try {
      final result = await MoodService().detectMood(File(pickedFile.path));
      if (!mounted) return;
      ref.read(moodProvider.notifier).setMood(result.mood, result.confidence);
      Navigator.pushReplacementNamed(context, '/mood-result');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text('Mood Scan',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const Spacer(),
                Center(
                  child: SizedBox(
                    width: 260, height: 320,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white12, width: 1),
                          ),
                        ),
                        CustomPaint(
                          size: const Size(260, 320),
                          painter: _CornerBracketPainter(),
                        ),
                        const Center(child: Icon(Icons.face_outlined,
                            size: 80, color: Colors.white24)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Position your face in the frame',
                    style: TextStyle(color: Colors.white, fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Make sure you're in good lighting",
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAnalyzing ? null : _scan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Scan',
                          style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isAnalyzing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 20),
                    Text('Analyzing your mood...',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const arm = 28.0;
    canvas.drawLine(Offset.zero, const Offset(arm, 0), paint);
    canvas.drawLine(Offset.zero, const Offset(0, arm), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - arm, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, arm), paint);
    canvas.drawLine(Offset(0, size.height), Offset(arm, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - arm), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - arm, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - arm), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
