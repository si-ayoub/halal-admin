class AuthService {
  // Mock - pas de vrai backend
  Stream<dynamic> get authStateChanges => Stream.value(null);
  dynamic get currentUser => null;

  Future<Map<String, dynamic>?> signUp({
    required String email,
    required String password,
    required String restaurantName,
    required String phoneNumber,
  }) async {
    await Future.delayed(Duration(seconds: 1)); // Simule un délai réseau
    print('Mode démo: Inscription simulée pour $email');
    return {'id': '1', 'email': email, 'name': restaurantName};
  }

  Future<dynamic> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(Duration(seconds: 1));
    print('Mode démo: Connexion simulée pour $email');
    return {'id': '1', 'email': email};
  }

  Future<void> signOut() async {
    print('Mode démo: Déconnexion simulée');
  }

  Future<void> resetPassword(String email) async {
    print('Mode démo: Reset password pour $email');
  }
}
