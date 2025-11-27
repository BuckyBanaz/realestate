
import 'package:flutter/material.dart';


class NavigatorService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


  static Future<dynamic> pushNamed(String routeName, {dynamic arguments}) async {
    // if (routeName == AppRoutes.landingScreen) {
    //   // Create an instance of EnsureAuthMiddleware
    //   var authMiddleware = EnsureAuthMiddleware();
    //
    //   // Get the redirect route from the middleware
    //   RouteSettings? redirectRoute = authMiddleware.redirect(routeName);
    //
    //   if (redirectRoute != null) {
    //     // Redirect to the specified route
    //     return navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
    //   }
    // }

    return navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  static void goBack() {
    return navigatorKey.currentState?.pop();
  }

  static Future<dynamic> pushNamedAndRemoveUntil(String routeName, {bool routePredicate = false, dynamic arguments}) async {
    // if (routeName == AppRoutes.landingScreen) {
    //   // Create an instance of EnsureAuthMiddleware
    //   var authMiddleware = EnsureAuthMiddleware();
    //
    //   // Get the redirect route from the middleware
    //   RouteSettings? redirectRoute = authMiddleware.redirect(routeName);
    //
    //   if (redirectRoute != null) {
    //     // Redirect to the specified route
    //     return navigatorKey.currentState?.pushNamedAndRemoveUntil(routeName, (route) => routePredicate, arguments: arguments);
    //   }
    // }

    return navigatorKey.currentState?.pushNamedAndRemoveUntil(routeName, (route) => routePredicate, arguments: arguments);
  }

  static Future<dynamic> popAndPushNamed(String routeName, {dynamic arguments}) async {

    // if (routeName == AppRoutes.landingScreen) {
    //   // Create an instance of EnsureAuthMiddleware
    //   var authMiddleware = EnsureAuthMiddleware();
    //
    //   // Get the redirect route from the middleware
    //   RouteSettings? redirectRoute = authMiddleware.redirect(routeName);
    //
    //   if (redirectRoute != null) {
    //     // Redirect to the specified route
    //     return navigatorKey.currentState
    //         ?.popAndPushNamed(routeName, arguments: arguments);
    //   }
    // }

    return navigatorKey.currentState?.popAndPushNamed(routeName, arguments: arguments);
  }

  static Map<String, dynamic> getArguments(BuildContext context){
    return  ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  }
}
