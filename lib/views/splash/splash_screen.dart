import 'package:flutter/material.dart';
import '../../presenters/splash_presenter.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> implements SplashView {
  late SplashPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = SplashPresenter(this);
    _presenter.init();
  }

  @override
  void navigateToHomeAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/met.png',
          width: 200, // Adjust size as needed
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.school, size: 100, color: Colors.deepPurple);
          },
        ),
      ),
    );
  }
}
