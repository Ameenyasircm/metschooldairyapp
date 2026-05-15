import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:met_school/core/utils/loader/customLoader.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/router/app_navigation.dart';
import '../../../../providers/auth_provider.dart';
import '../../../auth/presentation/screens/role_selection_screen.dart';
import '../../../modules/parent/views/parent_bottom_nav_screen.dart';
import '../../../modules/parent/views/parent_select_child_screen.dart';
import '../../../modules/teacher/home/presentation/screens/teacher_home_screen.dart';
import '../../../../core/utils/navigation/navigation_helper.dart';
import '../../../../features/auth/presentation/screens/login_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Sample data ──────────────────────────────────────────────────────────
  final List<Map<String, String>> _events = [
    {'title': 'Arts Club Inauguration', 'date': '12-Apr'},
    {'title': 'Arts Club Inauguration', 'date': '12-Apr'},
    {'title': 'Arts Club Inauguration', 'date': '12-Apr'},
  ];

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Scrollable content ──────────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroBanner(),
                const SizedBox(height: 10),
                _buildTopStudents(),
                const SizedBox(height: 10),
                _buildEvents(),
                const SizedBox(height: 15),
                _buildPhotoGrid(),
                const SizedBox(height: 15),
                _buildAboutSection(),
                const SizedBox(height: 15),
                _buildContactRow(),
                const SizedBox(height: 15),
                _buildSocialIcons(),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Sticky login button ─────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildLoginButton(),
          ),
        ],
      ),
    );
  }

  // ── Hero / Header ─────────────────────────────────────────────────────────
// ── Hero / Header ─────────────────────────────────────────────────────────
  Widget _buildHeroBanner() {
    // We use a SizedBox + Stack here so the layout engine knows exactly
    // how much space the hero + the overlapping collage takes up vertically.
    return SizedBox(
      height: 365.h, // 350 (Hero image) + 90 (Collage overflow)
      child: Stack(
        children: [
          // 1. Hero Background & Title Card
          Container(
            height: 350.h,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/homeMainImage.png'), // your image path
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFE5D3D8),
                      Color(0xFFC7D6E8),
                      Color(0xFFDFE2E8),
                      Color(0xFFD3C5D3),
                    ],
                    stops: [0.0, 0.25, 0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 23.8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(
                        "assets/images/metSchoolPng.png",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'MET PUBLIC SCHOOL',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'PAYYANAD',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. The Overlapping Rotated Collage
          Positioned(
            top: 250, // Pushes it down so it overlaps the bottom edge of the 350px hero image
            left: 0,
            right: 0,
            child: _buildImageCollage(),
          ),
        ],
      ),
    );
  }

  // ── Rotated Image Collage ─────────────────────────────────────────────────
  Widget _buildImageCollage() {
    // Increased height to 220 so the dropped right image has plenty of room
    return Container(
      // color: Colors.red,
      height: 220,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // 1. Left Image (Back layer)
          Positioned(
            left: 17,
            top: 15, // Sits higher than the right image
            child: Transform.rotate(
              angle: -14 * (math.pi / 180), // -14 degrees (steeper angle)
              child: _buildCollageCard(
                imagePath: 'assets/images/img1.png',
                width: 130, // Landscape
                height: 90,
              ),
            ),
          ),

          // 2. Right Image (Back layer)
          Positioned(
            right: 18,
            top: 15, // Pushed significantly lower to match Figma
            child: Transform.rotate(
              angle: -3 * (math.pi / 180), // rotate left
              child: _buildCollageCard(
                imagePath: 'assets/images/img3.png',
                width: 130, // Exact landscape ratio from Figma
                height: 90,
              ),
            ),
          ),

          // 3. Center Image (Front layer!)
          // Placed LAST in the children list so it renders ON TOP of the others
          Positioned(
            top: 0,
            child: _buildCollageCard(
              imagePath: 'assets/images/img2.png',
              width: 90,
              height: 110, // Tallest, portrait ratio
            ),
          ),
        ],
      ),
    );
  }  Widget _buildCollageCard({
    required String imagePath,
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        color: Colors.grey.shade300, // Placeholder color before image loads
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      // Remove this child Center icon once you uncomment the DecorationImage above
      // child: const Center(
      //   child: Icon(Icons.image, size: 32, color: Colors.white70),
      // ),
    );
  }
  Widget _greyImageBox({EdgeInsets margin = EdgeInsets.zero}) {
    return Expanded(
      child: Container(
        margin: margin,
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.image, size: 24, color: Colors.white54),
        ),
      ),
    );
  }

  // ── Top Students ──────────────────────────────────────────────────────────

