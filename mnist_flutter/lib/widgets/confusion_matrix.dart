import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class ConfusionMatrixCard extends StatelessWidget {
  const ConfusionMatrixCard({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = context.watch<ApiService>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Confusion Matrix (Validation Data)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (apiService.confusionMatrix == null)
               const Expanded(child: Center(child: Text('No matrix data available')))
            else
               Expanded(
                 child: LayoutBuilder(
                   builder: (context, constraints) {
                     return _buildGrid(context, apiService.confusionMatrix!, constraints);
                   }
                 )
               )
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<List<int>> matrix, BoxConstraints constraints) {
    int maxVal = 0;
    for (var row in matrix) {
      for (var val in row) {
        if (val > maxVal) maxVal = val;
      }
    }

    return Column(
      children: [
        // Top header
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
             Text('Predicted →', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ]
        ),
        Expanded(
          child: Row(
            children: [
              // Left header
              RotatedBox(
                quarterTurns: 3,
                child: const Text('Actual →', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    // Col Labels
                    Row(
                      children: [
                        const SizedBox(width: 24),
                        ...List.generate(10, (i) => Expanded(
                          child: Center(child: Text('$i', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70))),
                        ))
                      ],
                    ),
                    Expanded(
                      child: Column(
                        children: List.generate(10, (rowIdx) {
                          return Expanded(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24, 
                                  child: Center(child: Text('$rowIdx', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)))
                                ),
                                ...List.generate(10, (colIdx) {
                                  final val = matrix[rowIdx][colIdx];
                                  double intensity = maxVal > 0 ? val / maxVal : 0;
                                  Color cellColor = Color.lerp(Colors.transparent, Colors.blueAccent, intensity) ?? Colors.transparent;
                                
                                  return Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: rowIdx == colIdx && val > 0 ? Colors.green.withOpacity(0.4 + 0.6 * intensity) : cellColor,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.white10),
                                      ),
                                      child: Tooltip(
                                        message: 'Actual: $rowIdx\nPredicted: $colIdx\nCount: $val',
                                        child: Center(
                                          child: Text(
                                            val > 0 ? '$val' : '',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: intensity > 0.5 ? Colors.white : Colors.white70
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                })
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
