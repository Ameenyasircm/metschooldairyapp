import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseDatabase realtime = FirebaseDatabase.instance;
}