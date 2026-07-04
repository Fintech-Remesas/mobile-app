import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/app_theme.dart';
import '../bloc/kyc_bloc.dart';

class KycStartPage extends StatefulWidget {
  const KycStartPage({super.key});

  @override
  State<KycStartPage> createState() => _KycStartPageState();
}

class _KycStartPageState extends State<KycStartPage> {
  int _step = 0; // 0 = Intro, 1 = DNI Front, 2 = Selfie, 3 = Loading
  bool _dniCaptured = false;
  bool _selfieCaptured = false;

  void _nextStep() {
    setState(() {
      _step++;
    });
  }

  void _submit() {
    _nextStep(); // Goes to loading step
    context.read<KycBloc>().add(const SubmitKycRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KycBloc, KycState>(
      listener: (context, state) {
        if (state is KycSubmitted || state is KycStatusLoaded) {
          // Si está simulando el delay y aprueba, redirige a approved
          context.go('/kyc-approved');
        } else if (state is KycError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
          );
          setState(() => _step = 2); // Regresar a la foto anterior
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.bgMain,
        appBar: AppBar(
          backgroundColor: AppTheme.bgMain,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, size: 24),
            color: AppTheme.primaryBlue,
            onPressed: () => context.go('/home'),
          ),
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildStepContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    if (_step == 0) {
      return _buildIntroStep(context);
    } else if (_step == 1) {
      return _buildCaptureStep(
        context: context,
        title: 'Foto de tu DNI',
        subtitle: 'Asegúrate de que los datos sean legibles y no haya reflejos.',
        icon: Icons.badge_outlined,
        isCaptured: _dniCaptured,
        onCapture: () => setState(() => _dniCaptured = true),
        onNext: _nextStep,
      );
    } else if (_step == 2) {
      return _buildCaptureStep(
        context: context,
        title: 'Tómate una selfie',
        subtitle: 'Ubícate en un lugar iluminado y quítate lentes o gorras.',
        icon: Icons.face_rounded,
        isCaptured: _selfieCaptured,
        onCapture: () => setState(() => _selfieCaptured = true),
        onNext: _submit,
      );
    } else {
      return _buildLoadingStep(context);
    }
  }

  Widget _buildIntroStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_outlined,
                size: 40, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 24),
          Text(
            'Verifica tu identidad',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Para proteger tu cuenta y cumplir con las regulaciones, necesitamos confirmar tu identidad.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: AppTheme.textDark,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text(
              'Empezar verificación',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/home'),
            child: Text(
              'Hacerlo más tarde',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCaptureStep({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCaptured,
    required VoidCallback onCapture,
    required VoidCallback onNext,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onCapture,
            child: Container(
              height: 200,
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
                borderRadius: BorderRadius.circular(20),
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
          const Spacer(),
          ElevatedButton(
            onPressed: isCaptured ? onNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text(
              'Continuar',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildLoadingStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: AppTheme.primaryBlue,
                backgroundColor: AppTheme.surfaceLight,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Procesando tus datos',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Estamos validando tu identidad mediante el servicio KYC seguro. Esto tomará unos segundos.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
