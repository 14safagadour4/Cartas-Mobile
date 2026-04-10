import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/localization/language_provider.dart';
import 'package:cartas/core/routes/app_router.dart';
import 'package:cartas/features/herbier/providers/trousse_provider.dart';
import 'package:cartas/features/herbier/providers/plant_provider.dart';

void main() {
  runApp(const CartasApp());
}

class CartasApp extends StatelessWidget {
  const CartasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => TrousseProvider()),
        ChangeNotifierProvider(create: (_) => PlantProvider()..fetchPlants()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp.router(
            title: 'CARTAS',
            debugShowCheckedModeBanner: false,
            locale: languageProvider.locale,
            supportedLocales: const [Locale('fr'), Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: AppRouter.router,
            theme: ThemeData(
              fontFamily: 'Poppins',
              useMaterial3: true,
            ),
          );
        },
      ),
    );
  }
}