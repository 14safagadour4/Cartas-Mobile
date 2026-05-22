
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
import '../../features/auth/screens/pending_approval_screen.dart';
import '../../features/specialist/screens/specialist_home_screen.dart';
import '../../features/specialist/screens/specialist_agenda_screen.dart';
import '../../features/specialist/screens/specialist_profile_screen.dart';
import '../../features/specialist/screens/remedy_validation_screen.dart';
import '../../features/specialist/screens/consultation_requests_screen.dart';
import '../../features/specialist/screens/confirmed_appointments_screen.dart';
import '../../features/specialist/screens/specialist_main_layout.dart';
import '../../features/art_therapy/screens/dashboard_art_therapist.dart';
import '../../features/art_therapy/screens/workshops_list_art_therapist.dart';
import '../../features/art_therapy/screens/participants_list_art_therapist.dart';
import '../../features/art_therapy/screens/profile_edit_art_therapist.dart';
import '../../features/art_therapy/screens/reviews_list_art_therapist.dart';
import '../../features/chat_ia/screens/tawhida_chat_screen.dart';
import '../../features/consultation/screens/consultation_list_screen.dart';
import '../../features/consultation/screens/specialist_detail_screen.dart';
import '../../features/consultation/screens/booking_screen.dart';
import '../../features/consultation/screens/my_consultations_screen.dart';
import '../../features/consultation/models/specialist_public_model.dart';
import '../../features/consultation/models/consultation_model.dart';
import '../../features/learning/screens/learning_home_screen.dart';
import '../../features/learning/screens/category_modules_screen.dart';
import '../../features/learning/models/learning_models.dart';
import '../../features/learning/screens/module_details_screen.dart';
import '../../features/learning/screens/interactive_lesson_screen.dart';
import '../../features/learning/screens/quiz_screen.dart';
import '../../features/learning/screens/interactive_story_screen.dart';
import '../../features/learning/screens/recipe_exercise_screen.dart';
import '../../features/consultation/screens/payment_screen.dart';
import '../../features/notifications/screens/notification_screen.dart';
import '../../features/phyto_lab/screens/health_profile_form_screen.dart';
import '../../features/phyto_lab/screens/plant_selector_screen.dart';
import '../../features/phyto_lab/screens/analysis_result_screen.dart';
import '../../features/phyto_lab/screens/specialist_picker_screen.dart';
import '../../features/phyto_lab/screens/my_remedies_screen.dart';
import '../../features/specialist/screens/ai_learning_dashboard_screen.dart';

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

      // 10. En attente de validation
      GoRoute(
        path: '/pending-approval',
        name: 'pending-approval',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'SPECIALIST';
          return PendingApprovalScreen(role: role);
        },
      ),

      // 11. Espace Spécialiste (Shell pour la navigation persistante)
      ShellRoute(
        builder: (context, state, child) => SpecialistMainLayout(child: child),
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

      // 12. Validation Remèdes (Accès via Drawer)
      GoRoute(
        path: '/remedy-validation',
        name: 'remedy-validation',
        builder: (context, state) => const RemedyValidationScreen(),
      ),

      // 13. Demandes de Consultations
      GoRoute(
        path: '/consultation-requests',
        name: 'consultation-requests',
        builder: (context, state) => const ConsultationRequestsScreen(),
      ),

      // 14. Rendez-vous Confirmés
      GoRoute(
        path: '/confirmed-appointments',
        name: 'confirmed-appointments',
        builder: (context, state) => const ConfirmedAppointmentsScreen(),
      ),

      // 15. Espace Art-Thérapeute
      GoRoute(
        path: '/therapist-home',
        name: 'therapist-home',
        builder: (context, state) => const DashboardArtTherapist(),
      ),
      GoRoute(
        path: '/art-therapy/workshops',
        name: 'art-therapy-workshops',
        builder: (context, state) => const WorkshopsListArtTherapist(),
      ),
      GoRoute(
        path: '/art-therapy/participants',
        name: 'art-therapy-participants',
        builder: (context, state) => const ParticipantsListArtTherapist(),
      ),
      GoRoute(
        path: '/art-therapy/profile',
        name: 'art-therapy-profile',
        builder: (context, state) => const ProfileEditArtTherapist(),
      ),
      GoRoute(
        path: '/art-therapy/reviews',
        name: 'art-therapy-reviews',
        builder: (context, state) => const ReviewsListArtTherapist(),
      ),
      // 16. Chat IA (Tawhida+)
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const TawhidaChatScreen(),
      ),

      // 17. Consultation — Liste des spécialistes
      GoRoute(
        path: '/consultation',
        name: 'consultation',
        builder: (context, state) => const ConsultationListScreen(),
      ),

      // 18. Consultation — Profil spécialiste
      GoRoute(
        path: '/specialist-detail',
        name: 'specialist-detail',
        builder: (context, state) {
          final specialist = state.extra as SpecialistPublicModel;
          return SpecialistDetailScreen(specialist: specialist);
        },
      ),

      // 19. Consultation — Prise de rendez-vous
      GoRoute(
        path: '/booking',
        name: 'booking',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BookingScreen(
            specialist: extra['specialist'] as SpecialistPublicModel,
            preselectedSlot: extra['slot'] as String?,
          );
        },
      ),

      // 20. Mes Consultations
      GoRoute(
        path: '/my-consultations',
        name: 'my-consultations',
        builder: (context, state) => const MyConsultationsScreen(),
      ),

      // 21. Apprendre (Centre d'apprentissage)
      GoRoute(
        path: '/learning',
        name: 'learning',
        builder: (context, state) => const LearningHomeScreen(),
      ),

      // 22. Liste des modules d'une catégorie
      GoRoute(
        path: '/category-modules',
        name: 'category-modules',
        builder: (context, state) {
          final category = state.extra as LearningCategory;
          return CategoryModulesScreen(category: category);
        },
      ),

      // 23. Détail d'un module et ses leçons
      GoRoute(
        path: '/module-details',
        name: 'module-details',
        builder: (context, state) {
          final module = state.extra as LearningModule;
          return ModuleDetailsScreen(module: module);
        },
      ),

      // 24. Leçon Interactive
      GoRoute(
        path: '/lesson',
        name: 'lesson',
        builder: (context, state) {
          final lesson = state.extra as Lesson;
          return InteractiveLessonScreen(lesson: lesson);
        },
      ),

      // 25. Quiz
      GoRoute(
        path: '/quiz',
        name: 'quiz',
        builder: (context, state) {
          final quiz = state.extra as Quiz;
          return QuizScreen(quiz: quiz);
        },
      ),

      // 26. Histoire Interactive Maman-Enfant
      GoRoute(
        path: '/maman-enfant-story',
        name: 'maman-enfant-story',
        builder: (context, state) => const InteractiveStoryScreen(),
      ),
      // 27. Atelier Recette Maman-Enfant
      GoRoute(
        path: '/maman-enfant-recipe',
        name: 'maman-enfant-recipe',
        builder: (context, state) => const RecipeExerciseScreen(),
      ),
      // 28. Notifications
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      // 29. Paiement Consultation
      GoRoute(
        path: '/consultation/payment',
        name: 'consultation-payment',
        builder: (context, state) {
          final consultation = state.extra as ConsultationModel;
          return PaymentScreen(consultation: consultation);
        },
      ),
      // 30. Phyto Lab
      GoRoute(
        path: '/phyto-lab',
        name: 'phyto-lab',
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
        path: '/select-specialist',
        name: 'select-specialist',
        builder: (context, state) => const SpecialistPickerScreen(),
      ),
      GoRoute(
        path: '/my-remedies',
        name: 'my-remedies',
        builder: (context, state) => const MyRemediesScreen(),
      ),
      GoRoute(
        path: '/ai-dashboard',
        name: 'ai-dashboard',
        builder: (context, state) => const AILearningDashboardScreen(),
      ),
    ],
  );
}