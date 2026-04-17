import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class MetricsCard extends StatelessWidget {
  const MetricsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = context.watch<ApiService>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Training Metrics', style: Theme.of(context).textTheme.titleLarge),
                if (apiService.isLoadingMetrics)
                  const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () => apiService.fetchMetrics(),
                  )
              ],
            ),
            const SizedBox(height: 16),
            if (apiService.accuracy == null && !apiService.isLoadingMetrics)
              const Expanded(child: Center(child: Text('Train model to view metrics')))
            else if (apiService.accuracy != null)
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _LineChartWidget(
                        title: 'Accuracy',
                        trainData: apiService.accuracy!,
                        valData: apiService.valAccuracy!,
                        color: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _LineChartWidget(
                        title: 'Loss',
                        trainData: apiService.loss!,
                        valData: apiService.valLoss!,
                        color: Colors.redAccent,
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

class _LineChartWidget extends StatelessWidget {
  final String title;
  final List<double> trainData;
  final List<double> valData;
  final Color color;

  const _LineChartWidget({
    required this.title,
    required this.trainData,
    required this.valData,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    List<FlSpot> trainSpots = [];
    List<FlSpot> valSpots = [];
    double maxY = 0;
    
    for (int i = 0; i < trainData.length; i++) {
      trainSpots.add(FlSpot(i.toDouble(), trainData[i]));
      valSpots.add(FlSpot(i.toDouble(), valData[i]));
      if (trainData[i] > maxY) maxY = trainData[i];
      if (valData[i] > maxY) maxY = valData[i];
    }

    if (title == 'Accuracy') maxY = 1.0;

    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Expanded(
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: trainSpots,
                  isCurved: true,
                  color: color,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withOpacity(0.1),
                  ),
                ),
                LineChartBarData(
                  spots: valSpots,
                  isCurved: true,
                  color: Colors.orangeAccent,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                ),
              ],
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text('Epochs', style: TextStyle(fontSize: 10)),
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(2), style: const TextStyle(fontSize: 10)),
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.white24, width: 1),
                  left: BorderSide(color: Colors.white24, width: 1),
                  right: const BorderSide(color: Colors.transparent),
                  top: const BorderSide(color: Colors.transparent),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
              ),
              maxY: maxY * 1.1,
              minY: 0,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: color, text: 'Train'),
            const SizedBox(width: 16),
            const _LegendItem(color: Colors.orangeAccent, text: 'Val'),
          ],
        )
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}
