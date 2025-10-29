import 'package:flutter/material.dart';
import 'package:halal_admin/core/constants/app_colors.dart';
import 'package:halal_admin/core/constants/app_strings.dart';
import 'package:halal_admin/core/routes/app_routes.dart';

class PaymentConfirmationArgs {
  final String restaurantName;
  final String planName;
  final String planPrice;
  final String planPeriod;
  final DateTime? expirationDate;

  PaymentConfirmationArgs({
    required this.restaurantName,
    required this.planName,
    required this.planPrice,
    required this.planPeriod,
    this.expirationDate,
  });
}

class RegistrationFlowPage extends StatefulWidget {
  final String restaurantName;
  final String email;
  final String whatsappNumber;

  const RegistrationFlowPage({
    Key? key,
    required this.restaurantName,
    required this.email,
    required this.whatsappNumber,
  }) : super(key: key);

  @override
  State<RegistrationFlowPage> createState() => _RegistrationFlowPageState();
}

class _RegistrationFlowPageState extends State<RegistrationFlowPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _countryController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _platNameController = TextEditingController();
  final _platDescController = TextEditingController();
  final _platPriceController = TextEditingController();

  late List<Map<String, dynamic>> _horaires;
  List<Map<String, String>> _plats = [];
  String? _selectedPlan;
  bool _isAnnual = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeHoraires();
  }

  void _initializeHoraires() {
    _horaires = [
      {'day': 'Lundi', 'open': true, 'start': '11:00', 'end': '22:00'},
      {'day': 'Mardi', 'open': true, 'start': '11:00', 'end': '22:00'},
      {'day': 'Mercredi', 'open': true, 'start': '11:00', 'end': '22:00'},
      {'day': 'Jeudi', 'open': true, 'start': '11:00', 'end': '22:00'},
      {'day': 'Vendredi', 'open': true, 'start': '11:00', 'end': '22:30'},
      {'day': 'Samedi', 'open': true, 'start': '11:00', 'end': '23:00'},
      {'day': 'Dimanche', 'open': false, 'start': '00:00', 'end': '00:00'},
    ];
  }

  void _addPlat() {
    if (_platNameController.text.isEmpty) {
      _showSnackBar('Entrez le nom du plat', isError: true);
      return;
    }
    setState(() {
      _plats.add({
        'name': _platNameController.text,
        'desc': _platDescController.text,
        'price': _platPriceController.text,
      });
    });
    _platNameController.clear();
    _platDescController.clear();
    _platPriceController.clear();
    _showSnackBar('Plat ajouté avec succès', isError: false);
  }

  void _removePlat(int index) {
    setState(() => _plats.removeAt(index));
    _showSnackBar('Plat supprimé', isError: false);
  }

  Future<void> _handlePayment() async {
    if (_selectedPlan == null) {
      _showSnackBar('Veuillez sélectionner un abonnement', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      final planPrice = _isAnnual ? (_selectedPlan == 'medium' ? '576' : '768') : (_selectedPlan == 'medium' ? '60' : '80');
      final expirationDate = DateTime.now().add(const Duration(days: 365));

      if (mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.paymentConfirmation,
          arguments: PaymentConfirmationArgs(
            restaurantName: widget.restaurantName,
            planName: _selectedPlan == 'medium' ? 'Medium' : 'Premium',
            planPrice: planPrice,
            planPeriod: _isAnnual ? 'an' : 'mois',
            expirationDate: expirationDate,
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Erreur: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cuisineController.dispose();
    _countryController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _tiktokController.dispose();
    _platNameController.dispose();
    _platDescController.dispose();
    _platPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopNav(),
              _buildHero(),
              _buildInfosBase(),
              _buildCuisineCountry(),
              _buildHoraires(),
              _buildPlats(),
              _buildPhotos(),
              _buildReseauxSociaux(),
              _buildApercuPleinEcran(),
              _buildBlocPedagogique(),
              _buildPlans(),
              _buildValidation(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.95),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => AppColors.goldGradient.createShader(bounds),
            child: const Text(AppStrings.appName, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          GestureDetector(
            onTap: () => _showSnackBar('Dashboard sera accessible après validation', isError: false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(gradient: AppColors.goldGradient, borderRadius: BorderRadius.circular(8)),
              child: const Text('Dashboard', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          const Text('Créez gratuitement la fiche de votre restaurant en 3 minutes', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          Text('Votre fiche sera visible par des milliers de clients. Vous pourrez la modifier à tout moment.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildInfosBase() {
    return _buildCard(
      title: 'Informations de base',
      subtitle: 'Ces informations aideront vos clients à vous trouver facilement',
      child: Column(
        children: [
          _buildFormField(label: 'Nom du restaurant', initialValue: widget.restaurantName, enabled: false),
          const SizedBox(height: 16),
          _buildFormField(label: 'Adresse complète', controller: _addressController, placeholder: '123 rue de la Paix, 75001 Paris', helper: 'Pour que vos clients vous trouvent facilement'),
          const SizedBox(height: 16),
          _buildFormField(label: 'Numéro WhatsApp', initialValue: widget.whatsappNumber, enabled: false, helper: '✅ Déjà renseigné lors de l\'inscription'),
        ],
      ),
    );
  }

  Widget _buildCuisineCountry() {
    return _buildCard(
      title: 'Type de cuisine & Pays',
      child: Column(
        children: [
          _buildDropdown(label: 'Type de cuisine', controller: _cuisineController, items: ['Marocaine', 'Algérienne', 'Libanaise', 'Turque', 'Indienne', 'Française', 'Italienne']),
          const SizedBox(height: 16),
          _buildDropdown(label: 'Pays', controller: _countryController, items: ['France', 'Belgique', 'Suisse', 'Maroc', 'Algérie', 'Canada']),
        ],
      ),
    );
  }

  Widget _buildHoraires() {
    return _buildCard(
      title: 'Horaires d\'ouverture',
      subtitle: 'Cochez les jours où vous êtes ouvert',
      child: Column(
        children: List.generate(_horaires.length, (index) {
          final horaire = _horaires[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.darkSurfaceSecondary, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Checkbox(
                  value: horaire['open'],
                  onChanged: (value) => setState(() => _horaires[index]['open'] = value ?? false),
                  fillColor: WidgetStateProperty.all(AppColors.gold),
                ),
                SizedBox(width: 100, child: Text(horaire['day'], style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white))),
                Expanded(
                  child: horaire['open']
                      ? Row(
                          children: [
                            SizedBox(width: 80, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(6)), child: Text(horaire['start'], style: TextStyle(color: AppColors.textSecondary, fontSize: 13), textAlign: TextAlign.center))),
                            const SizedBox(width: 8),
                            Text('-', style: TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(width: 8),
                            SizedBox(width: 80, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(6)), child: Text(horaire['end'], style: TextStyle(color: AppColors.textSecondary, fontSize: 13), textAlign: TextAlign.center))),
                          ],
                        )
                      : Text('Fermé', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPlats() {
    return _buildCard(
      title: 'Vos plats et menu',
      subtitle: 'Ajoutez autant de plats que vous le souhaitez',
      child: Column(
        children: [
          if (_plats.isNotEmpty) ...[
            ..._plats.asMap().entries.map((entry) => _buildPlatItem(entry.key, entry.value)),
            const SizedBox(height: 16),
          ],
          Container(
            decoration: BoxDecoration(color: AppColors.darkBackground, border: Border.all(color: AppColors.darkBorder, width: 2), borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ajouter un plat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gold)),
                const SizedBox(height: 16),
                _buildFormField(label: 'Nom du plat', controller: _platNameController, placeholder: 'Couscous Royal'),
                const SizedBox(height: 12),
                _buildFormField(label: 'Description (optionnel)', controller: _platDescController, placeholder: 'Décrivez votre plat...', maxLines: 3),
                const SizedBox(height: 12),
                _buildFormField(label: 'Prix (optionnel)', controller: _platPriceController, placeholder: '15.90', keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addPlat,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: Ink(
                      decoration: BoxDecoration(gradient: AppColors.goldButtonGradient, borderRadius: BorderRadius.circular(10)),
                      child: Container(alignment: Alignment.center, child: const Text('+ Ajouter ce plat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatItem(int index, Map<String, String> plat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.darkBackground, border: Border.all(color: AppColors.darkBorder), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(width: 60, height: 60, decoration: BoxDecoration(color: AppColors.darkSurfaceSecondary, borderRadius: BorderRadius.circular(10)), child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 28)))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plat['name']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.gold)),
                if (plat['desc']!.isNotEmpty) ...[const SizedBox(height: 4), Text(plat['desc']!, style: TextStyle(fontSize: 13, color: AppColors.textSecondary))],
                if (plat['price']!.isNotEmpty) ...[const SizedBox(height: 4), Text('${plat['price']!}€', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gold))],
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _removePlat(index),
            child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(border: Border.all(color: Colors.red), borderRadius: BorderRadius.circular(8)), child: const Text('✕', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotos() {
    return _buildCard(
      title: 'Photos',
      subtitle: 'Plus de photos = plus de clients',
      child: Column(
        children: [
          _buildUploadZone('Logo (optionnel)', '🏷️'),
          const SizedBox(height: 16),
          _buildUploadZone('Photo de couverture', '📷'),
        ],
      ),
    );
  }

  Widget _buildReseauxSociaux() {
    return _buildCard(
      title: 'Réseaux sociaux',
      subtitle: 'Ajoutez vos liens (optionnel)',
      child: Column(
        children: [
          _buildFormField(label: 'Instagram', controller: _instagramController, placeholder: '@votre_restaurant'),
          const SizedBox(height: 12),
          _buildFormField(label: 'Facebook', controller: _facebookController, placeholder: 'facebook.com/votre-restaurant'),
          const SizedBox(height: 12),
          _buildFormField(label: 'TikTok', controller: _tiktokController, placeholder: '@votre_restaurant'),
        ],
      ),
    );
  }

  Widget _buildApercuPleinEcran() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: AppColors.darkSurface, border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text('👉 Voici comment vos clients verront votre restaurant', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gold)),
          const SizedBox(height: 30),
          Container(
            width: double.infinity, height: 500,
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.goldLight, AppColors.gold]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.3), blurRadius: 30)]),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.restaurantName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 12),
                  Text(_cuisineController.text.isEmpty ? 'Type de cuisine' : _cuisineController.text, style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.9))),
                  const SizedBox(height: 30),
                  Container(width: 200, height: 200, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('📷', style: TextStyle(fontSize: 64)))),
                  const SizedBox(height: 30),
                  Text('📍 ${_countryController.text.isEmpty ? "Localisation" : _countryController.text}\n⭐ Nouveaux avis\n🕐 Horaires', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.9), height: 1.8)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlocPedagogique() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: AppColors.darkBackground, border: Border.all(color: AppColors.gold, width: 2), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pourquoi choisir l\'abonnement sponsorisé ?', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.gold)),
          const SizedBox(height: 20),
          Text('Avec la mise en avant, votre restaurant sera visible par 500 000 à 1 000 000 de clients potentiels par an.', style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.6)),
          const SizedBox(height: 16),
          Text('Imaginons que seulement 1% viennent une fois :', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.darkSurface, border: Border.all(color: AppColors.darkBorder), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('500 000 vues = 5 000 clients', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Text('5 000 x 10€ = 50 000€ de CA/an', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.gold)),
                const SizedBox(height: 16),
                const Text('1 000 000 vues = 10 000 clients', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Text('10 000 x 10€ = 100 000€ de CA/an', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFFF59E0B))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('➡️ Pour seulement 576€ à 768€/an, une visibilité qui peut générer des dizaines de milliers d\'euros', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gold)),
        ],
      ),
    );
  }

  Widget _buildPlans() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choisissez votre abonnement sponsorisé', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.gold)),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Mensuel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: !_isAnnual ? AppColors.gold : AppColors.textSecondary)),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => _isAnnual = !_isAnnual),
                child: Container(
                  width: 50, height: 28,
                  decoration: BoxDecoration(color: _isAnnual ? AppColors.gold : AppColors.darkSurfaceSecondary, borderRadius: BorderRadius.circular(14)),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        left: _isAnnual ? 26 : 2, top: 2,
                        child: Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('Annuel (-20%)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _isAnnual ? AppColors.gold : AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 30),
          _buildPlanCard(name: '💎 Medium', price: _isAnnual ? '576' : '60', unit: _isAnnual ? '/an' : '/mois', views: '≈ 500 000 vues/an', features: ['Mise en avant prioritaire', 'Badge TENDANCE', 'Statistiques détaillées', 'Support prioritaire'], isSelected: _selectedPlan == 'medium', onSelect: () => setState(() => _selectedPlan = 'medium')),
          const SizedBox(height: 20),
          _buildPlanCard(name: '👑 Premium', price: _isAnnual ? '768' : '80', unit: _isAnnual ? '/an' : '/mois', views: '≈ 1 000 000 vues/an', features: ['Visibilité maximale', 'Priorité absolue', 'Analytics avancées', 'Support VIP dédié'], isSelected: _selectedPlan == 'premium', onSelect: () => setState(() => _selectedPlan = 'premium'), isPremium: true),
        ],
      ),
    );
  }

  Widget _buildPlanCard({required String name, required String price, required String unit, required String views, required List<String> features, required bool isSelected, required VoidCallback onSelect, bool isPremium = false}) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.darkSurface, border: Border.all(color: isSelected ? AppColors.gold : AppColors.darkBorder, width: 2), borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.gold)),
                    const SizedBox(height: 4),
                    Text(views, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
                Radio<String>(
                  value: isPremium ? 'premium' : 'medium',
                  groupValue: _selectedPlan,
                  onChanged: (_) => onSelect(),
                  fillColor: WidgetStateProperty.all(AppColors.gold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('$price€$unit', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.gold)),
            const SizedBox(height: 20),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Text('✓ ', style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.w700)),
                  Text(feature, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildValidation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: AppColors.darkSurface, border: Border.all(color: AppColors.darkBorder), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: () => _showSnackBar('Fiche validée! (Stripe sera intégré pour le paiement)', isError: false),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 0, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Ink(
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF3B3B), Color(0xFFFF1744)]), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: const Color(0xFFFF3B3B).withValues(alpha: 0.35), blurRadius: 20)]),
                child: Container(alignment: Alignment.center, child: const Text('✅ Je valide ma fiche gratuite', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Votre fiche sera visible gratuitement. Vous pourrez la modifier à tout moment.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 30),
          Container(height: 1, color: AppColors.darkBorder),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: _selectedPlan != null ? _handlePayment : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 0, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: _selectedPlan != null ? const LinearGradient(colors: [Color(0xFFFF3B3B), Color(0xFFFF1744)]) : LinearGradient(colors: [AppColors.darkBorder, AppColors.darkBorder]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedPlan != null ? [BoxShadow(color: const Color(0xFFFF3B3B).withValues(alpha: 0.35), blurRadius: 20)] : [],
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('🚀 Accéder à mon Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _selectedPlan != null ? Colors.white : AppColors.textSecondary)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('(Disponible après paiement)', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, String? subtitle, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.darkSurface, border: Border.all(color: AppColors.darkBorder), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.gold)),
          if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle, style: TextStyle(fontSize: 14, color: AppColors.textSecondary))],
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildFormField({required String label, TextEditingController? controller, String? initialValue, String? placeholder, String? helper, bool enabled = true, int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller, initialValue: initialValue, enabled: enabled, maxLines: maxLines, keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: placeholder, hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)), filled: true, fillColor: AppColors.darkBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.darkBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.darkBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.gold, width: 2)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.darkBorder)),
          ),
        ),
        if (helper != null) ...[const SizedBox(height: 6), Text(helper, style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic))],
      ],
    );
  }

  Widget _buildDropdown({required String label, required TextEditingController controller, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? null : controller.text,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.text = value;
              setState(() {});
            }
          },
          decoration: InputDecoration(
            filled: true, fillColor: AppColors.darkBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.darkBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.darkBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.gold, width: 2)),
          ),
          style: const TextStyle(color: Colors.white),
          dropdownColor: AppColors.darkSurface,
        ),
      ],
    );
  }

  Widget _buildUploadZone(String label, String emoji) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(border: Border.all(color: AppColors.darkBorder, width: 2, style: BorderStyle.solid), borderRadius: BorderRadius.circular(12), color: AppColors.darkBackground),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text('Cliquez pour ajouter', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}