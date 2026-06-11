
import 'package:go_router/go_router.dart';

// Importations de tes écrans
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/actor_choice_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/pending_approval_screen.dart';

import 'package:cartas/features/home/screens/home_screen.dart';
import 'package:cartas/features/herbier/screens/herbier_screen.dart';
import 'package:cartas/features/herbier/screens/plant_detail_screen.dart';
import 'package:cartas/features/herbier/screens/trousse_screen.dart';
import 'package:cartas/features/herbier/models/plant.dart';
import 'package:cartas/features/art_therapy/screens/art_therapy_screen.dart';
import 'package:cartas/features/art_therapy/screens/mood_selection_screen.dart';
import 'package:cartas/features/art_therapy/screens/interactive_coloring_screen.dart';
import 'package:cartas/features/gamification/screens/treasure_path_screen.dart';
import 'package:cartas/features/scanner/screens/scanner_screen.dart';
import 'package:cartas/features/shop/screens/shop_screen.dart';
import 'package:cartas/features/community/screens/community_screen.dart';

// --- Imports manquants ajoutés automatiquement ---
import 'package:cartas/features/chat_ia/screens/tawhida_chat_screen.dart';
import 'package:cartas/features/learning/screens/learning_home_screen.dart';
import 'package:cartas/features/learning/screens/module_details_screen.dart';
import 'package:cartas/features/learning/screens/interactive_lesson_screen.dart';
import 'package:cartas/features/learning/screens/quiz_screen.dart';
import 'package:cartas/features/learning/screens/interactive_story_screen.dart';
import 'package:cartas/features/learning/screens/recipe_exercise_screen.dart';
import 'package:cartas/features/phyto_lab/screens/health_profile_form_screen.dart';
import 'package:cartas/features/phyto_lab/screens/plant_selector_screen.dart';
import 'package:cartas/features/phyto_lab/screens/analysis_result_screen.dart';
import 'package:cartas/features/phyto_lab/screens/my_remedies_screen.dart';
import 'package:cartas/features/phyto_lab/screens/specialist_picker_screen.dart';
import 'package:cartas/features/consultation/screens/consultation_list_screen.dart';
import 'package:cartas/features/consultation/screens/my_consultations_screen.dart';
import 'package:cartas/features/consultation/screens/specialist_detail_screen.dart';
import 'package:cartas/features/consultation/screens/booking_screen.dart';
import 'package:cartas/features/specialist/screens/specialist_home_screen.dart';
import 'package:cartas/features/specialist/screens/specialist_agenda_screen.dart';
import 'package:cartas/features/specialist/screens/specialist_profile_screen.dart';
import 'package:cartas/features/specialist/screens/specialist_main_layout.dart';
import 'package:cartas/features/specialist/screens/consultation_requests_screen.dart';
import 'package:cartas/features/specialist/screens/confirmed_appointments_screen.dart';
import 'package:cartas/features/specialist/screens/remedy_validation_screen.dart';
import 'package:cartas/features/specialist/screens/ai_learning_dashboard_screen.dart';
import 'package:cartas/features/notifications/screens/notification_screen.dart';
import 'package:cartas/features/consultation/screens/payment_screen.dart';
import 'package:cartas/features/consultation/models/consultation_model.dart';
import 'package:cartas/features/art_therapy/screens/dashboard_art_therapist.dart';
import 'package:cartas/features/art_therapy/screens/workshops_list_art_therapist.dart';
import 'package:cartas/features/art_therapy/screens/participants_list_art_therapist.dart';
import 'package:cartas/features/art_therapy/screens/reviews_list_art_therapist.dart';
import 'package:cartas/features/art_therapy/screens/profile_edit_art_therapist.dart';
import 'package:cartas/features/profile/screens/profile_screen.dart';

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

      // 5.5 Pending Approval
      GoRoute(
        path: '/pending-approval',
        name: 'pending-approval',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'SPECIALIST';
          return PendingApprovalScreen(role: role);
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
        builder: (context, state) {
          final query = state.extra as String?;
          return HerbierScreen(initialSearchQuery: query);
        },
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

      // 10. Art-Thérapie (Espace Rachma)
      GoRoute(
        path: '/arttherapy',
        name: 'arttherapy',
        builder: (context, state) => const ArtTherapyScreen(),
      ),

      // 10b. Coloriage - Étape 1: Humeur
      GoRoute(
        path: '/arttherapy/mood',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return MoodSelectionScreen(
            title: extra['title'] as String,
            imagePath: extra['imagePath'] as String,
          );
        },
      ),

      // 10c. Coloriage - Étape 2: Dessin Interactif
      GoRoute(
        path: '/arttherapy/coloring/interactive',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return InteractiveColoringScreen(
            title: extra['title'] as String,
            imagePath: extra['imagePath'] as String,
            difficulty: extra['difficulty'] ?? 'Moyen',
            duration: extra['duration'] ?? '20 min',
            initialDrawingJson: extra['initialDrawingJson'] as String?,
          );
        },
      ),

      // 11. Tri9 el Kenz (Gamification)
      GoRoute(
        path: '/treasure',
        name: 'treasure',
        builder: (context, state) => const TreasurePathScreen(),
      ),

      // 12. Scanner Khaïel
      GoRoute(
        path: '/scanner',
        name: 'scanner',
        builder: (context, state) => const ScannerScreen(),
      ),

      // 13. Boutique
      GoRoute(
        path: '/shop',
        name: 'shop',
        builder: (context, state) => const ShopScreen(),
      ),

      // 14. Forum Communautaire
      GoRoute(
        path: '/forum',
        name: 'forum',
        builder: (context, state) => const CommunityScreen(),
      ),

      // --- Nouvelles Routes Ajoutées ---
      
      // Chat IA
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const TawhidaChatScreen(),
      ),

      // Learning (Modules Pédagogiques)
      GoRoute(
        path: '/learning',
        name: 'learning',
        builder: (context, state) => const LearningHomeScreen(),
      ),
      GoRoute(
        path: '/module-details',
        name: 'module-details',
        builder: (context, state) {
          final module = state.extra;
          return ModuleDetailsScreen(module: module as dynamic);
        },
      ),
      GoRoute(
        path: '/lesson',
        name: 'lesson',
        builder: (context, state) {
          final lesson = state.extra;
          return InteractiveLessonScreen(lesson: lesson as dynamic);
        },
      ),
      GoRoute(
        path: '/quiz',
        name: 'quiz',
        builder: (context, state) {
          final quiz = state.extra;
          return QuizScreen(quiz: quiz as dynamic);
        },
      ),
      GoRoute(
        path: '/maman-enfant-story',
        name: 'maman-enfant-story',
        builder: (context, state) => const InteractiveStoryScreen(),
      ),
      GoRoute(
        path: '/maman-enfant-recipe',
        name: 'maman-enfant-recipe',
        builder: (context, state) => const RecipeExerciseScreen(),
      ),

      // Phyto Lab
      GoRoute(
        path: '/lab',
        name: 'lab',
        builder: (context, state) => const HealthProfileFormScreen(),
      ),
      GoRoute(
        path: '/plant-selector',
        name: 'plant-selector',
        builder: (context, state) => const PlantSelectorScreen(),
      ),
      GoRoute(
        path: '/analysis-result',
        name: 'analysis-result',
        builder: (context, state) => const AnalysisResultScreen(),
      ),
      GoRoute(
        path: '/my-remedies',
        name: 'my-remedies',
        builder: (context, state) => const MyRemediesScreen(),
      ),
      GoRoute(
        path: '/select-specialist',
        name: 'select-specialist',
        builder: (context, state) => const SpecialistPickerScreen(),
      ),

      // Consultations
      GoRoute(
        path: '/consultation',
        name: 'consultation',
        builder: (context, state) => const ConsultationListScreen(),
      ),
      GoRoute(
        path: '/my-consultations',
        name: 'my-consultations',
        builder: (context, state) => const MyConsultationsScreen(),
      ),
      GoRoute(
        path: '/specialist-detail',
        name: 'specialist-detail',
        builder: (context, state) {
          final specialist = state.extra;
          return SpecialistDetailScreen(specialist: specialist as dynamic);
        },
      ),
      GoRoute(
        path: '/booking',
        name: 'booking',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return BookingScreen(
            specialist: data['specialist'],
            preselectedSlot: data['slot'],
          );
        },
      ),

      // Specialist & Therapist & Profile
      ShellRoute(
        builder: (context, state, child) {
          return SpecialistMainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/specialist-home',
            name: 'specialist-home',
            builder: (context, state) => const SpecialistHomeScreen(),
          ),
          GoRoute(
            path: '/specialist-agenda',
            name: 'specialist-agenda',
            builder: (context, state) => const SpecialistAgendaScreen(),
          ),
          GoRoute(
            path: '/specialist-profile',
            name: 'specialist-profile',
            builder: (context, state) => const SpecialistProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/consultation-requests',
        name: 'consultation-requests',
        builder: (context, state) => const ConsultationRequestsScreen(),
      ),
      GoRoute(
        path: '/confirmed-appointments',
        name: 'confirmed-appointments',
        builder: (context, state) => const ConfirmedAppointmentsScreen(),
      ),
      GoRoute(
        path: '/remedy-validation',
        name: 'remedy-validation',
        builder: (context, state) => const RemedyValidationScreen(),
      ),
      GoRoute(
        path: '/ai-dashboard',
        name: 'ai-dashboard',
        builder: (context, state) => const AILearningDashboardScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/consultation/payment',
        name: 'consultation-payment',
        builder: (context, state) {
          final consultation = state.extra as ConsultationModel;
          return PaymentScreen(consultation: consultation);
        },
      ),
      GoRoute(
        path: '/therapist-home',
        name: 'therapist-home',
        builder: (context, state) => const DashboardArtTherapist(),
      ),
      GoRoute(
        path: '/art-therapy-workshops',
        name: 'art-therapy-workshops',
        builder: (context, state) => const WorkshopsListArtTherapist(),
      ),
      GoRoute(
        path: '/art-therapy-participants',
        name: 'art-therapy-participants',
        builder: (context, state) => const ParticipantsListArtTherapist(),
      ),
      GoRoute(
        path: '/art-therapy-reviews',
        name: 'art-therapy-reviews',
        builder: (context, state) => const ReviewsListArtTherapist(),
      ),
      GoRoute(
        path: '/art-therapy-profile',
        name: 'art-therapy-profile',
        builder: (context, state) => const ProfileEditArtTherapist(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}