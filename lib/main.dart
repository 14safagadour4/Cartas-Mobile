import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/localization/language_provider.dart';
import 'package:cartas/core/routes/app_router.dart';
import 'package:cartas/features/herbier/providers/trousse_provider.dart';
import 'package:cartas/features/herbier/providers/plant_provider.dart';
import 'package:cartas/features/art_therapy/providers/art_therapy_provider.dart';
import 'package:cartas/features/shop/provider/cart_provider.dart';
import 'package:cartas/features/community/providers/community_provider.dart';
import 'package:cartas/features/phyto_lab/providers/phyto_lab_provider.dart';
import 'package:cartas/features/learning/providers/learning_provider.dart';
import 'package:cartas/features/consultation/providers/consultation_provider.dart';
import 'package:cartas/features/specialist/providers/specialist_provider.dart';

import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation de Stripe avec une clé publique de test
  Stripe.publishableKey ='pk_test_51TTV4KEkzNZ3b2RgeALNM9ePD2ozWgD3imLbZvA7D45SQXuCHIodSTvspPpG3jt9mk2XOqTQ2SIA3iPcfstYKPvw00iDOmcijc'; // À remplacer par ta vraie clé publique si nécessaire
  await Stripe.instance.applySettings();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Erreur initialisation Firebase: $e");
  }
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
        ChangeNotifierProvider(create: (_) => ArtTherapyProvider()..fetchAllData()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => PhytoLabProvider()),
        ChangeNotifierProvider(create: (_) => LearningProvider()),
        ChangeNotifierProvider(create: (_) => ConsultationProvider()),
        ChangeNotifierProvider(create: (_) => SpecialistProvider()),
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