import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class DatabaseMethods {
  // Add new student details
  Future addStudentdetails(
      Map<String, dynamic> studentInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Student")
        .doc(id)
        .set(studentInfoMap);
  }

  // Get student details stream
  Stream<QuerySnapshot> getStudentdetails() {
    return FirebaseFirestore.instance.collection("Student").snapshots();
  }

  // Update student details
  Future updateStudentdetails(
      String id, Map<String, dynamic> updateInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("Student")
        .doc(id)
        .update(updateInfoMap);
  }

  // Delete student details
  Future deleteStudentdetails(String id) async {
    return await FirebaseFirestore.instance
        .collection("Student")
        .doc(id)
        .delete();
  }

  // Upload image to Firebase Storage and get URL
  Future<String?> uploadImage(String id, File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("student_images")
          .child("$id.jpg");

      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
}
