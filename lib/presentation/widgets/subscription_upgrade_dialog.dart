// lib/presentation/widgets/subscription_upgrade_dialog.dart
import 'package:flutter/material.dart';

class SubscriptionUpgradeDialog extends StatelessWidget {
  final String restaurantId;
  final String currentPlan;
  final VoidCallback onSuccess;

  const SubscriptionUpgradeDialog({
    Key? key,
    required this.restaurantId,
    required this.currentPlan,
    required this.onSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.deepPurple.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Icons.upgrade, color: Colors.deepPurple, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Upgrade Premium', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('Plan actuel: ', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),
            _buildPlanCard(context, 'Premium', '60€/mois', '80,000 vues/mois', '3 km de rayon', Colors.blue),
            const SizedBox(height: 16),
            _buildPlanCard(context, 'Premium+', '80€/mois', '120,000 vues/mois', '5 km de rayon', Colors.deepPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, String plan, String price, String views, String radius, Color color) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: color, width: 2), borderRadius: BorderRadius.circular(12)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            _handleUpgrade(context, plan);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(plan, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                    Text(price, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFeature(Icons.visibility, views),
                const SizedBox(height: 8),
                _buildFeature(Icons.location_on, radius),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  void _handleUpgrade(BuildContext context, String plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Upgrade vers  en cours...')),
    );
    onSuccess();
  }

  String _getPlanLabel(String plan) {
    switch (plan) {
      case 'premium_plus': return 'Premium+';
      case 'premium': return 'Premium';
      case 'free': return 'Gratuit';
      default: return plan;
    }
  }
}