// --- Updated: Parent list widget with unique rotation logic ---
  Widget _buildTopStudents() {
    // A list of student image assets (using generic names for this example)
    final List<String> studentImages = [
      'assets/images/std1.png',
      'assets/images/std2.png',
      'assets/images/std3.png',
      'assets/images/std4.png',
      // Add more as needed
    ];

    // Placeholder list to match your original itemCount of 5
    // for this example, we'll just cycle the 4 images.
    final List<String> cyclicalImages = List.generate(
      5, // original item count
          (index) => studentImages[index % studentImages.length],
    );

    final math.Random random = math.Random();

    return Column(
      children: [
        // Trophy icon
        const Text('🏆', style: TextStyle(fontSize: 32)),
        const SizedBox(height: 6),
        const Text(
          'Top Students',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal avatar list
        SizedBox(
          height: 110, // Increased list height to fit the larger, angled frames
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cyclicalImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              // Generate a random angle for each avatar
              // between -8 degrees and +8 degrees for a subtle, varied tilt.
              final double degrees = (random.nextDouble() * 16) - 8;
              final double radians = degrees * (math.pi / 180);

              return Transform.rotate(
                angle: radians,
                child: _buildStudentAvatar(cyclicalImages[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Updated: Avatar definition with larger sizes and organic layering ---
  Widget _buildStudentAvatar(String studentImagePath) {
    return SizedBox(
      width: 110, // Increased overall width
      height: 110, // Increased overall height
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. The Student Image (Bottom Layer)
          ClipOval(
            // Round the inner image organically to fit behind the frame
            child: Image.asset(
              studentImagePath,
              width: 90, // Keep the student image slightly smaller than the frame
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey.shade300), // Placeholder if asset fails
            ),
          ),

          // 2. The Yellow Border Asset (Top Layer)
          Image.asset(
            // Changed generic border asset name to a more descriptive specific asset file
            'assets/images/yellowBorder.png',
            width: 105,
            height: 105,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
  // ── Events ────────────────────────────────────────────────────────────────
  Widget _buildEvents() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(_events.length, (i) => _buildEventTile(_events[i])),
        ],
      ),
    );
  }

  Widget _buildEventTile(Map<String, String> event) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              // Event icon placeholder
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event['date']!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade200, height: 1),
      ],
    );
  }

  // ── Photo Grid ────────────────────────────────────────────────────────────
// ── Photo Grid ────────────────────────────────────────────────────────────
  Widget _buildPhotoGrid() {
    // Replace these with your actual image paths
    final List<String> imagePaths = [
      'assets/images/gallary1.png',
      'assets/images/gallary2.png',
      'assets/images/gallary3.png',
      'assets/images/gallary4.png',
      'assets/images/gallary5.png',

    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StaggeredGrid.count(
        crossAxisCount: 6, // 6 columns total
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          // Row 1: 2 items (takes 3 columns each)
          StaggeredGridTile.extent(
            crossAxisCellCount: 3,
            mainAxisExtent: 130, // height
            child: _photoCard(imagePaths[0]),
          ),
          StaggeredGridTile.extent(
            crossAxisCellCount: 3,
            mainAxisExtent: 130,
            child: _photoCard(imagePaths[1]),
          ),

          // Row 2: 3 items (takes 2 columns each)
          StaggeredGridTile.extent(
            crossAxisCellCount: 2,
            mainAxisExtent: 100, // height
            child: _photoCard(imagePaths[2]),
          ),
          StaggeredGridTile.extent(
            crossAxisCellCount: 2,
            mainAxisExtent: 100,
            child: _photoCard(imagePaths[3]),
          ),
          StaggeredGridTile.extent(
            crossAxisCellCount: 2,
            mainAxisExtent: 100,
            child: _photoCard(imagePaths[4]),
          ),
        ],
      ),
    );
  }

  Widget _photoCard(String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      // ClipRRect ensures the image stays inside the rounded corners
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          // Optional: Add an error builder in case the asset is missing during testing
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.image, size: 32, color: Colors.white54),
            );
          },
        ),
      ),
    );
  }

  // ── About Section ─────────────────────────────────────────────────────────
  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Our School',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Lorem ipsum dolor sit amet consectetur. At et viverra orci senectus velit '
                'tristique odio sem. Tempus ipsum massa est a eu nibh urna aenean quis. Odio '
                'nibh pharetra sapien in feugiat. Et porttitor eu elementum non eget amet. '
                'Porta in ut nibh integer turpis aliquam feugiat. Proin neque tellus orci '
                'velit eget placerat ut viverra facilisis. Id amet ac in est non. Et eget '
                'pellentesque pharetra pretium auctor tempor eros.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Read More',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Contact Row ───────────────────────────────────────────────────────────
  Widget _buildContactRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {},
        child: Row(
          children: [
            const Icon(Icons.phone_outlined, size: 22, color: Colors.black87),
            const SizedBox(width: 8),
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Social Icons ──────────────────────────────────────────────────────────
  Widget _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialIcon(
          Icons.camera_alt_outlined,
          Colors.pink,
          'https://www.instagram.com/met_publicschoolpayyanad?utm_source=qr&igsh=MWI5MDZjYTF1cXg2bw==',
        ),
        const SizedBox(width: 24),

        _socialIcon(
          Icons.facebook,
          const Color(0xFF1877F2),
          'https://www.facebook.com/share/1B7NobNz11/',
        ),
        const SizedBox(width: 24),

        _socialIcon(
          Icons.play_circle_fill,
          Colors.red,
          'https://youtube.com/@metpublicschoolpayyanad5294?si=8GvIioRFl1bbRFp3',
        ),
      ],
    );
  }

  Widget _socialIcon(IconData icon, Color color, String url) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(url);

        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        }
      },
      borderRadius: BorderRadius.circular(30),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: color.withOpacity(.1),
        child: Icon(icon, color: color),
      ),
    );
  }
  // ── Login Button ──────────────────────────────────────────────────────────
