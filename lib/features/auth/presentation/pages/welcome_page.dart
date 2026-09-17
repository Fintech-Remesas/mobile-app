import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../theme/app_theme.dart';

class WelcomePage extends StatelessWidget {
  static const _logoPath = 'assets/icon/logo-Photoroom.png';

  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.surfaceLight, AppTheme.bgMain],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: Center(
                  child: Image.asset(
                    _logoPath,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      loc.translate('welcome_title'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: 17,
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/register'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                        ),
                        child: Text(loc.translate('create_account')),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.push('/login'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(loc.translate('log_in')),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
