import 'utils/import_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeController());
  Get.put(UserController());
  Get.put(AuthController());
  Get.put(EventController());
  Get.put(InviteController());
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
          ],
        ));
  }
}
