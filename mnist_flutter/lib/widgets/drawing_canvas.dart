import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class DrawingCard extends StatefulWidget {
  const DrawingCard({super.key});

  @override
  State<DrawingCard> createState() => _DrawingCardState();
}

class _DrawingCardState extends State<DrawingCard> {
  List<Offset?> points = [];

  void clearCanvas() {
    setState(() {
      points.clear();
    });
    context.read<ApiService>().clearPrediction();
  }

  Future<void> predictImage() async {
    if (points.isEmpty) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 18.0; // MNIST digits are quite thick

    // Draw transparent background to capture exactly what the user drew
    canvas.drawRect(const Rect.fromLTWH(0, 0, 280, 280), Paint()..color = Colors.transparent);

    for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != null && points[i + 1] != null) {
          canvas.drawLine(points[i]!, points[i + 1]!, paint);
        }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(280, 280);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      final base64Image = base64Encode(byteData.buffer.asUint8List());
      context.read<ApiService>().predict(base64Image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Draw a Digit (0-9)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: Colors.black, // Canvas background is black, drawing is white
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 20)
                ]
              ),
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    points.add(details.localPosition);
                  });
                },
                onPanEnd: (details) {
                  points.add(null); // Delimiter for continuous lines
                  predictImage();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CustomPaint(
                    painter: CanvasPainter(points: points),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: clearCanvas,
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    foregroundColor: Colors.redAccent,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CanvasPainter extends CustomPainter {
  final List<Offset?> points;

  CanvasPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 18.0;

    for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != null && points[i + 1] != null) {
          canvas.drawLine(points[i]!, points[i + 1]!, paint);
        }
    }
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) => true;
}
