class Validators {
  static final _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final _username = RegExp(r'^[A-Za-z0-9]{3,10}$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Adresse email requise';
    if (!_email.hasMatch(v)) return 'Adresse email invalide';
    return null;
  }

  static String? username(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Pseudo requis';
    if (!_username.hasMatch(v)) {
      return '3 à 10 caractères alphanumériques uniquement';
    }
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.length < 8) return 'Au moins 8 caractères';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'Au moins une majuscule';
    if (!v.contains(RegExp(r'[a-z]'))) return 'Au moins une minuscule';
    if (!v.contains(RegExp(r'[0-9]'))) return 'Au moins un chiffre';
    if (!v.contains(RegExp(r'[^A-Za-z0-9]'))) return 'Au moins un caractère spécial';
    return null;
  }

  static String? confirmation(String? value, String password) {
    if (value != password) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  static String? identifier(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Pseudo ou email requis';
    return null;
  }
}
