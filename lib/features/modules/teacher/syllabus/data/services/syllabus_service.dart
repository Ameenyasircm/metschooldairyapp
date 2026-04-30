import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/cupertino.dart';
import '../models/syllabus_model.dart';

class SyllabusService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Replace with your Cloudinary credentials or fetch from environment config
  // In a real production app, these should be handled securely.
  static const String _cloudName = 'dt9qsvvp2';
  static const String _uploadPreset = 'METSCHOOL';

  final CloudinaryPublic _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);

  Future<String> uploadSyllabusFile(File file) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Raw,
          folder: 'syllabus',
        ),
      );
      final url = response.secureUrl;
      debugPrint("Final Uploaded URL (Raw): $url");
      return url;
    } catch (e) {
      throw Exception('Failed to upload to Cloudinary: $e');
    }
  }

  Future<void> saveSyllabusMetadata(SyllabusModel syllabus) async {
    try {
      await _db.collection('syllabus').doc(syllabus.id).set(syllabus.toMap());
    } catch (e) {
      throw Exception('Failed to save metadata to Firestore: $e');
    }
  }

  Future<List<SyllabusModel>> getSyllabusList({
    required String classId,
    required String divisionId,
  }) async {
    try {
      Query query = _db.collection('syllabus')
          .where('classId', isEqualTo: classId);
      
      if (divisionId.isNotEmpty) {
        query = query.where('divisionId', isEqualTo: divisionId);
      }

      final snapshot = await query.orderBy('uploadedAt', descending: true).get();

      return snapshot.docs
          .map((doc) => SyllabusModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching syllabus list: $e');
      return [];
    }
  }

  Future<void> deleteSyllabus(String syllabusId) async {
    try {
      await _db.collection('syllabus').doc(syllabusId).delete();
    } catch (e) {
      throw Exception('Failed to delete syllabus: $e');
    }
  }
}
