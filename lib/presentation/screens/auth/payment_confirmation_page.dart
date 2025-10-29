import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

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

class PaymentConfirmationPage extends StatefulWidget {
  final String restaurantName;
  final String planName;
  final String planPrice;
  final String planPeriod;
  final DateTime? expirationDate;

  const PaymentConfirmationPage({
    Key? key,
    required this.restaurantName,
    required this.planName,
    required this.planPrice,
    required this.planPeriod,
    this.expirationDate,
  }) : super(key: key);

  @override
  State<PaymentConfirmationPage> createState() =>
      _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _countdown = 5;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _countdown--);
        if (_countdown > 0) {
          _startCountdown();
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activationDate = DateTime.now();
    final expirationDate =
        widget.expirationDate ?? activationDate.add(const Duration(days: 365));

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.4),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Félicitations !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Votre abonnement  (€/) est actif !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

