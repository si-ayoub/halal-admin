import 'package:flutter/material.dart';
import '../../presentation/screens/auth/home_page.dart';
import '../../presentation/screens/auth/registration_flow_page.dart';
import '../../presentation/screens/auth/payment_confirmation_page.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';

class AppRoutes {
  // Routes nommées
  static const String home = '/';
  static const String registration = '/registration';
  static const String paymentConfirmation = '/payment-confirmation';
  static const String dashboard = '/dashboard';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      
      case registration:
        final args = settings.arguments as RegistrationArgs?;
        return MaterialPageRoute(
          builder: (_) => RegistrationFlowPage(
            restaurantName: args?.restaurantName ?? '',
            email: args?.email ?? '',
            whatsappNumber: args?.whatsappNumber ?? '',
          ),
        );
      
      case paymentConfirmation:
        final args = settings.arguments as PaymentConfirmationArgs?;
        return MaterialPageRoute(
          builder: (_) => PaymentConfirmationPage(
            restaurantName: args?.restaurantName ?? '',
            planName: args?.planName ?? 'Premium',
            planPrice: args?.planPrice ?? '80',
            planPeriod: args?.planPeriod ?? 'mois',
            expirationDate: args?.expirationDate,
          ),
        );
      
      case dashboard:
        final restaurantId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => DashboardScreen(
            restaurantId: restaurantId ?? '',
          ),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} non trouvée'),
            ),
          ),
        );
    }
  }
}

// Arguments pour registration
class RegistrationArgs {
  final String restaurantName;
  final String email;
  final String whatsappNumber;

  RegistrationArgs({
    required this.restaurantName,
    required this.email,
    required this.whatsappNumber,
  });
}

// Arguments pour payment confirmation
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
