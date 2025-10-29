// lib/presentation/widgets/visibility_card.dart
import 'package:flutter/material.dart';
import '../../data/models/restaurant_model.dart';

class VisibilityCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final Map<String, dynamic>? visibilityStats;
  final VoidCallback onUpgrade;

  const VisibilityCard({
    Key? key,
    required this.restaurant,
    this.visibilityStats,
    required this.onUpgrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final score = visibilityStats?['currentScore'] ?? '0.0';
    final status = visibilityStats?['performanceStatus'] ?? 'unknown';
    
    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    switch (status) {
      case 'excellent':
        statusColor = Colors.green;
        statusIcon = Icons.trending_up;
        statusLabel = 'Excellent';
        break;
      case 'good':
        statusColor = Colors.blue;
        statusIcon = Icons.thumb_up;
        statusLabel = 'Bon';
        break;
      case 'average':
        statusColor = Colors.orange;
        statusIcon = Icons.show_chart;
        statusLabel = 'Moyen';
        break;
      case 'poor':
        statusColor = Colors.red;
        statusIcon = Icons.trending_down;
        statusLabel = 'Faible';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusLabel = 'Inconnu';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Score de Visibilité', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(score, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: statusColor)),
                        const Text('/100', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(statusIcon, color: statusColor, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.circle, color: statusColor, size: 12),
                const SizedBox(width: 8),
                Text(statusLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: statusColor)),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 16),
            _buildInfoRow('Rayon actuel', ' km', Icons.location_on),
            const SizedBox(height: 8),
            _buildInfoRow('Plan', restaurant.plan, Icons.star),
            const SizedBox(height: 8),
            _buildInfoRow('Vues ce mois', ' / ', Icons.visibility),
            const SizedBox(height: 16),
            if (restaurant.plan == 'free')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onUpgrade,
                  icon: const Icon(Icons.upgrade),
                  label: const Text('Passer Premium'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
