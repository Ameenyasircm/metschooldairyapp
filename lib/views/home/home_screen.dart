import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/constants/app_colors.dart';
import '../../presenters/home_presenter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements HomeView {
  late HomePresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = HomePresenter(this);
  }

  @override
  void navigateToAdmissions() {
    // TODO: Navigate to Admissions Page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to Admissions Page...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get slider images from the presenter
    final List<String> imgList = _presenter.getSliderImages();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'MET Public School',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // 1. Carousel Slider Section
            CarouselSlider(
              options: CarouselOptions(
                height: 220.0,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 0.85,
              ),
              items: imgList.map((item) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.network(
                    item,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              )).toList(),
            ),

            const SizedBox(height: 30),

            // 2. School Description & Motto Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(color: AppColors.silverGrey.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.silverGrey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Care for the Morrow',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Welcome to MET Public School, Payyanad. We are committed to nurturing young minds with quality education, modern facilities, and a holistic approach to personal growth. Join us to build a brighter tomorrow for your child.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 3. Admissions Call to Action Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _presenter.onAdmissionsClicked();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Apply for Admission',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }
}