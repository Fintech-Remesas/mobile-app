import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';

import '../../../../theme/app_theme.dart';
import '../bloc/kyc_bloc.dart';

class KycStartPage extends StatefulWidget {
  const KycStartPage({super.key});

  @override
  State<KycStartPage> createState() => _KycStartPageState();
}

class _KycStartPageState extends State<KycStartPage> {
  int _step = 0; // 0 = Intro, 1 = DNI Front, 2 = DNI Back, 3 = Selfie, 4 = Loading
  bool _dniCaptured = false;
  bool _dniBackCaptured = false;
  bool _selfieCaptured = false;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        await _setupCameraController(isSelfie: false);
      }
    } catch (e) {
      debugPrint('Error init cameras: $e');
    }
  }

  Future<void> _setupCameraController({required bool isSelfie}) async {
    if (_cameras == null || _cameras!.isEmpty) return;
    
    if (mounted) setState(() => _isCameraInitialized = false);
    
    CameraDescription? targetCamera;
    if (isSelfie) {
      targetCamera = _cameras!.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => _cameras!.first);
    } else {
      targetCamera = _cameras!.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => _cameras!.first);
    }

    await _cameraController?.dispose();
    
    _cameraController = CameraController(
      targetCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    
    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera controller: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      _step++;
    });
    if (_step == 1 || _step == 2) {
      _setupCameraController(isSelfie: false);
    } else if (_step == 3) {
      _setupCameraController(isSelfie: true);
    }
  }

  Future<void> _captureImage({required bool isSelfie, required VoidCallback onCaptured}) async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        await _cameraController!.takePicture();
        onCaptured();
      } catch (e) {
        debugPrint('Error tomando foto: $e');
        onCaptured(); // Fallback
      }
    } else {
      onCaptured(); // Fallback
    }
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
          setState(() => _step = 3); // Regresar a la foto anterior
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
        title: 'Foto de tu DNI (Frente)',
        subtitle: 'Asegúrate de que los datos sean legibles y no haya reflejos.',
        icon: Icons.badge_outlined,
        isCaptured: _dniCaptured,
        onCapture: () => _captureImage(isSelfie: false, onCaptured: () => setState(() => _dniCaptured = true)),
        onNext: _nextStep,
      );
    } else if (_step == 2) {
      return _buildCaptureStep(
        context: context,
        title: 'Foto de tu DNI (Reverso)',
        subtitle: 'Asegúrate de que los datos de la parte posterior sean legibles.',
        icon: Icons.credit_card_outlined,
        isCaptured: _dniBackCaptured,
        onCapture: () => _captureImage(isSelfie: false, onCaptured: () => setState(() => _dniBackCaptured = true)),
        onNext: _nextStep,
      );
    } else if (_step == 3) {
      return _buildCaptureStep(
        context: context,
        title: 'Tómate una selfie',
        subtitle: 'Ubícate en un lugar iluminado y quítate lentes o gorras.',
        icon: Icons.face_rounded,
        isCaptured: _selfieCaptured,
        onCapture: () => _captureImage(isSelfie: true, onCaptured: () => setState(() => _selfieCaptured = true)),
        onNext: _submit,
        isSelfie: true,
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
    bool isSelfie = false,
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
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: onCapture,
              child: Container(
                height: isSelfie ? 220 : 200,
                width: isSelfie ? 220 : double.infinity,
                decoration: BoxDecoration(
                  shape: isSelfie ? BoxShape.circle : BoxShape.rectangle,
                  color: isCaptured
                      ? AppTheme.accentGreen.withOpacity(0.1)
                      : AppTheme.surfaceLight,
                  border: Border.all(
                    color: isCaptured
                        ? AppTheme.accentGreen
                        : AppTheme.borderColor,
                    width: 2,
                  ),
                  borderRadius: isSelfie ? null : BorderRadius.circular(20),
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
                      : (_isCameraInitialized && _cameraController != null)
                        ? SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: isSelfie
                                ? ClipOval(child: CameraPreview(_cameraController!))
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: CameraPreview(_cameraController!),
                                  ),
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
