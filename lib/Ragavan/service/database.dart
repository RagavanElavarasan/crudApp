import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseMethods {
  // Method to add patient details to Firestore
  Future<void> addPatient(Map<String, dynamic> patientInfoMap, String id) async {
    await FirebaseFirestore.instance.collection("Patient").doc(id).set(patientInfoMap);
  }

  // Method to upload image to Firebase Storage
  Future<String> uploadImage(File imageFile, String id) async {
    try {
      // Define the storage path
      Reference storageRef = FirebaseStorage.instance.ref().child("PatientImages/$id");

      // Start the upload
      UploadTask uploadTask = storageRef.putFile(imageFile);

      // Wait for the upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return "";
    }
  }
  Future<Stream<QuerySnapshot>> getPatientDetails() async{
    return await FirebaseFirestore.instance.collection("Patient").snapshots();
  }

  Future updatePatientDetails(String id,Map<String,dynamic>updateInfoMap)async{
    return await FirebaseFirestore.instance.collection("Patient").doc(id).update(updateInfoMap);
  }

  Future deletePatientDetails(String id,)async{
    return await FirebaseFirestore.instance.collection("Patient").doc(id).delete();
  }
}
