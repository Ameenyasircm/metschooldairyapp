import 'package:flutter/material.dart';
import 'package:met_school/core/utils/navigation/navigation_helper.dart';
import 'package:met_school/features/about/about_us_screen.dart';
import 'package:met_school/features/auth/presentation/screens/login_screen.dart';
import 'package:met_school/features/home/views/home/widgets/home_grid.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/app_navigation.dart';
import '../../../modules/teacher/home/presentation/screens/teacher_navbar_screen.dart';
import '../contact_screen/contact_us_screen.dart';
import '../gallary/gallery_screen.dart';
import 'home_provider.dart';
import 'widgets/carousel.dart';
import 'widgets/home_widgets.dart';

class HomeScreen extends StatelessWidget {
  static const Color primary = Color(0xff00796B);

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We use context.watch to rebuild when data changes
    final provider = context.watch<HomeProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text("Met School Payyanad",
            style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
        actions: [
          const Icon(Icons.search, color: Colors.black),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: (){
              // NavigationService.push(context,LoginScreen());
              NavigationService.push(context,TeacherNavbarScreen(staffName: '',));
            },
            child: const CircleAvatar(
                backgroundColor: primary,
                radius: 18,
                child: Icon(Icons.person, color: Colors.white, size: 18)
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Achievers Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Top Achievers",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                    provider.activeGroupTitle,
                    style: const TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.bold)
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Your auto-scrolling widget
            const WinnerCarousel(),

            const SizedBox(height: 25),

            // Quick Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                QuickActionIcon(icon: Icons.info_outline, label: "ABOUT US",onTap: (){
                  callNext(AboutUsScreen(), context);
                },),
                 QuickActionIcon(icon: Icons.photo_library_outlined, label: "GALLERY",onTap: (){
                   callNext(AcademicGalleryScreen(), context);
                 },),
                 QuickActionIcon(icon: Icons.alternate_email, label: "CONTACT",onTap: (){
                   callNext(ContactUsScreen(), context);
                 },),
                 QuickActionIcon(icon: Icons.payments_outlined, label: "FEE PAY",onTap: (){},),
              ],
            ),

            const SizedBox(height: 25),

            // Admission Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Admission Open",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Secure your child's future at the atelier of excellence.",
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: (){},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primary,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text("Apply Now →"),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),
            SchoolHighlights(),
            const SizedBox(height: 25),

            const Text("Upcoming Events",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // ✅ THE FIX: Map from 'events', not 'winners'
            ...provider.sampleEvents.map((e) => EventCard(event: e)).toList(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}