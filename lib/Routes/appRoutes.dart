import 'package:get/get.dart';
import 'package:realestate/screens/auth/otp_screen.dart';
import 'package:realestate/screens/auth/register_screen.dart';
import 'package:realestate/screens/dashboard/dashboard_screen.dart';
import 'package:realestate/screens/splash_screen.dart';
import 'package:realestate/screens/toplocations/top_locations_screen.dart';
import 'package:realestate/screens/toplocations/locations_details_screen.dart';
import 'package:realestate/screens/featured/featured_screen.dart';
import 'package:realestate/screens/property/property_deatils_screen.dart';
import 'package:realestate/screens/search/search_screen.dart';
import 'package:realestate/screens/notification/notification_screen.dart';
import 'package:realestate/screens/transaction/transaction_details_screen.dart';

import 'package:realestate/screens/property/property_map_view_screen.dart';
import 'package:realestate/screens/property/property_equiery_form.dart';
import 'package:realestate/screens/property/subcategory_screen.dart';
import 'package:realestate/screens/property/site_plan_view_screen.dart';

import 'package:realestate/screens/news/news_list_screen.dart';
import 'package:realestate/screens/news/news_detail_screen.dart';
import '../screens/auth/login_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const signup = '/signup';
  static const otp = '/otp';
  static const home = '/home';
  static const topLocations = '/topLocations';
  static const locationDetail = '/locationDetail';
  static const featured = '/featured';
  static const propertyDetail = '/propertyDetail';
  static const search = '/search';
  static const notification = '/notification';
  static const enquiry = '/enquiry';
  static const propertyMap = '/propertyMap';
  static const subCategory = '/subCategory';
  static const sitePlan = '/sitePlan';
  static const newsList = '/newsList';
  static const newsDetail = '/newsDetail';
  static const transactionDetail = '/transactionDetail';

  static get routes => [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: login, page: () => LoginScreen(), transition: Transition.rightToLeft),
    GetPage(name: signup, page: () => RegisterScreen(), transition: Transition.rightToLeft),
    GetPage(name: home, page: () => DashboardScreen(), transition: Transition.rightToLeft),
    GetPage(
      name: otp,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return OTPScreen(
          contact: args['contact'] ?? "",
          isEmail: args['isEmail'] ?? false,
          isForgotPassword: args['isForgotPassword'] ?? false,
        );
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(name: topLocations, page: () => TopLocationsScreen(), transition: Transition.rightToLeft),
    GetPage(name: locationDetail, page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return LocationDetailScreen(
          locationName: args['locationName'],
          rank: args['rank'],
          heroImage: args['heroImage'] ?? "",
          subtitle: args['subtitle'] ?? "",
          addressId: args['addressId'],
        );
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(name: featured, page: () => FeaturedScreen(), transition: Transition.rightToLeft),
    GetPage(name: propertyDetail, page: () {
        final propertyId = Get.arguments as int;
        return PropertyDetailScreen(propertyId: propertyId);
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(name: search, page: () => SearchScreen(), transition: Transition.rightToLeft),
    GetPage(name: notification, page: () => NotificationScreen(), transition: Transition.rightToLeft),
    GetPage(name: propertyMap, page: () => PropertyMapViewScreen(), transition: Transition.rightToLeft),
    GetPage(name: enquiry, page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return EnquiryFormScreen(
          propertyId: args['propertyId'] ?? 0,
          propertyName: args['propertyName'] ?? "Property Enquiry",
          propertyLocation: args['propertyLocation'] ?? "Unknown Location",
        );
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(name: subCategory, page: () => PlotsOnlyScreen(), transition: Transition.rightToLeft),
    GetPage(name: sitePlan, page: () {
        final imagePath = Get.arguments as String;
        return SitePlanViewScreen(imagePath: imagePath);
      },
      transition: Transition.fade,
    ),
    GetPage(name: newsList, page: () => const NewsListScreen(), transition: Transition.rightToLeft),
    GetPage(name: newsDetail, page: () => const NewsDetailScreen(), transition: Transition.rightToLeft),
    GetPage(name: transactionDetail, page: () => const TransactionDetailsScreen(), transition: Transition.rightToLeft),
  ];
}
