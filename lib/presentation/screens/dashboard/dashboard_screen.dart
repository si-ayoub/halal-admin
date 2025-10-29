// lib/presentation/screens/dashboard/dashboard_screen.dart
// HALAL ADMIN - Intégration de la section visibilité dans le dashboard

import 'package:flutter/material.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../data/services/visibility_algorithm_service.dart';
import '../../../data/services/impression_tracker_service.dart';
import '../../widgets/visibility_card.dart';
import '../../widgets/progress_gauge_widget.dart';
import '../../widgets/radius_map_widget.dart';
import '../../widgets/subscription_upgrade_dialog.dart';

class DashboardScreen extends StatefulWidget {
  final String restaurantId;

  const DashboardScreen({
    Key? key,
    required this.restaurantId,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final VisibilityAlgorithmService _visibilityService = VisibilityAlgorithmService();
  final ImpressionTrackerService _impressionService = ImpressionTrackerService();
  
  RestaurantModel? _restaurant;
  Map<String, dynamic>? _visibilityStats;
  Map<String, dynamic>? _impressionStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Charger les données du restaurant
      // À remplacer par votre logique de récupération Firestore
      // _restaurant = await _restaurantService.getRestaurant(widget.restaurantId);

      // Charger les stats de visibilité
      _visibilityStats = await _visibilityService.getVisibilityStats(
        widget.restaurantId,
      );

      // Charger les stats d'impressions
      _impressionStats = await _impressionService.getRestaurantStats(
        restaurantId: widget.restaurantId,
      );
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de bienvenue
              _buildWelcomeHeader(),
              
              const SizedBox(height: 24),

              // Stats rapides (impressions du jour/semaine/mois)
              _buildQuickStats(),

              const SizedBox(height: 24),

              // Section Visibilité - NOUVEAU !
              Text(
                '?? Votre Visibilité',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Carte de visibilité avec rayon
              if (_restaurant != null)
                VisibilityCard(
                  restaurant: _restaurant!,
                  visibilityStats: _visibilityStats,
                  onUpgrade: _showUpgradeDialog,
                ),

              const SizedBox(height: 16),

              // Jauge de progression
              if (_restaurant != null)
                ProgressGaugeWidget(
                  restaurant: _restaurant!,
                  visibilityStats: _visibilityStats,
                ),

              const SizedBox(height: 16),

              // Carte avec rayon géographique
              if (_restaurant != null)
                RadiusMapWidget(
                  restaurant: _restaurant!,
                ),

              const SizedBox(height: 24),

              // Section Analytics existante (conservée)
              Text(
                '?? Analytics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Vos widgets analytics existants ici
              _buildExistingAnalytics(),

              const SizedBox(height: 24),

              // Bouton Boost si Premium
              if (_restaurant != null && _restaurant!.isPremium)
                _buildBoostSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple[400]!,
              Colors.deepPurple[600]!,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenue !',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _restaurant?.name ?? 'Votre restaurant',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final today = _impressionStats?['today'] ?? 0;
    final week = _impressionStats?['week'] ?? 0;
    final month = _impressionStats?['month'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Aujourd\'hui',
            today.toString(),
            Icons.today,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Cette semaine',
            week.toString(),
            Icons.calendar_view_week,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Ce mois',
            month.toString(),
            Icons.calendar_month,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingAnalytics() {
    // Conservez ici vos widgets analytics existants
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Vos graphiques et analytics existants ici'),
            // ... Vos widgets existants
          ],
        ),
      ),
    );
  }

  Widget _buildBoostSection() {
    final hasActiveBoost = _restaurant?.hasActiveBoost ?? false;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber[400]!,
              Colors.amber[600]!,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.rocket_launch, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Boost de Visibilité',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasActiveBoost
                            ? 'Boost actif jusqu\'au ${_restaurant!.boostUntil!.day}/${_restaurant!.boostUntil!.month}'
                            : '+50% de visibilité pendant 1 semaine ou 1 mois',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!hasActiveBoost) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showBoostDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.amber[900],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Activer un Boost',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => SubscriptionUpgradeDialog(
        restaurantId: widget.restaurantId,
        currentPlan: _restaurant?.plan ?? 'free',
        onSuccess: _loadDashboardData,
      ),
    );
  }

  void _showBoostDialog() {
    // À implémenter: Dialog pour choisir boost 1 semaine ou 1 mois
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activer un Boost'),
        content: const Text('Choisissez la durée de votre boost de visibilité'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Logique d'activation du boost
              Navigator.pop(context);
            },
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }
}
