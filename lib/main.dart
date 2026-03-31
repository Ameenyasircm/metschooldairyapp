import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/providers/admin_provider.dart';
import 'package:met_school/providers/auth_provider.dart';
import 'package:met_school/providers/parent_provider.dart';
import 'package:met_school/providers/teacher_provider.dart';
import 'package:provider/provider.dart';
import 'features/home/views/home/home_provider.dart';
import 'features/modules/teacher/home/viewmodels/teacher_home_viewmodel.dart';
import 'features/splash/splash_screen.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => ParentProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => TeacherHomeViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ScreenUtilInit(
      minTextAdapt: false,
      designSize: const Size(360, 813),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MET SCHOOL',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
          ),
        ),
        home:  SplashScreen(),
        // home:  AdminHome(userid: '777', userName: 'wise',),
      ),
    );
  }
}
