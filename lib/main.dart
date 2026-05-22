import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/localization/language_provider.dart';
import 'package:cartas/core/routes/app_router.dart';
import 'package:cartas/features/specialist/providers/specialist_provider.dart';
import 'package:cartas/features/herbier/providers/trousse_provider.dart';
import 'package:cartas/features/herbier/providers/plant_provider.dart';
import 'package:cartas/features/consultation/providers/consultation_provider.dart';
import 'package:cartas/features/learning/providers/learning_provider.dart';
import 'package:cartas/features/phyto_lab/providers/phyto_lab_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cartas/firebase_options.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialiser Stripe avec la clé publique (mode test)
  Stripe.publishableKey = 'pk_test_51TTV4KEkzNZ3b2RgeALNM9ePD2ozWgD3imLbZvA7D45SQXuCHIodSTvspPpG3jt9mk2XOqTQ2SIA3iPcfstYKPvw00iDOmcijc';
  
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
        ChangeNotifierProvider(create: (_) => SpecialistProvider()),
        ChangeNotifierProvider(create: (_) => ConsultationProvider()),
        ChangeNotifierProvider(create: (_) => LearningProvider()),
        ChangeNotifierProvider(create: (_) => PhytoLabProvider()),
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