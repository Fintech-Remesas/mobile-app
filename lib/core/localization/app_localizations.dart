import 'package:flutter/material.dart';

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations('en');
  }

  final String locale;

  AppLocalizations(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'welcome_title': 'Instant transfers, 100% secure',
      'create_account': 'Create Account',
      'log_in': 'Log In',
      
      'profile_title': 'Profile',
      'verify_identity': 'Verificar Identidad',
      'completed': 'Completado',
      'bank_accounts': 'Cuentas Bancarias',
      'cards': 'Tarjetas',
      'security': 'Security',
      'limits': 'Limits',
      'general_settings': 'General Settings',
      'log_out': 'Log Out',
      
      'settings_title': 'General Settings',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'english': 'English',
      'spanish': 'Spanish',
      
      'home': 'Home',
      'transaction': 'Transaction',
      'history': 'History',
      'profile': 'Profile',
      
      'total_balance': 'Total Balance',
      'deposit': 'Deposit',
      'withdraw': 'Withdraw',
      'recent_transactions': 'Recent Transactions',
      'view_all': 'View All',
      'send_funds': 'Send Funds',
    },
    'es': {
      'welcome_title': 'Transferencias instantáneas, 100% seguras',
      'create_account': 'Crear Cuenta',
      'log_in': 'Iniciar Sesión',
      
      'profile_title': 'Perfil',
      'verify_identity': 'Verificar Identidad',
      'completed': 'Completado',
      'bank_accounts': 'Cuentas Bancarias',
      'cards': 'Tarjetas',
      'security': 'Seguridad',
      'limits': 'Límites',
      'general_settings': 'Configuraciones Generales',
      'log_out': 'Cerrar Sesión',
      
      'settings_title': 'Configuraciones Generales',
      'dark_mode': 'Modo Oscuro',
      'language': 'Idioma',
      'english': 'Inglés',
      'spanish': 'Español',
      
      'home': 'Inicio',
      'transaction': 'Transacción',
      'history': 'Historial',
      'profile': 'Perfil',
      
      'total_balance': 'Balance Total',
      'deposit': 'Depositar',
      'withdraw': 'Retirar',
      'recent_transactions': 'Transacciones Recientes',
      'view_all': 'Ver Todo',
      'send_funds': 'Enviar Fondos',
    },
  };

  String translate(String key) {
    return _localizedValues[locale]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale.languageCode);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
