import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/kds_theme.dart';
import '../../data/auth_repository.dart';
import '../providers/auth_providers.dart';
import '../widgets/screen_setup_sheet.dart';

/// KDS login screen — shown only on first launch or after logout.
/// Staff enter their POS credentials; Firebase config is returned by the API
/// and initialised transparently — no merchant-facing Firebase settings.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  /// Whether this device has registered as a screen. Read once on open, and
  /// again after a setup, so the button can say which it is.
  bool _registered = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(sessionProvider.notifier).login(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          );
      if (mounted) context.go('/kds');
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('ApiException', '').trim(); });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kitchen = context.kitchen;
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo / title
                Icon(Icons.restaurant_menu, size: 64, color: colors.primary),
                const SizedBox(height: 16),
                Text(
                  'Xeboki KDS',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in with your POS staff credentials',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: 40),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: _inputDec(context, 'Email', Icons.email_outlined),
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: _inputDec(context, 'Password', Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: colors.onDisabled,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 4) ? 'Enter your password' : null,
                  onFieldSubmitted: (_) => _submit(),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kitchen.ageRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kitchen.ageRed.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: kitchen.ageRed, fontSize: 13),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Sign-in button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _loading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: colors.onPrimary),
                          )
                        : const Text('Sign In',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),

                // SPEC-097. A screen registers like a till. Shown here rather
                // than hidden in settings because it is the first thing a new
                // tablet needs, and because a screen that is not set up shows
                // only unclaimed work — which looks like a quiet kitchen
                // rather than a screen nobody has told what to show.
                const SizedBox(height: 20),
                Center(
                  child: TextButton.icon(
                    onPressed: _loading ? null : _setUpThisScreen,
                    icon: Icon(
                      _registered ? Icons.check_circle_outline : Icons.tv,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                    label: Text(
                      _registered
                          ? 'This screen is set up — change it'
                          : 'Set up this screen',
                      style: TextStyle(
                          fontSize: 13, color: colors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Takes a context because the field's colours are the till's now, and
  /// those differ between light and dark. The `colors.textSecondary` /
  /// `colors.onDisabled` that stood here were written for a screen that was
  /// always dark; on the till's light ground they are invisible.
  Future<void> _refreshRegistration() async {
    final id = await AuthRepository().registeredScreenId();
    if (mounted) setState(() => _registered = id != null);
  }

  Future<void> _setUpThisScreen() async {
    final done = await showScreenSetupSheet(context);
    await _refreshRegistration();
    if (done && mounted) {
      setState(() => _error = null);
    }
  }

  InputDecoration _inputDec(
      BuildContext context, String label, IconData icon) {
    final colors = context.appColors;
    return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.textSecondary),
        prefixIcon: Icon(icon, color: colors.textSecondary),
        filled: true,
        fillColor: colors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.primary),
        ),
      );
  }
}
