import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:realestate/screens/auth/otp_screen.dart';
import 'package:realestate/screens/auth/register_screen.dart';
import 'package:realestate/screens/dashboard/dashboard_screen.dart';
import 'package:realestate/screens/splash_screen.dart';

import '../screens/auth/login_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const signup = '/signup';
  static const otp = '/otp';
  static const home = '/home';

  static get routes => [

    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: login, page: () => LoginScreen(),transition: Transition.rightToLeft),
    GetPage(name: signup, page: () => RegisterScreen(),transition: Transition.rightToLeft),
    GetPage(name: home, page: () => DashboardScreen(),transition: Transition.rightToLeft),
    GetPage(name: otp, page: () => OTPScreen(contact: "chetan@gmail.com"),transition: Transition.rightToLeft),

  ];
}
