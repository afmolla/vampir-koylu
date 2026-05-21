import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'services/session_store.dart';

class VampirKoyluApp extends StatefulWidget {
  const VampirKoyluApp({super.key});

  @override
  State<VampirKoyluApp> createState() => _VampirKoyluAppState();
}

class _VampirKoyluAppState extends State<VampirKoyluApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final code = await SessionStore().getLocale();
    if (!mounted) return;
    setState(() => _locale = Locale(code));
  }

  void _setLocale(Locale locale) {
    setState(() => _locale = locale);
    SessionStore().setLocale(locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vampir Köylü',
      theme: AppTheme.dark(),
      locale: _locale,
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
      builder: (context, child) {
        return LocaleSwitcher(
          onLocaleChanged: _setLocale,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class LocaleSwitcher extends InheritedWidget {
  const LocaleSwitcher({
    super.key,
    required this.onLocaleChanged,
    required super.child,
  });

  final void Function(Locale locale) onLocaleChanged;

  static LocaleSwitcher? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleSwitcher>();
  }

  @override
  bool updateShouldNotify(LocaleSwitcher oldWidget) => false;
}
