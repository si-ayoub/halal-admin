class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email requis';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Email invalide';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  static String? required(String? value) => (value == null || value.isEmpty) ? 'Champ requis' : null;

  /// Validation du numéro WhatsApp (OBLIGATOIRE)
  /// Format accepté : +33612345678 ou +33 6 12 34 56 78 ou 0612345678
  static String? whatsapp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Numéro WhatsApp requis';
    }

    // Nettoyer le numéro (enlever espaces, tirets, parenthèses)
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Vérifier si c'est un format international (+33, +212, +1, etc.)
    if (cleanNumber.startsWith('+')) {
      // Format international : minimum 10 chiffres après le +
      if (!RegExp(r'^\+\d{10,15}$').hasMatch(cleanNumber)) {
        return 'Format invalide (ex: +33612345678)';
      }
      return null;
    }

    // Vérifier si c'est un numéro français local (06, 07)
    if (cleanNumber.startsWith('0')) {
      if (!RegExp(r'^0[67]\d{8}$').hasMatch(cleanNumber)) {
        return 'Format invalide (ex: 0612345678)';
      }
      return null;
    }

    return 'Format invalide (ex: +33612345678 ou 0612345678)';
  }

  /// Convertit un numéro local français en format international
  /// Exemple : 0612345678 → +33612345678
  static String normalizeWhatsAppNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Si déjà au format international, retourner tel quel
    if (cleanNumber.startsWith('+')) {
      return cleanNumber;
    }
    
    // Si numéro français local (0X), convertir en +33
    if (cleanNumber.startsWith('0')) {
      return '+33${cleanNumber.substring(1)}';
    }
    
    // Sinon retourner tel quel
    return cleanNumber;
  }
}