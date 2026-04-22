import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:met_school/providers/academic_provider.dart';
import 'package:met_school/providers/admin_provider.dart';
import 'package:met_school/providers/auth_provider.dart';
import 'package:met_school/providers/conversation_provider.dart';
import 'package:met_school/providers/fee_provider.dart';
import 'package:met_school/providers/parent_provider.dart';
import 'package:met_school/providers/teacher_provider.dart';
import 'package:met_school/data/repositories/leave_repository.dart';
import 'package:met_school/providers/leave_provider.dart';
import 'package:provider/provider.dart';
import 'core/utils/snackbarNotification/snackbar_notification.dart';
import 'features/home/views/home/home_provider.dart';
import 'features/modules/admin/views/admin_home.dart';
import 'features/modules/teacher/attendance/data/service/attendance_firestore_service.dart';
import 'features/modules/teacher/attendance/presentation/provider/attendance_view_model.dart';
import 'features/modules/teacher/home/viewmodels/teacher_home_viewmodel.dart';
import 'features/modules/teacher/timetable/presentation/provider/timetable_provider.dart';
import 'features/modules/teacher/students/data/datasource/student_firestore.dart';
import 'features/modules/teacher/students/data/repository/student_repository.dart';
import 'features/modules/teacher/students/presentation/provider/student_provider.dart';
import 'features/modules/teacher/attendance/presentation/provider/attendance_provider.dart';
import 'features/modules/teacher/attendance/presentation/provider/attendance_report_view_model.dart';
import 'features/homework/providers/homework_provider.dart' as new_hw;
import 'features/modules/teacher/homework/presentation/provider/homework_provider.dart';
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
        ChangeNotifierProvider(create: (_) => FeeProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => ParentProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => TeacherHomeViewModel()),
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
        ChangeNotifierProvider(create: (_) => AcademicProvider()),
        ChangeNotifierProvider(create: (_) => HomeworkProvider()),
        ChangeNotifierProvider(create: (_) => ConversationProvider()),
        ChangeNotifierProvider(create: (_) => new_hw.HomeworkProvider()),
        Provider(create: (_) => LeaveRepository()),
        ChangeNotifierProvider(
          create: (context) => LeaveProvider(context.read<LeaveRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => StudentProvider(
            StudentRepository(StudentFirestore()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AttendanceViewModel(
            AttendanceFirestoreService(),
            context.read<StudentProvider>().repository,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AttendanceProvider(
            context.read<StudentProvider>().repository,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AttendanceReportViewModel(
            AttendanceFirestoreService(),
          ),
        ),
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
        scaffoldMessengerKey: SnackbarService().messengerKey,
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
