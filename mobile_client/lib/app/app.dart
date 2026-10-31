import 'package:flutter/material.dart';
import 'package:mobile_client/app/router.dart';
import 'package:mobile_client/core/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile_client/core/theme/theme_provider.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  final colors = Provider.of<ThemeProvider>(context).currentTheme;
    return MaterialApp.router(
      title: 'NoteCore',
      // debugShowCheckedModeBanner: false,

      theme: AppTheme.getLightTheme(colors),
      darkTheme: AppTheme.getDarkTheme(colors),
      themeMode: ThemeMode.system,

      routerConfig: appRouter,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale("en");
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale("en");
      },
    );
  }
}
