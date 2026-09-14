import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/validators.dart';
import '../../services/auth_service.dart';
import '../../services/profile_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _busy = false;

  void _backToLogin() {
    context.read<ProfileController>().clear();
    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false);
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    String confirmLabel = 'Confirmer',
    bool danger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: danger
                ? FilledButton.styleFrom(backgroundColor: Colors.red.shade700)
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<String?> _prompt({
    required String title,
    required String label,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            autocorrect: false,
            autofocus: true,
            decoration: InputDecoration(labelText: label),
            validator: validator,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Future<void> _run(
    Future<void> Function() action, {
    required String success,
    bool thenLogout = false,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(success)));
      if (thenLogout) _backToLogin();
    } on AuthFailure catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Opération impossible, réessaie')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _changeUsername() async {
    final value = await _prompt(
      title: 'Changer de pseudo',
      label: 'Nouveau pseudo',
      validator: Validators.username,
    );
    if (value == null || !mounted) return;

    if (!await _confirm(
      title: 'Changer de pseudo',
      message: 'Ton pseudo deviendra « $value ». Tu devras te reconnecter.',
    )) {
      return;
    }
    if (!mounted) return;

    await _run(
      () => AuthService().changeUsername(value),
      success: 'Pseudo modifié',
      thenLogout: true,
    );
  }

  Future<void> _changePassword() async {
    final value = await _prompt(
      title: 'Changer de mot de passe',
      label: 'Nouveau mot de passe',
      obscure: true,
      validator: Validators.password,
    );
    if (value == null || !mounted) return;

    if (!await _confirm(
      title: 'Changer de mot de passe',
      message: 'Tu devras te reconnecter avec le nouveau mot de passe.',
    )) {
      return;
    }
    if (!mounted) return;

    await _run(
      () async {
        await AuthService().changePassword(value);
        await AuthService().logout();
      },
      success: 'Mot de passe modifié',
      thenLogout: true,
    );
  }

  Future<void> _resetProgress() async {
    if (!await _confirm(
      title: 'Effacer la progression',
      message:
          'Tous tes scores, tes pièces et tes stages débloqués seront '
          'remis à zéro. Ton compte et ton inventaire sont conservés. '
          'Cette action est irréversible.',
      confirmLabel: 'Effacer',
      danger: true,
    )) {
      return;
    }
    if (!mounted) return;

    await _run(() async {
      await AuthService().resetProgress();
      if (mounted) await context.read<ProfileController>().load();
    }, success: 'Progression effacée');
  }

  Future<void> _deleteAccount() async {
    if (!await _confirm(
      title: 'Supprimer le compte',
      message:
          'Ton compte et toutes tes données seront définitivement '
          'supprimés. Cette action est irréversible.',
      confirmLabel: 'Supprimer',
      danger: true,
    )) {
      return;
    }
    if (!mounted) return;

    await _run(
      () => AuthService().deleteAccount(),
      success: 'Compte supprimé',
      thenLogout: true,
    );
  }

  Future<void> _logout() async {
    await _run(
      () => AuthService().logout(),
      success: 'À bientôt',
      thenLogout: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = context.watch<ProfileController>().profile?.username ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (username.isNotEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(username),
                subtitle: const Text('Compte connecté'),
              ),
            ),
          const SizedBox(height: 16),
          const _SectionTitle('Compte'),
          _Tile(
            icon: Icons.badge,
            label: 'Changer de pseudo',
            onTap: _busy ? null : _changeUsername,
          ),
          _Tile(
            icon: Icons.lock,
            label: 'Changer de mot de passe',
            onTap: _busy ? null : _changePassword,
          ),
          _Tile(
            icon: Icons.logout,
            label: 'Se déconnecter',
            onTap: _busy ? null : _logout,
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Zone sensible'),
          _Tile(
            icon: Icons.restart_alt,
            label: 'Effacer ma progression',
            danger: true,
            onTap: _busy ? null : _resetProgress,
          ),
          _Tile(
            icon: Icons.delete_forever,
            label: 'Supprimer mon compte',
            danger: true,
            onTap: _busy ? null : _deleteAccount,
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, color: Colors.white54),
    ),
  );
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.red.shade300 : null;
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: TextStyle(color: color)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
