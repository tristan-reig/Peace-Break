import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/validators.dart';
import '../../services/auth_service.dart';

import '../../core/theme.dart';
import '../../core/widgets/arcade.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService().login(
        identifier: _identifier.text,
        password: _password.text,
      );
      if (mounted) Navigator.pushReplacementNamed(context, Routes.menu);
    } on AuthFailure catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Connexion impossible. Vérifie ton réseau.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ArcadeTitle('Peace', size: 30),
                  const ArcadeTitle('Break', size: 30, color: AppTheme.amber),
                  const SizedBox(height: 8),
                  Text(
                    '// insert coin //',
                    style: TextStyle(
                      fontFamily: AppTheme.titleFont,
                      fontSize: 8,
                      color: AppTheme.textDim,
                    ),
                  ),
                  const SizedBox(height: 40),

                  ArcadeFrame(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _identifier,
                          decoration: const InputDecoration(
                            labelText: 'PSEUDO OU EMAIL',
                          ),
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          validator: Validators.identifier,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _password,
                          decoration: const InputDecoration(
                            labelText: 'MOT DE PASSE',
                          ),
                          obscureText: true,
                          onFieldSubmitted: (_) => _submit(),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Mot de passe requis'
                              : null,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.magenta,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              _error!.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppTheme.magenta,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 26),
                        ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.bg,
                                  ),
                                )
                              : const Text('START'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.pushNamed(context, Routes.register),
                    child: const BlinkingText(
                      'NOUVEAU JOUEUR ?',
                      style: TextStyle(
                        fontFamily: AppTheme.titleFont,
                        fontSize: 9,
                        color: AppTheme.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
