import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:met_school/core/utils/navigation/navigation_helper.dart';
import 'package:met_school/features/modules/admin/views/admin_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseDatabase realtime = FirebaseDatabase.instance;

  bool _obscurePassword = true;
  bool _isLoading = false;

  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;

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
          .collection("admins")
          .where("phone_number", isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (adminSnapshot.docs.isNotEmpty) {
        var adminData = adminSnapshot.docs.first.data();

        String dbPassword = adminData['password'] ?? "";
        String adminName = adminData['name'] ?? "";
        String adminPhone = adminData['phone_number'] ?? "";

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

  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}