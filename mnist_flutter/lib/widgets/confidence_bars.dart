import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class ConfidenceCard extends StatelessWidget {
  const ConfidenceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = context.watch<ApiService>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Prediction Confidence', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (apiService.isPredicting)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (apiService.confidences == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.draw, size: 48, color: Colors.white24),
                      const SizedBox(height: 16),
                      Text('Draw a digit to see AI prediction', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${apiService.predictedDigit}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 80,
                        shadows: [Shadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 20)],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 1.0,
                          barGroups: List.generate(
                            10,
                            (index) => BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: apiService.confidences![index],
                                  color: index == apiService.predictedDigit 
                                      ? Colors.blueAccent 
                                      : Colors.white24,
                                  width: 20,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final isPredicted = value.toInt() == apiService.predictedDigit;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      value.toInt().toString(),
                                      style: TextStyle(
                                        fontWeight: isPredicted ? FontWeight.bold : FontWeight.normal,
                                        color: isPredicted ? Colors.blueAccent : Colors.white70,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                        ),
                        swapAnimationDuration: const Duration(milliseconds: 500),
                        swapAnimationCurve: Curves.easeOutQuart,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
