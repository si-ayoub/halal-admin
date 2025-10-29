// lib/presentation/widgets/radius_map_widget.dart
import 'package:flutter/material.dart';
import '../../data/models/restaurant_model.dart';

class RadiusMapWidget extends StatelessWidget {
  final RestaurantModel restaurant;

  const RadiusMapWidget({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radiusPercent = (restaurant.radius / restaurant.radiusMax * 100).toStringAsFixed(0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.map, color: Colors.blue[700], size: 24),
                const SizedBox(width: 8),
                Text('Rayon de Visibilité', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 200,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, size: 64, color: Colors.blue[400]),
                    const SizedBox(height: 16),
                    Text(' km', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue[700])),
                    const SizedBox(height: 8),
                    Text('Rayon de diffusion', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRadiusInfo('Minimum', ' km', Icons.remove_circle_outline, Colors.orange),
                _buildRadiusInfo('Actuel', ' km', Icons.radio_button_checked, Colors.blue),
                _buildRadiusInfo('Maximum', ' km', Icons.add_circle_outline, Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: restaurant.radius / restaurant.radiusMax,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text('% du rayon maximum utilisé', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusInfo(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
