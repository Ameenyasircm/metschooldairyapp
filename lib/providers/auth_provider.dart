import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:met_school/core/utils/navigation/navigation_helper.dart';
import 'package:met_school/features/auth/presentation/screens/login_screen.dart';
import 'package:met_school/features/modules/admin/views/admin_home.dart';
import 'package:met_school/providers/parent_provider.dart';
import 'package:met_school/providers/teacher_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/presentation/models/academic_year_model.dart';
import '../features/home/views/home/home_provider.dart';
import '../features/homework/providers/homework_provider.dart';
import '../features/modules/admin/views/admin_login_screen.dart';

import '../core/utils/snackbarNotification/snackbar_notification.dart';
import '../features/modules/parent/views/parent_home.dart';
import '../features/modules/parent/views/parent_select_child_screen.dart';
import '../features/modules/teacher/home/presentation/screens/teacher_navbar_screen.dart';
import '../features/modules/teacher/home/viewmodels/teacher_home_viewmodel.dart';
import '../features/modules/teacher/timetable/presentation/provider/timetable_provider.dart';
import '../features/splash/splash_screen.dart';
import '../features/update/update_screen.dart';
import 'academic_provider.dart';
import 'admin_provider.dart';
import 'conversation_provider.dart';
import 'fee_provider.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseDatabase realtime = FirebaseDatabase.instance;
  final DatabaseReference mRoot = FirebaseDatabase.instance.ref();

  bool _obscurePassword = true;
  bool _isLoading = false;

  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;

  AuthProvider(){
    loadCurrentAcademicYear();
    getAppVersion();
    loadLoginStatus();
    // lockApp();
  }

  void togglePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Admin Login Logic
  Future<void> loginAdmin({
    required String phoneNumber,
    required String password,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final adminSnapshot = await fireStore
          .collection("users")
          .where("phone", isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (adminSnapshot.docs.isNotEmpty) {
        var adminData = adminSnapshot.docs.first.data();

        // 🔹 1. CHECK IF ACCOUNT IS ACTIVE
        // Default to true if the field doesn't exist yet
        bool isActive = adminData['isActive'] ?? true;

        if (!isActive) {
          if (context.mounted) {
            _showError(context, "Your account is temporarily deactivated. Please contact the administrator.");
          }
          return; // Stop the login process here
        }

        String dbPassword = adminData['password'] ?? "";
        String adminName = adminData['name'] ?? "";
        String adminPhone = adminData['phone'] ?? "";

        if (dbPassword == password) {
          /// ✅ SAVE LOGIN DATA
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("adminId", adminSnapshot.docs.first.id);
          await prefs.setString("adminName", adminName);
          await prefs.setString("adminPhone", adminPhone);
          await prefs.setString("password", dbPassword);

          if (context.mounted) {
            callNextReplacement(
              AdminHome(
                userid: adminSnapshot.docs.first.id,
                userName: adminName,
                phone: adminPhone,
              ),
              context,
            );
          }
        } else {
          _showError(context, "Incorrect password. Please try again.");
        }
      } else {
        _showError(context, "Admin not found with this phone number.");
      }
    } catch (e) {
      _showError(context, "An error occurred: ${e.toString()}");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    notifyListeners();
  }

  /// staff login
  bool _isStaffLoginLoading = false;

  bool get staffLoginLoading => _isStaffLoginLoading;

  Future<void> staffLogin({
    required String phoneNumber,
    required String password,
    required BuildContext context,
  }) async {
    _isStaffLoginLoading = true;
    notifyListeners();

    try {
      final query = await fireStore
          .collection("users")
          .where("phone", isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        SnackbarService().showError("User not found.");
        return;
      }

      final doc = query.docs.first;
      final data = doc.data();

      final dbPassword = data['password'] ?? "";

      if (dbPassword != password) {
        SnackbarService().showError("Incorrect password.");
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      /// =========================
      /// 🎯 PARENT LOGIN
      /// =========================
      if (data['role'] == "parent") {
        final academicYear = currentYear?.id;

        if (academicYear == null) {
          SnackbarService().showError("Academic year not found.");
          return;
        }

        final enrollments = await fireStore
            .collection("enrollments")
            .where("parent_id", isEqualTo: doc.id)
            .where("academic_year_id", isEqualTo: academicYear)
            .get();

        if (enrollments.docs.isEmpty) {
          SnackbarService().showError("Ensure the Student is Assigned To Class");
          return;
        }

        /// ✅ SAVE LOGIN SESSION
        await prefs.setString("password", password);
        await prefs.setString("staffPhone", phoneNumber);
        await prefs.setBool("isLoggedIn", true);


        _isLoggedIn = true;
        notifyListeners();
        /// Save common data
        await prefs.setString("userId", doc.id);
        await prefs.setString("userName", data['name'] ?? "");
        await prefs.setString("phone", data['phone'] ?? "");
        await prefs.setString("role", data['role'] ?? "");
        await prefs.setString("email", data['email'] ?? "");
        await prefs.setString("profilePic", data['profile_pic'] ?? "");

        /// ✅ Build full student list (FIXED HERE)
        List<Map<String, dynamic>> studentDataList = [];

        for (var e in enrollments.docs) {
          final enrollData = e.data();

          final studentId = enrollData['student_id'];
          final divisionId = enrollData['division_id'];

          final divisionDoc = await fireStore
              .collection("divisions")
              .doc(divisionId)
              .get();

          final divisionData = divisionDoc.data() ?? {};

          studentDataList.add({
            "studentId": studentId,
            "academicYearId": enrollData['academic_year_id'] ?? "",
            "teacherName": divisionData['class_teacher_name'] ?? "",
            "teacherId": divisionData['class_teacher_id'] ?? "",
            "studentName": enrollData['student_name'] ?? "",
            "className": enrollData['class_name'] ?? "",
            "classId": enrollData['class_id'] ?? "",
            "divisionId": enrollData['division_id'] ?? "",
            "divisionName": enrollData['division_name'] ?? "",
          });
        }

        /// ✅ Save full list
        await prefs.setStringList(
          "studentDataList",
          studentDataList.map((e) => jsonEncode(e)).toList(),
        );

        /// =========================
        /// ✅ SINGLE STUDENT
        /// =========================
        if (studentDataList.length == 1) {
          final s = studentDataList.first;

          await prefs.setString("selectedStudentData", jsonEncode(s));

          /// ✅ FIXED (FROM ENROLLMENT)
          await prefs.setString("divisionId", s['divisionId'] ?? "");
          await prefs.setString("divisionName", s['divisionName'] ?? "");
          await prefs.setString("classId", s['classId'] ?? "");
          await prefs.setString("className", s['className'] ?? "");
          await prefs.setString("academicYearId", s['academicYearId'] ?? "");

          if (context.mounted) {
            callNextReplacement(
              ParentHomeScreen(
                studentId: s['studentId'],
                academicYearID: s['academicYearId'],
                teacherName: s['teacherName'],
                teacherID: s['teacherId'],
                parentName: data['name'],
              ),
              context,
            );
          }
        }

        /// =========================
        /// ✅ MULTIPLE STUDENTS
        /// =========================
        else {
          if (context.mounted) {
            final s = studentDataList.first;

            await prefs.setString("selectedStudentData", jsonEncode(s));

            /// ✅ FIXED (FROM ENROLLMENT)
            await prefs.setString("divisionId", s['divisionId'] ?? "");
            await prefs.setString("divisionName", s['divisionName'] ?? "");
            await prefs.setString("classId", s['classId'] ?? "");
            await prefs.setString("className", s['className'] ?? "");
            await prefs.setString("academicYearId", s['academicYearId'] ?? "");

            callNextReplacement(
              ParentStudentSelectionScreen(
                studentIds: studentDataList,
                parentName: data['name']??"",
              ),
              context,
            );
          }
        }
      }

      /// =========================
      /// 🎯 TEACHER LOGIN (UNCHANGED)
      /// =========================
      else {
        await prefs.setBool("isClassTeacher", data['is_class_teacher'] ?? false);
        await prefs.setString("divisionId", data['division_id'] ?? "");
        await prefs.setString("divisionName", data['division_name'] ?? "");
        await prefs.setString("classId", data['class_id'] ?? "");
        await prefs.setString("className", data['class_name'] ?? "");
        await prefs.setString("staffId", doc.id);
        await prefs.setString("staffName", data['name'] ?? "");
        await prefs.setBool("isLoggedIn", true);

        _isLoggedIn = true;
        notifyListeners();

        final academicYear = await currentAcademicYearId();
        if (academicYear != null) {
          await prefs.setString("academicYearId", academicYear);
        }

        if (context.mounted) {
          callNextReplacement(
            TeacherNavbarScreen(
              staffName: data['name'] ?? "",
            ),
            context,
          );
        }
      }
    } catch (e) {
      SnackbarService().showError("Something went wrong. Try again.");
    } finally {
      _isStaffLoginLoading = false;
      notifyListeners();
    }
  }

  Future<String?> currentAcademicYearId() async {
    final query = await fireStore
        .collection('academic_years')
        .where('is_current', isEqualTo: true)
        .limit(1)
        .get();

    return query.docs.isNotEmpty ? query.docs.first.id : null;
  }


  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }


  Future<void> uploadStudents() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    final List<Map<String, String>> students =[
      {
        "student_id": "STU001",
        "name": "Aarav Nair",
        "parent_phone": "9876543210",
        "dob": "12/03/2010",
        "blood_group": "O+",
        "address": "Kowdiar, Thiruvananthapuram",
        "admission_number": "ADM1001"
      },
      {
        "student_id": "STU002",
        "name": "Diya Menon",
        "parent_phone": "9876543211",
        "dob": "25/07/2011",
        "blood_group": "A+",
        "address": "Kazhakootam, Thiruvananthapuram",
        "admission_number": "ADM1002"
      },
      {
        "student_id": "STU003",
        "name": "Muhammed Rihan",
        "parent_phone": "9876543212",
        "dob": "05/01/2010",
        "blood_group": "B+",
        "address": "Pattom, Thiruvananthapuram",
        "admission_number": "ADM1003"
      },
      {
        "student_id": "STU004",
        "name": "Ananya Pillai",
        "parent_phone": "9876543213",
        "dob": "18/09/2012",
        "blood_group": "AB+",
        "address": "Vazhuthacaud, Thiruvananthapuram",
        "admission_number": "ADM1004"
      },
      {
        "student_id": "STU005",
        "name": "Arjun Kumar",
        "parent_phone": "9876543214",
        "dob": "30/11/2011",
        "blood_group": "O-",
        "address": "Nemom, Thiruvananthapuram",
        "admission_number": "ADM1005"
      },
      {
        "student_id": "STU006",
        "name": "Fathima Zahra",
        "parent_phone": "9876543215",
        "dob": "14/06/2010",
        "blood_group": "A-",
        "address": "Karamana, Thiruvananthapuram",
        "admission_number": "ADM1006"
      },
      {
        "student_id": "STU007",
        "name": "Nikhil Raj",
        "parent_phone": "9876543216",
        "dob": "09/02/2012",
        "blood_group": "B-",
        "address": "Peroorkada, Thiruvananthapuram",
        "admission_number": "ADM1007"
      },
      {
        "student_id": "STU008",
        "name": "Aisha Noor",
        "parent_phone": "9876543217",
        "dob": "22/08/2011",
        "blood_group": "O+",
        "address": "Attingal, Thiruvananthapuram",
        "admission_number": "ADM1008"
      },
      {
        "student_id": "STU009",
        "name": "Rahul Das",
        "parent_phone": "9876543218",
        "dob": "03/05/2010",
        "blood_group": "A+",
        "address": "Varkala, Thiruvananthapuram",
        "admission_number": "ADM1009"
      },
      {
        "student_id": "STU010",
        "name": "Sneha Suresh",
        "parent_phone": "9876543219",
        "dob": "17/12/2012",
        "blood_group": "B+",
        "address": "Kilimanoor, Thiruvananthapuram",
        "admission_number": "ADM1010"
      },
      {
        "student_id": "STU011",
        "name": "Aditya Krishnan",
        "parent_phone": "9876543220",
        "dob": "11/04/2011",
        "blood_group": "AB+",
        "address": "Neyyattinkara, Thiruvananthapuram",
        "admission_number": "ADM1011"
      },
      {
        "student_id": "STU012",
        "name": "Hiba Rahman",
        "parent_phone": "9876543221",
        "dob": "27/10/2010",
        "blood_group": "O-",
        "address": "Balaramapuram, Thiruvananthapuram",
        "admission_number": "ADM1012"
      },
      {
        "student_id": "STU013",
        "name": "Vishnu Prasad",
        "parent_phone": "9876543222",
        "dob": "06/01/2012",
        "blood_group": "A-",
        "address": "Chalai, Thiruvananthapuram",
        "admission_number": "ADM1013"
      },
      {
        "student_id": "STU014",
        "name": "Meera Nair",
        "parent_phone": "9876543223",
        "dob": "19/03/2011",
        "blood_group": "B-",
        "address": "Fort, Thiruvananthapuram",
        "admission_number": "ADM1014"
      },
      {
        "student_id": "STU015",
        "name": "Shamil Basheer",
        "parent_phone": "9876543224",
        "dob": "08/07/2010",
        "blood_group": "O+",
        "address": "Pothencode, Thiruvananthapuram",
        "admission_number": "ADM1015"
      },
      {
        "student_id": "STU016",
        "name": "Lakshmi Devi",
        "parent_phone": "9876543225",
        "dob": "29/09/2012",
        "blood_group": "A+",
        "address": "Ulloor, Thiruvananthapuram",
        "admission_number": "ADM1016"
      },
      {
        "student_id": "STU017",
        "name": "Farhan Ali",
        "parent_phone": "9876543226",
        "dob": "16/02/2011",
        "blood_group": "B+",
        "address": "Sreekariyam, Thiruvananthapuram",
        "admission_number": "ADM1017"
      },
      {
        "student_id": "STU018",
        "name": "Gayathri Menon",
        "parent_phone": "9876543227",
        "dob": "21/11/2010",
        "blood_group": "AB+",
        "address": "Kaniyapuram, Thiruvananthapuram",
        "admission_number": "ADM1018"
      },
      {
        "student_id": "STU019",
        "name": "Sidharth Mohan",
        "parent_phone": "9876543228",
        "dob": "04/06/2012",
        "blood_group": "O-",
        "address": "Pappanamcode, Thiruvananthapuram",
        "admission_number": "ADM1019"
      },
      {
        "student_id": "STU020",
        "name": "Nida Fathima",
        "parent_phone": "9876543229",
        "dob": "13/08/2011",
        "blood_group": "A+",
        "address": "Thampanoor, Thiruvananthapuram",
        "admission_number": "ADM1020"
      }
    ];
    for (var student in students) {
      final docRef = firestore
          .collection('students')
          .doc(student['student_id']);

      batch.set(docRef, student);
    }

    await batch.commit();
  }
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    /// Clear saved data
    await prefs.clear();

    /// 🔥 UPDATE STATE
    _isLoggedIn = false;
    notifyListeners();

    /// Navigate to login
    if (context.mounted) {
      if (kIsWeb) {
        callNextReplacement(const AdminLoginScreen(), context);
      } else {
        pushAndRemoveUntil(LoginScreen(), context);
      }
    }
  }
  AcademicYearModel? currentYear;

  Future<void> loadCurrentAcademicYear() async {

    currentYear = await fetchCurrentAcademicYear();

    notifyListeners();
  }

  Future<AcademicYearModel?> fetchCurrentAcademicYear() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('academic_years')
          .where('is_current', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return AcademicYearModel.fromMap(snapshot.docs.first.data());
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching academic year: $e");
      return null;
    }
  }

  void lockApp() {
    mRoot.child("0").onValue.listen((event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> map = event.snapshot.value as Map;
        List<String> versions =Platform.isIOS?map['iOSVersion'].toString().split(','): map['AppVersion'].toString().split(',');
        print('$appVersion current version and in List $versions');
        if (!versions.contains(appVersion)) {
          print(' FUJEUIRFERF ');
          // bool versionStatus = await checkVersionExist();

          // if (!versionStatus) {
            String address = map[Platform.isIOS?"ADDRESS_iOS":'ADDRESS'].toString();
            String button = map['BUTTON'].toString();
            String text = map['TEXT'].toString();
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
                  ],
                  child: MaterialApp(
                      debugShowCheckedModeBanner: false,
                      theme: ThemeData(
                        useMaterial3: true,
                        primarySwatch: Colors.blue,
                      ),
                      home: Update(
                        ADDRESS: address,
                        button: button,
                        text: text,
                      )
                  ),
                ));
          // }
        }else{
          print("ellse printed  $appVersion");
        }
      }
    });
  }
  String? appVersion;
  String currentVersion='';
  String buildNumber="";
  Future<void> getAppVersion() async {
    PackageInfo.fromPlatform().then((value) {
      currentVersion=value.version;
      buildNumber = value.buildNumber;
      appVersion=buildNumber;
      print(appVersion.toString()+"edfesappversion");
      notifyListeners();
    });

  }


  Future<bool> checkVersionExist() async {
    DatabaseEvent dataSnapshot ;
    if(Platform.isIOS){
      dataSnapshot=  await mRoot.child("0").child('iOSVersion').once();
    }else{
      dataSnapshot=  await mRoot.child("0").child('AppVersion').once();

    }
    List<String> versions = dataSnapshot.snapshot.value.toString().split(',');

    print("c  $versions");
    print("currentVersion,  $appVersion");

    if (versions.contains(appVersion)) {
      return true;
    } else {
      return false;
    }
  }

  void lockAppUpdateScreen() {
    mRoot.child("0").once().then((event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> map = event.snapshot.value as Map;
        List<String> versions =Platform.isIOS?map['iOSVersion'].toString().split(','): map['AppVersion'].toString().split(',');
        print(' PRINT HERE HERE HERE HERE '+versions.toString()+' '+appVersion.toString());

        if (!versions.contains(appVersion)) {
          print(' FIRFNEJKRF ');
          // bool versionStatus = await checkVersionExist();
          String address = map[Platform.isIOS?"ADDRESS_iOS":'ADDRESS'].toString();
          String button = map['BUTTON'].toString();
          String text = map['TEXT'].toString();
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
                ],
                child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: ThemeData(
                      useMaterial3: true,
                      primarySwatch: Colors.blue,
                    ),
                    home: Update(
                      ADDRESS: address,
                      button: button,
                      text: text,
                    )
                ),
              ));
        }else{
          print(' KKKSKDKDS NJJERNFERNF FJERNFER F ');
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
                ],
                child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: ThemeData(
                      useMaterial3: true,
                      primarySwatch: Colors.blue,
                    ),
                    home: SplashScreen()
                ),
              ));
          print("ellse printed  $appVersion");
        }
      }
    });
  }

  Future<void> logoutWithoutNavigation() async {
    final prefs = await SharedPreferences.getInstance();

    /// Clear saved data
    await prefs.clear();

    /// Update provider state
    _isLoggedIn = false;
    notifyListeners();
  }


}