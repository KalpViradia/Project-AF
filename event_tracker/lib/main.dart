import 'utils/import_export.dart';
import 'service/category_service.dart';
import 'view/forgot_password_page.dart';
import 'view/reset_password_page.dart';
import 'view/recurring_events_page.dart';
import 'view/recurring_event_form_page.dart';
import 'view/event_comments_page.dart';

void main() async {
  print('Starting app initialization...');
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  print('Initializing storage service...');
  await StorageService.init();
  
  // Initialize controllers
  print('Initializing controllers...');
  Get.put(ThemeController());
  Get.put(UserController());
  Get.put(AuthController());
  
  // Setup API service
  print('Setting up API service...');
  ApiService.setupDio();
  
  // Initialize services
  print('Initializing services...');
  Get.put(CategoryService());
  Get.put(EventService());
  
  // Initialize event-related controllers
  print('Initializing event controllers...');
  Get.put(EventController());
  Get.put(InviteController());
  
  print('Starting app...');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
          title: 'Event Tracker',
          theme: themeController.customTheme ?? lightTheme,
          darkTheme: darkTheme,
          themeMode: themeController.customTheme != null
              ? ThemeMode.light
              : themeController.themeMode,
          debugShowCheckedModeBanner: false,
          initialRoute: ROUTE_SPLASH,
          getPages: [
            GetPage(name: ROUTE_SPLASH, page: () => const SplashPage()),
            GetPage(name: ROUTE_THEME_CUSTOMIZATION, page: () => const ThemeCustomizationPage()),
            GetPage(name: ROUTE_LOGIN, page: () => const LoginPage()),
            GetPage(name: ROUTE_SIGNUP, page: () => const SignupPage()),
            GetPage(name: ROUTE_FORGOT_PASSWORD, page: () => const ForgotPasswordPage()),
            GetPage(name: ROUTE_RESET_PASSWORD, page: () => const ResetPasswordPage()),
            GetPage(name: ROUTE_HOME, page: () => HomePage(), middlewares: [AuthMiddleware()]),
            GetPage(name: ROUTE_PROFILE, page: () => const ProfilePage(), middlewares: [AuthMiddleware()]),
            GetPage(name: ROUTE_EDIT_PROFILE, page: () => const EditProfilePage(), middlewares: [AuthMiddleware()]),
            GetPage(
              name: ROUTE_CREATE_EVENT,
              page: () => const EventFormPage(),
              middlewares: [AuthMiddleware()],
            ),
            GetPage(
              name: ROUTE_EVENT_EDIT,
              page: () => EventFormPage(event: Get.arguments as Event),
              middlewares: [AuthMiddleware()],
            ),
            GetPage(
              name: ROUTE_EVENT_DETAILS,
              page: () => EventDetailsPage(event: Get.arguments as Event),
              middlewares: [AuthMiddleware()],
            ),
            GetPage(
              name: ROUTE_INVITE_USERS,
              page: () => InviteUsersPage(
                eventId: Get.arguments['eventId'] as String,
                eventTitle: Get.arguments['eventTitle'] as String,
              ),
              middlewares: [AuthMiddleware()],
            ),
            GetPage(
              name: ROUTE_EVENT_INVITES,
              page: () => EventInvitesPage(eventId: Get.arguments as String),
              middlewares: [AuthMiddleware()],
            ),
            GetPage(
              name: ROUTE_MY_INVITES,
              page: () => const MyInvitesPage(),
              middlewares: [AuthMiddleware()],
            ),
            GetPage(
              name: ROUTE_INVISIBLE_EVENTS,
              page: () => InvisibleEventsPage(),
              middlewares: [AuthMiddleware()],
            ),
            GetPage(
              name: ROUTE_ABOUT_US,
              page: () => AboutUsPage(),
              middlewares: [AuthMiddleware()],
            ),
            GetPage(
              name: ROUTE_RECURRING_EVENTS,
              page: () => RecurringEventsPage(),
              middlewares: [AuthMiddleware()],
            ),
            GetPage(
              name: ROUTE_CREATE_RECURRING_EVENT,
              page: () => const RecurringEventFormPage(),
              middlewares: [AuthMiddleware()],
            ),
            GetPage(
              name: ROUTE_EDIT_RECURRING_EVENT,
              page: () => RecurringEventFormPage(event: Get.arguments as Event),
              middlewares: [AuthMiddleware()],
            ),
            GetPage(
              name: ROUTE_EVENT_COMMENTS,
              page: () => EventCommentsPage(event: Get.arguments as Event),
              middlewares: [AuthMiddleware()],
            ),
          ],
        ));
  }
}
