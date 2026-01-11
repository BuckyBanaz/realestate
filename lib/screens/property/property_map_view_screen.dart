import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';



class PropertyMapViewScreen extends StatelessWidget {
  const PropertyMapViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).iconTheme.color),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Detail / View on Map",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Full Map Background
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              "assets/images/download.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // Top Facilities Chips
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _facilityChip(context, "1 Hospital", Icons.local_hospital_outlined),
                _facilityChip(context, "2 Gas Stations", Icons.local_gas_station_outlined),
                _facilityChip(context, "1 Schools", Icons.school_outlined),
              ],
            ),
          ),

          // Agent Pin (Top-leftish)
          const Positioned(
            top: 120,
            left: 80,
            child: _AgentPin(),
          ),

          // Property Pins
          const Positioned(
            top: 280,
            left: 60,
            child: _PropertyPin(),
          ),
          const Positioned(
            top: 320,
            right: 80,
            child: _PropertyPin(),
          ),
          const Positioned(
            bottom: 380,
            right: 40,
            child: _PropertyPin(),
          ),
          const Positioned(
            bottom: 420,
            left: 100,
            child: _PropertyPin(),
          ),

          // Main Property Marker (Center Bottom)
          Positioned(
            bottom: 300,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child:  Icon(Icons.home, color: secondary, size: 40),
            ),
          ),

          // Green Route Line (Dummy Overlay)
          Center(
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 600),
              painter: GreenRoutePainter(),
            ),
          ),

          // Location Detail Card (Bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 20),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    "Location detail",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(IconlyLight.location, color: Colors.grey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15),
                            children: [
                              TextSpan(text: "St. Ciloko Timur, Kec. Pancoran, Jakarta Selatan, Indonesia 12770"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Right Compass Button
          Positioned(
            bottom: 180,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Theme.of(context).cardColor,
              elevation: 6,
              child: Icon(Icons.explore, color: Theme.of(context).iconTheme.color),
              onPressed: () {},
            ),
          ),

          // Jakarta Location Chip
          Positioned(
            bottom: 280,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children:  [
                  Icon(Icons.location_on, color: secondary, size: 18),
                  SizedBox(width: 6),
                  Text("Jakarta, Indonesia", style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  Icon(Icons.keyboard_arrow_down, color: secondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _facilityChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: primary, size: 18),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
        ],
      ),
    );
  }
}

// Agent Pin
class _AgentPin extends StatelessWidget {
  const _AgentPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: const CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage("https://randomuser.me/api/portraits/men/45.jpg"),
      ),
    );
  }
}

// Property Pin
class _PropertyPin extends StatelessWidget {
  const _PropertyPin();

  @override
  Widget build(BuildContext context) {
    return  Icon(Icons.location_city, color: secondary, size: 40);
  }
}

// Green Curved Route
class GreenRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.8)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.25)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.4,
        size.width * 0.5,
        size.height * 0.7,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}