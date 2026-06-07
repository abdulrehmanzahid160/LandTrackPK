import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'citizen/citizen_dashboard.dart';
import 'officer/officer_dashboard.dart';
import '../theme/app_theme.dart';
import '../widgets/bilingual_label.dart';
import '../widgets/page_transitions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cnicController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Citizen';
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _cnicController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.login(
        _cnicController.text.trim(),
        _passwordController.text,
        _selectedRole,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        await SessionService.saveSession(
          cnic: _cnicController.text.trim(),
          fullName: result['full_name'],
          role: result['role'],
          citizenId: result['citizen_id'],
        );

        if (!mounted) return;

        final destination = result['role'] == 'Officer'
            ? const OfficerDashboard()
            : const CitizenDashboard();

        Navigator.pushReplacement(
          context,
          DocumentFlipPageRoute(page: destination),
        );
      } else {
        _showSnackBar(result['message'] ?? 'Invalid credentials', AppColors.error);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Connection error. Is the server running?', AppColors.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.account_balance_outlined, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text('LandTrackPK', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Image.asset('assets/images/logo.png', width: 32, height: 32, errorBuilder: (_,__,___) => const SizedBox()),
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.02,
                child: Image.asset(
                  'assets/images/guilloche_pattern.png',
                  repeat: ImageRepeat.repeat,
                  errorBuilder: (_,__,___) => const SizedBox(),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.edgeMargin),
                child: Container(
                  decoration: AppDecorations.certificateCard,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.onSurface, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.security, size: 40, color: AppColors.onSurface),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Secure Access Portal',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Divider(color: AppColors.tertiary),
                        Text(
                          'GOVERNMENT OF PAKISTAN',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.tertiary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const Divider(color: AppColors.tertiary),
                        const SizedBox(height: AppSpacing.xl),
                        
                        // Role Toggle
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              _buildRoleButton('Citizen', 'شہری'),
                              _buildRoleButton('Officer', 'افسر'),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        const BilingualLabel(englishText: 'CNIC NUMBER', urduText: 'شناختی کارڈ نمبر'),
                        TextFormField(
                          controller: _cnicController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _CnicFormatter(),
                          ],
                          decoration: const InputDecoration(
                            hintText: '00000-0000000-0',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (value.length != 15) return 'Invalid length';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        const BilingualLabel(englishText: 'PASSWORD', urduText: 'پاس ورڈ'),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.onPrimary))
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('LOGIN TO SYSTEM'),
                                      SizedBox(width: AppSpacing.md),
                                      Icon(Icons.login),
                                    ],
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.lg),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: Text(
                            'THIS IS A SECURE GOVERNMENT SYSTEM.\nUNAUTHORIZED ACCESS IS STRICTLY PROHIBITED AND MONITORED.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOut).fadeIn(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(String role, String urdu) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Text(
                role.toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                urdu,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected ? AppColors.onPrimary.withOpacity(0.8) : AppColors.outline,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CnicFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 5 == 0 && nonZeroIndex != text.length && nonZeroIndex < 6) {
        buffer.write('-');
      } else if (nonZeroIndex == 12 && nonZeroIndex != text.length) {
        buffer.write('-');
      }
    }

    var string = buffer.toString();
    if (string.length > 15) {
      return oldValue;
    }

    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
