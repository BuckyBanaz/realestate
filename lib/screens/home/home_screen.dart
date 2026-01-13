import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/screens/widgets/helpers.dart';

import 'modules/categories.dart';
import 'modules/featured_properties_list.dart';
import 'modules/greeting_text.dart';
import 'modules/promotional_banners.dart';
import 'modules/search_text_field.dart';
import 'modules/section_title.dart';
import 'modules/top_locations_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  double _p(BuildContext c, double value) {
    // ignore: prefer_const_declarations
    final designWidth = 375.0;
    final w = MediaQuery.of(c).size.width;
    return (value / designWidth) * w;
  }

  @override
  Widget build(BuildContext context) {
    final pw = (double v) => ScreenUtil().scaleWidth > 0 ? v.w : _p(context, v);
    final ph = (double v) => ScreenUtil().scaleHeight > 0
        ? v.h
        : (v / 812.0) * MediaQuery.of(context).size.height;
    // ignore: unused_local_variable
    final ps = (double v) => ScreenUtil().scaleText > 0
        ? v.sp
        : v * MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      // backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenW = constraints.maxWidth;

          return SingleChildScrollView(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                stagger(0, const GreetingText()),
                SizedBox(height: ph(15)),
                stagger(
                    1, const SearchTextField()),

                SizedBox(height: ph(25)),
                stagger(
                    2, PromotionalBanners(responsiveWidth: screenW)),
                SizedBox(height: ph(20)),
                stagger(
                    3, const SectionTitle(title: "OUR PROPERTIES")),
                SizedBox(height: ph(8)),
                stagger(
                    4, const Categories()),
                SizedBox(height: ph(20)),
                stagger(
                  5, SectionTitle(
                    title: "TOP LOCATIONS",
                    actionText: "Explore",
                    onActionTap: () {
                      Get.toNamed(AppRoutes.topLocations);
                    },
                  ),
                ),
                SizedBox(height: ph(8)),
                stagger(
                    6, const TopLocationsSection()),
                SizedBox(height: ph(20)),
                stagger(
                  7,SectionTitle(
                    title: "FEATURED PROPERTIES",
                    actionText: "View all",
                    onActionTap: () {
                      Get.toNamed(AppRoutes.featured);
                    },
                  ),
                ),
                SizedBox(height: ph(8)),
                stagger(
                    8, const FeaturedPropertiesList()),
              ],
            ),
          );
        },
      ),
    );
  }
}
