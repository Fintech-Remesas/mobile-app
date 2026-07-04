import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/app_theme.dart';
import '../../../../core/data/session_manager.dart';
import '../bloc/auth_bloc.dart';
import '../../../kyc/presentation/bloc/kyc_bloc.dart';
import '../../../payment_methods/presentation/bloc/add_bank_account_bloc.dart';
import '../../../payment_methods/presentation/bloc/add_card_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1 — Personal data
  final _step1Key = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  
  // Step 4 — Bank Account
  final _step4Key = GlobalKey<FormState>();
  final _bankNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _aliasCtrl = TextEditingController();
  final _customBankCtrl = TextEditingController();
  String _selectedAccountType = 'SAVINGS';
  String _selectedCurrency = 'USD';
  String _selectedCountry = 'PE';
  String? _selectedBank;

  // Step 5 — Card
  final _step5Key = GlobalKey<FormState>();
  final _cardNumberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _cardholderNameCtrl = TextEditingController();

  // Step 2 — Account & security
  final _step2Key = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _country = 'PE';
  String _language = 'es';
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  static const _countries = [
    ('PE', 'Perú'),
    ('MX', 'México'),
    ('CO', 'Colombia'),
    ('AR', 'Argentina'),
    ('CL', 'Chile'),
    ('US', 'United States'),
    ('ES', 'España'),
  ];

  static const _languages = [
    ('es', 'Español'),
    ('en', 'English'),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _aliasCtrl.dispose();
    _customBankCtrl.dispose();
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _cardholderNameCtrl.dispose();
    super.dispose();
  }

  void _goNext() {
    // Only used for step 1
    if (_step1Key.currentState!.validate()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = 1);
    }
  }

  void _goToStep(int stepIndex) {
    if (stepIndex == 5) {
      final authState = context.read<AuthBloc>().state;
      final userId = authState is AuthRegisterSuccess ? authState.createdUserId : 'User';
      _showSuccessDialog(userId);
      return;
    }
    _pageController.animateToPage(
      stepIndex,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = stepIndex);
  }

  void _goBack() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep -= 1);
  }

  void _submit() {
    if (!_step2Key.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          RegisterSubmitted(
            email: _emailCtrl.text.trim(),
            username: _usernameCtrl.text.trim(),
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
            country: _country,
            preferredLanguage: _language,
            initialPassword: _passwordCtrl.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegisterSuccess) {
          _goToStep(2); // Al finalizar registro y auto-login, pasamos al KYC
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13)),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.bgMain,
        appBar: AppBar(
          backgroundColor: AppTheme.bgMain,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: AppTheme.primaryBlue,
            onPressed: () {
              if (_currentStep > 0 && _currentStep < 5) {
                _goBack();
              } else {
                context.pop();
              }
            },
          ),
          title: Text(
            'Crear cuenta',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // ── Step indicator ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: _StepIndicator(current: _currentStep),
            ),
            const SizedBox(height: 4),

            // ── Pages ───────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1(
                    formKey: _step1Key,
                    firstNameCtrl: _firstNameCtrl,
                    lastNameCtrl: _lastNameCtrl,
                    usernameCtrl: _usernameCtrl,
                    phoneCtrl: _phoneCtrl,
                    onNext: _goNext,
                  ),
                  _Step2(
                    formKey: _step2Key,
                    emailCtrl: _emailCtrl,
                    passwordCtrl: _passwordCtrl,
                    confirmCtrl: _confirmCtrl,
                    country: _country,
                    language: _language,
                    countries: _countries,
                    languages: _languages,
                    obscurePass: _obscurePass,
                    obscureConfirm: _obscureConfirm,
                    onCountryChanged: (v) => setState(() => _country = v!),
                    onLanguageChanged: (v) => setState(() => _language = v!),
                    onTogglePass: () =>
                        setState(() => _obscurePass = !_obscurePass),
                    onToggleConfirm: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    onSubmit: _submit,
                  ),
                  _Step3(
                    onNext: () => _goToStep(3),
                    onSkip: () => _goToStep(3),
                  ),
                  _Step4(
                    formKey: _step4Key,
                    bankNameCtrl: _bankNameCtrl,
                    accountNumberCtrl: _accountNumberCtrl,
                    aliasCtrl: _aliasCtrl,
                    customBankCtrl: _customBankCtrl,
                    selectedAccountType: _selectedAccountType,
                    selectedCurrency: _selectedCurrency,
                    selectedCountry: _selectedCountry,
                    selectedBank: _selectedBank,
                    onAccountTypeChanged: (v) => setState(() => _selectedAccountType = v!),
                    onCurrencyChanged: (v) => setState(() => _selectedCurrency = v!),
                    onCountryChanged: (v) => setState(() => _selectedCountry = v!),
                    onBankChanged: (v) => setState(() => _selectedBank = v),
                    onNext: () => _goToStep(4),
                    onSkip: () => _goToStep(4),
                  ),
                  _Step5(
                    formKey: _step5Key,
                    cardNumberCtrl: _cardNumberCtrl,
                    expiryCtrl: _expiryCtrl,
                    cvvCtrl: _cvvCtrl,
                    cardholderNameCtrl: _cardholderNameCtrl,
                    onFinish: () => _goToStep(5),
                    onSkip: () => _goToStep(5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(String userId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppTheme.bgMain,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppTheme.accentGreen, size: 38),
              ),
              const SizedBox(height: 18),
              Text(
                '¡Cuenta creada!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu cuenta fue registrada exitosamente.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: [
                    Text('ID de usuario',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(
                      userId,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () {
                    SessionManager.instance.clear();
                    Navigator.of(context).pop();
                    context.go('/login');
                  },
                  child: const Text('Ir al login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step indicator
// ─────────────────────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int current;
  const _StepIndicator({required this.current});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StepDot(index: 0, current: current, label: 'Personal'),
          _divider(current >= 1),
          _StepDot(index: 1, current: current, label: 'Cuenta'),
          _divider(current >= 2),
          _StepDot(index: 2, current: current, label: 'Identidad'),
          _divider(current >= 3),
          _StepDot(index: 3, current: current, label: 'Banco'),
          _divider(current >= 4),
          _StepDot(index: 4, current: current, label: 'Tarjeta'),
        ],
      ),
    );
  }

  Widget _divider(bool active) {
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: active ? AppTheme.primaryBlue : AppTheme.borderColor,
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final int current;
  final String label;
  const _StepDot(
      {required this.index, required this.current, required this.label});

  @override
  Widget build(BuildContext context) {
    final done = current > index;
    final active = current == index;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (done || active) ? AppTheme.primaryBlue : AppTheme.surfaceLight,
            border: Border.all(
              color: (done || active) ? AppTheme.primaryBlue : AppTheme.borderColor,
              width: 2,
            ),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 16)
                : Text(
                    '${index + 1}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: (done || active)
                ? AppTheme.primaryBlue
                : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — Datos personales
// ─────────────────────────────────────────────────────────────────────────────
class _Step1 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController usernameCtrl;
  final TextEditingController phoneCtrl;
  final VoidCallback onNext;

  const _Step1({
    required this.formKey,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.usernameCtrl,
    required this.phoneCtrl,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              context,
              icon: Icons.person_outline_rounded,
              title: 'Datos personales',
              subtitle: 'Cuéntanos un poco sobre ti',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: firstNameCtrl,
                    label: 'Nombre',
                    icon: Icons.badge_outlined,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    controller: lastNameCtrl,
                    label: 'Apellido',
                    icon: Icons.badge_outlined,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Field(
              controller: usernameCtrl,
              label: 'Nombre de usuario',
              icon: Icons.alternate_email_rounded,
              hint: 'juan.perez',
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                if (v.contains(' ')) return 'No puede tener espacios';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _Field(
              controller: phoneCtrl,
              label: 'Teléfono (opcional)',
              icon: Icons.phone_outlined,
              hint: '+51 912 345 678',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            _PrimaryButton(
              label: 'Continuar',
              onPressed: onNext,
              trailingIcon: Icons.arrow_forward_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — Cuenta y seguridad
// ─────────────────────────────────────────────────────────────────────────────
class _Step2 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final String country;
  final String language;
  final List<(String, String)> countries;
  final List<(String, String)> languages;
  final bool obscurePass;
  final bool obscureConfirm;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onLanguageChanged;
  final VoidCallback onTogglePass;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSubmit;

  const _Step2({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.country,
    required this.language,
    required this.countries,
    required this.languages,
    required this.obscurePass,
    required this.obscureConfirm,
    required this.onCountryChanged,
    required this.onLanguageChanged,
    required this.onTogglePass,
    required this.onToggleConfirm,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              context,
              icon: Icons.lock_outline_rounded,
              title: 'Cuenta y seguridad',
              subtitle: 'Configura tu email, país y contraseña',
            ),
            const SizedBox(height: 24),

            // Email
            _Field(
              controller: emailCtrl,
              label: 'Correo electrónico',
              icon: Icons.email_outlined,
              hint: 'juan@ejemplo.com',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                if (!v.contains('@') || !v.contains('.')) {
                  return 'Email inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // País e idioma en fila
            Row(
              children: [
                Expanded(
                  child: _DropdownField<String>(
                    label: 'País',
                    icon: Icons.public_rounded,
                    value: country,
                    items: countries
                        .map((e) => DropdownMenuItem(
                              value: e.$1,
                              child: Text(e.$2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: AppTheme.textDark)),
                            ))
                        .toList(),
                    onChanged: onCountryChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DropdownField<String>(
                    label: 'Idioma',
                    icon: Icons.language_rounded,
                    value: language,
                    items: languages
                        .map((e) => DropdownMenuItem(
                              value: e.$1,
                              child: Text(e.$2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: AppTheme.textDark)),
                            ))
                        .toList(),
                    onChanged: onLanguageChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Contraseña
            _PasswordField(
              controller: passwordCtrl,
              label: 'Contraseña',
              obscure: obscurePass,
              onToggle: onTogglePass,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                if (v.length < 8) return 'Mínimo 8 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _PasswordField(
              controller: confirmCtrl,
              label: 'Confirmar contraseña',
              obscure: obscureConfirm,
              onToggle: onToggleConfirm,
              validator: (v) =>
                  v != passwordCtrl.text ? 'Las contraseñas no coinciden' : null,
            ),
            const SizedBox(height: 32),

            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return _PrimaryButton(
                  label: 'Crear cuenta',
                  onPressed: isLoading ? null : onSubmit,
                  isLoading: isLoading,
                );
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: AppTheme.textSecondary),
                    children: const [
                      TextSpan(text: '¿Ya tienes cuenta? '),
                      TextSpan(
                        text: 'Iniciar sesión',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

Widget _sectionHeader(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(
          fontSize: 14, color: AppTheme.textDark),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13, color: AppTheme.textSecondary),
        hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13, color: AppTheme.borderColor),
        prefixIcon: Icon(icon, color: AppTheme.primaryBlue, size: 18),
        filled: true,
        fillColor: AppTheme.bgMain,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorStyle: GoogleFonts.plusJakartaSans(fontSize: 11),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(
          fontSize: 14, color: AppTheme.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13, color: AppTheme.textSecondary),
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            color: AppTheme.primaryBlue, size: 18),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppTheme.textSecondary,
            size: 18,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppTheme.bgMain,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorStyle: GoogleFonts.plusJakartaSans(fontSize: 11),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: AppTheme.textSecondary, size: 18),
      style: GoogleFonts.plusJakartaSans(
          fontSize: 13, color: AppTheme.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12, color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, color: AppTheme.primaryBlue, size: 18),
        filled: true,
        fillColor: AppTheme.bgMain,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? trailingIcon;

  const _PrimaryButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentGreen,
          foregroundColor: AppTheme.textDark,
          disabledBackgroundColor: AppTheme.borderColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.textDark,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 6),
                    Icon(trailingIcon, size: 18, color: AppTheme.textDark),
                  ],
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 — KYC
// ─────────────────────────────────────────────────────────────────────────────
class _Step3 extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _Step3({required this.onNext, required this.onSkip});

  @override
  State<_Step3> createState() => _Step3State();
}

class _Step3State extends State<_Step3> {
  int _kycSubStep = 0;
  bool _dniCaptured = false;
  bool _selfieCaptured = false;

  void _nextSubStep() {
    setState(() {
      _kycSubStep++;
    });
  }

  void _submit() {
    context.read<KycBloc>().add(const SubmitKycRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KycBloc, KycState>(
      listener: (context, state) {
        if (state is KycSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Identidad verificada exitosamente')),
          );
          widget.onNext();
        } else if (state is KycError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
          );
          setState(() => _kycSubStep = 2);
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              context,
              icon: Icons.verified_user_outlined,
              title: 'Verificar Identidad',
              subtitle: 'Requerido para realizar transacciones (KYC)',
            ),
            const SizedBox(height: 32),
            
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildSubStepContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubStepContent(BuildContext context) {
    if (_kycSubStep == 0) {
      return _buildIntro();
    } else if (_kycSubStep == 1) {
      return _buildCapture(
        title: 'Foto de tu DNI',
        subtitle: 'Asegúrate de que los datos sean legibles y no haya reflejos.',
        icon: Icons.badge_outlined,
        isCaptured: _dniCaptured,
        onCapture: () => setState(() => _dniCaptured = true),
        onNext: _nextSubStep,
      );
    } else {
      return _buildCapture(
        title: 'Tómate una selfie',
        subtitle: 'Ubícate en un lugar iluminado y quítate lentes o gorras.',
        icon: Icons.face_rounded,
        isCaptured: _selfieCaptured,
        onCapture: () => setState(() => _selfieCaptured = true),
        onNext: _submit,
      );
    }
  }

  Widget _buildIntro() {
    return Column(
      key: const ValueKey(0),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              const Icon(Icons.document_scanner_outlined, size: 64, color: AppTheme.primaryBlue),
              const SizedBox(height: 16),
              Text(
                'Para mantener tu cuenta segura y cumplir con las regulaciones, necesitamos verificar tu identidad.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _PrimaryButton(
          label: 'Empezar verificación',
          onPressed: _nextSubStep,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TextButton(
            onPressed: widget.onSkip,
            child: const Text('Omitir por ahora', style: TextStyle(color: Colors.grey)),
          ),
        ),
      ],
    );
  }

  Widget _buildCapture({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCaptured,
    required VoidCallback onCapture,
    required VoidCallback onNext,
  }) {
    return Column(
      key: ValueKey(title),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: onCapture,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: isCaptured
                  ? AppTheme.accentGreen.withOpacity(0.1)
                  : AppTheme.surfaceLight,
              border: Border.all(
                color: isCaptured
                    ? AppTheme.accentGreen
                    : AppTheme.borderColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: isCaptured
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 48, color: AppTheme.accentGreen),
                        SizedBox(height: 12),
                        Text('Captura exitosa',
                            style: TextStyle(
                                color: AppTheme.accentGreen,
                                fontWeight: FontWeight.bold)),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 48, color: AppTheme.primaryBlue),
                        const SizedBox(height: 12),
                        const Text('Toca para tomar foto',
                            style: TextStyle(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        BlocBuilder<KycBloc, KycState>(
          builder: (context, state) {
            final isLoading = state is KycLoading;
            return _PrimaryButton(
              label: 'Continuar',
              onPressed: (isCaptured && !isLoading) ? onNext : null,
              isLoading: isLoading,
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 4 — Bank Account
// ─────────────────────────────────────────────────────────────────────────────
class _Step4 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController bankNameCtrl;
  final TextEditingController accountNumberCtrl;
  final TextEditingController aliasCtrl;
  final TextEditingController customBankCtrl;
  
  final String selectedAccountType;
  final String selectedCurrency;
  final String selectedCountry;
  final String? selectedBank;

  final ValueChanged<String?> onAccountTypeChanged;
  final ValueChanged<String?> onCurrencyChanged;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onBankChanged;

  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _Step4({
    required this.formKey,
    required this.bankNameCtrl,
    required this.accountNumberCtrl,
    required this.aliasCtrl,
    required this.customBankCtrl,
    required this.selectedAccountType,
    required this.selectedCurrency,
    required this.selectedCountry,
    required this.selectedBank,
    required this.onAccountTypeChanged,
    required this.onCurrencyChanged,
    required this.onCountryChanged,
    required this.onBankChanged,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> banks = [
      {'name': 'Banco de Crédito del Perú (BCP)', 'domain': 'viabcp.com'},
      {'name': 'BBVA', 'domain': 'bbva.pe'},
      {'name': 'Interbank', 'domain': 'interbank.pe'},
      {'name': 'Scotiabank', 'domain': 'scotiabank.com.pe'},
      {'name': 'Otro', 'domain': ''},
    ];

    return BlocListener<AddBankAccountBloc, AddBankAccountState>(
      listener: (context, state) {
        if (state is AddBankAccountSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cuenta añadida exitosamente')),
          );
          onNext();
        } else if (state is AddBankAccountFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(
                context,
                icon: Icons.account_balance_outlined,
                title: 'Cuenta Bancaria',
                subtitle: 'Agrega una cuenta para retirar fondos',
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: selectedBank,
                hint: const Text('Nombre del banco'),
                decoration: const InputDecoration(labelText: 'Banco', border: OutlineInputBorder()),
                items: banks.map((bank) {
                  return DropdownMenuItem<String>(
                    value: bank['name'],
                    child: Text(bank['name']!),
                  );
                }).toList(),
                onChanged: onBankChanged,
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              if (selectedBank == 'Otro') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: customBankCtrl,
                  decoration: const InputDecoration(labelText: 'Ingresa el nombre del banco', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: accountNumberCtrl,
                decoration: const InputDecoration(labelText: 'Número de cuenta', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedAccountType,
                decoration: const InputDecoration(labelText: 'Tipo de cuenta', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'SAVINGS', child: Text('Ahorros')),
                  DropdownMenuItem(value: 'CHECKING', child: Text('Corriente')),
                ],
                onChanged: onAccountTypeChanged,
              ),
              const SizedBox(height: 32),
              BlocBuilder<AddBankAccountBloc, AddBankAccountState>(
                builder: (context, state) {
                  final isLoading = state is AddBankAccountLoading;
                  return _PrimaryButton(
                    label: 'Guardar y Continuar',
                    onPressed: isLoading
                        ? null
                        : () {
                            if (!formKey.currentState!.validate()) return;
                            String finalBankName = selectedBank == 'Otro' ? customBankCtrl.text.trim() : selectedBank ?? '';
                            context.read<AddBankAccountBloc>().add(
                              AddBankAccountSubmitted(
                                bankName: finalBankName,
                                accountNumber: accountNumberCtrl.text.replaceAll(' ', ''),
                                accountType: selectedAccountType,
                                currency: selectedCurrency,
                                country: selectedCountry,
                                alias: aliasCtrl.text.trim(),
                              ),
                            );
                          },
                    isLoading: isLoading,
                  );
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: onSkip,
                  child: const Text('Omitir por ahora', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 5 — Card
// ─────────────────────────────────────────────────────────────────────────────
class _Step5 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController cardNumberCtrl;
  final TextEditingController expiryCtrl;
  final TextEditingController cvvCtrl;
  final TextEditingController cardholderNameCtrl;
  
  final VoidCallback onFinish;
  final VoidCallback onSkip;

  const _Step5({
    required this.formKey,
    required this.cardNumberCtrl,
    required this.expiryCtrl,
    required this.cvvCtrl,
    required this.cardholderNameCtrl,
    required this.onFinish,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddCardBloc, AddCardState>(
      listener: (context, state) {
        if (state is AddCardSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarjeta añadida exitosamente')),
          );
          onFinish();
        } else if (state is AddCardFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(
                context,
                icon: Icons.credit_card_outlined,
                title: 'Tarjeta',
                subtitle: 'Agrega una tarjeta para depositar fondos',
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: cardNumberCtrl,
                decoration: const InputDecoration(labelText: 'Número de tarjeta', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                maxLength: 19,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: expiryCtrl,
                      decoration: const InputDecoration(labelText: 'MM/YY', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: cvvCtrl,
                      decoration: const InputDecoration(labelText: 'CVV', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: cardholderNameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre en la tarjeta', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 32),
              BlocBuilder<AddCardBloc, AddCardState>(
                builder: (context, state) {
                  final isLoading = state is AddCardLoading;
                  return _PrimaryButton(
                    label: 'Finalizar',
                    onPressed: isLoading
                        ? null
                        : () {
                            if (!formKey.currentState!.validate()) return;
                            
                            final expiryParts = expiryCtrl.text.split('/');
                            int expiryMonth = 1;
                            int expiryYear = 2024;
                            if (expiryParts.length == 2) {
                              expiryMonth = int.tryParse(expiryParts[0]) ?? 1;
                              expiryYear = 2000 + (int.tryParse(expiryParts[1]) ?? 24);
                            }

                            context.read<AddCardBloc>().add(
                              AddCardSubmitted(
                                cardNumber: cardNumberCtrl.text.replaceAll(' ', ''),
                                expiryMonth: expiryMonth,
                                expiryYear: expiryYear,
                                cardBrand: 'VISA',
                                cardType: 'CREDIT',
                                cardholderName: cardholderNameCtrl.text.trim(),
                              ),
                            );
                          },
                    isLoading: isLoading,
                  );
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: onSkip,
                  child: const Text('Omitir por ahora', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
