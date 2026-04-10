
import 'package:go_router/go_router.dart';

// Importations de tes écrans
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/actor_choice_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';

import 'package:cartas/features/home/screens/home_screen.dart';
import 'package:cartas/features/herbier/screens/herbier_screen.dart';
import 'package:cartas/features/herbier/screens/plant_detail_screen.dart';
import 'package:cartas/features/herbier/screens/trousse_screen.dart';
import 'package:cartas/features/herbier/models/plant.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // 1. Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // 3. Choix de l'acteur (Rôle)
      GoRoute(
        path: '/actor-choice',
        name: 'actor-choice',
        builder: (context, state) => const ActorChoiceScreen(),
      ),

      // 4. Connexion
      GoRoute(
        path: '/login/:role',
        name: 'login',
        builder: (context, state) {
          final role = state.pathParameters['role'] ?? 'utilisatrice';
          return LoginScreen(role: role);
        },
      ),

      // 5. Inscription
      GoRoute(
        path: '/signup/:role',
        name: 'signup',
        builder: (context, state) {
          final role = state.pathParameters['role'] ?? 'utilisatrice';
          return SignupScreen(role: role);
        },
      ),

      // 6. Home
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),  
      ),

      // 7. Herbier Digital
      GoRoute(
        path: '/herbier',
        name: 'herbier',
        builder: (context, state) => const HerbierScreen(),
      ),

      // 8. Détail Plante
      GoRoute(
        path: '/plant-detail',
        name: 'plant-detail',
        builder: (context, state) {
          final plant = state.extra as Plant;
          return PlantDetailScreen(plant: plant);
        },
      ),

      // 9. Ma Trousse
      GoRoute(
        path: '/trousse',
        name: 'trousse',
        builder: (context, state) => const TrousseScreen(),
      ),
    ],
  );
}