// ── Auth tap handler (copied from old HomeScreen) ─────────────────────────
  Future<void> _handleAuthTap() async {
    final auth = context.read<AuthProvider>();

    if (!auth.isLoggedIn) {
      NavigationService.push(context, LoginScreen());
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CustomLoader()),
    );

    // Refresh user data to get latest roles and student list from DB
    await auth.syncUserData(context);

    if (!mounted) return;
    Navigator.pop(context); // Dismiss loading

    final prefs = await SharedPreferences.getInstance();
    final isTeacher = prefs.getBool("isTeacher") ?? false;
    final isParent = prefs.getBool("isParent") ?? false;
    final isClassTeacher = prefs.getBool("isClassTeacher") ?? false;
    final isSubjectTeacher = prefs.getBool("isSubjectTeacher") ?? false;

    final data = jsonDecode(prefs.getString("userData") ?? "{}");
    final studentDataList = (prefs.getStringList("studentDataList") ?? [])
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();

    /// 🎯 ROLE NAVIGATION LOGIC (Sync with AuthProvider)
    if (isParent && (isClassTeacher || isSubjectTeacher)) {
      NavigationService.pushAndRemoveUntil(
        context,
        RoleSelectionScreen(
          teacherData: data,
          studentDataList: studentDataList,
          parentName: data['name'] ?? "",
        ),
      );
    }
    else if (isParent) {
      await prefs.setString("role", "parent");
      if (studentDataList.isNotEmpty) {
        final s = studentDataList.first;
        await prefs.setString("studentId", s['studentId'] ?? "");
        if (!mounted) return;
        NavigationService.pushAndRemoveUntil(
          context,
          ParentMainScreen(
            parentName: data['name'] ?? "",
            studentId: s['studentId'],
            academicYearID: s['academicYearId'],
            teacherName: s['teacherName'],
            teacherID: s['teacherId'],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No student enrollments found.")),
        );
      }
    }
    else if (isClassTeacher || isSubjectTeacher) {
      await prefs.setString("role", "teacher");
      NavigationService.pushAndRemoveUntil(
        context,
        TeacherHomeScreen(
          staffName: prefs.getString("name") ?? data['name'] ?? "",
        ),
      );
    }
    else if (isTeacher) {
      // Teacher but no assignments
      await prefs.setString("role", "teacher");
      NavigationService.pushAndRemoveUntil(
        context,
        TeacherHomeScreen(
          staffName: prefs.getString("name") ?? data['name'] ?? "",
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No active role assigned.")),
      );
    }
  }

// ── Login / Continue Button ───────────────────────────────────────────────
  Widget _buildLoginButton() {
    // Watch AuthProvider so the button label reacts to login state changes
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF9C27B0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: ElevatedButton.icon(
            onPressed: _handleAuthTap,
            icon: Icon(
              isLoggedIn ? Icons.dashboard_rounded : Icons.login_rounded,
              color: Colors.white,
              size: 20,
            ),
            label: Text(
              isLoggedIn ? 'Continue' : 'Login',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ),
    );
  }
}