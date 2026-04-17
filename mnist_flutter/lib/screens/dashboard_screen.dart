import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/confidence_bars.dart';
import '../widgets/metrics_charts.dart';
import '../widgets/confusion_matrix.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neural Network Vision'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: const [
                        DrawingCard(),
                        SizedBox(height: 24),
                        Expanded(child: ConfidenceCard()),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: const [
                        Expanded(child: MetricsCard()),
                        SizedBox(height: 24),
                        Expanded(child: ConfusionMatrixCard()),
                      ],
                    ),
                  )
                ],
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: const [
                    DrawingCard(),
                    SizedBox(height: 24),
                    SizedBox(height: 400, child: ConfidenceCard()),
                    SizedBox(height: 24),
                    SizedBox(height: 400, child: MetricsCard()),
                    SizedBox(height: 24),
                    SizedBox(height: 400, child: ConfusionMatrixCard()),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
