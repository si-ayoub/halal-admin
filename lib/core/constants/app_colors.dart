import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales VERTES (existantes - pour le dashboard)
  static const Color primary = Color(0xFF1A7F5A);
  static const Color primaryLight = Color(0xFF3ECF8E);
  
  // Nouvelles couleurs DORÉES (pour la landing page)
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFC9A961);
  static const Color goldDark = Color(0xFFB8984E);
  static const Color goldAccent = Color(0xFFF5D6A6);
  
  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC9A961), Color(0xFFD4AF37), Color(0xFFC9A961)],
  );
  
  static const LinearGradient goldButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4AF37), Color(0xFFC9A961), Color(0xFFB8984E)],
  );
  
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A7F5A), Color(0xFF3ECF8E)],
  );
  
  // Dark Mode (pour la landing)
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkBackgroundSecondary = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceSecondary = Color(0xFF2A2A2A);
  static const Color darkBorder = Color(0xFF3A3A3A);
  
  // Gift banner
  static const Color giftRed = Color(0xFFFF3B3B);
  static const Color giftRedDark = Color(0xFFFF1744);
  static const Color giftBorder = Color(0xFFFF5252);
  
  static const LinearGradient giftGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF3B3B), Color(0xFFFF1744)],
  );
  
  // Texte
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8B8);
  static const Color textMuted = Color(0xFF64748B);
}