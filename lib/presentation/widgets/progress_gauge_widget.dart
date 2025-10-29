// lib/presentation/widgets/progress_gauge_widget.dart
import 'package:flutter/material.dart';
import '../../data/models/restaurant_model.dart';

class ProgressGaugeWidget extends StatelessWidget {
  final RestaurantModel restaurant;
  final Map<String, dynamic>? visibilityStats;

  const ProgressGaugeWidget({
    Key? key,
    required this.restaurant,
    this.visibilityStats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = visibilityStats?['progressPercentage'] != null
        ? double.tryParse(visibilityStats!['progressPercentage']) ?? 0.0
        : 0.0;
    final vCur = visibilityStats?['vCur'] ?? 0;
    final vMin = visibilityStats?['vMin'] ?? 1;
    final remaining = visibilityStats?['viewsRemaining'] ?? 0;

    final progressValue = (progress / 100).clamp(0.0, 1.0);
    final color = progressValue >= 0.8 ? Colors.green : progressValue >= 0.5 ? Colors.orange : Colors.red;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Progression vers l\'objectif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: progressValue,
                    strokeWidth: 16,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('%', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color)),
                    const SizedBox(height: 4),
                    Text(' / ', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(' vues restantes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



