import 'dart:io';

import 'package:crud_app/Ragavan/Pages/home.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:crud_app/Ragavan/service/database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_string/random_string.dart';

class Patient extends StatefulWidget {
  const Patient({super.key});

  @override
  State<Patient> createState() => _PatientState();
  
}

class _PatientState extends State<Patient> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile; // Variable to store selected image file

  // Function to pick image from the gallery
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Name"),
            const SizedBox(height: 10),
            buildTextField(nameController),
            const SizedBox(height: 20),
            const Text("Age"),
            const SizedBox(height: 10),
            buildTextField(ageController),
            const SizedBox(height: 20),
            const Text("Gender"),
            const SizedBox(height: 10),
            buildTextField(genderController),
            const SizedBox(height: 20),
            // Add Image Button
            Center(
              child: ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Select Image"),
              ),
            ),
            const SizedBox(height: 10), 
            // Display a message if an image is selected
            _imageFile != null
                ? Center(
                  child: const Text(
                      "Image selected",
                      style: TextStyle(color: Colors.green),
                    ),
                )
                : Center(
                  child: const Text(
                      "No image selected",
                      style: TextStyle(color: Colors.red),
                    ),
                ),
            const SizedBox(height: 20),
            // Add Patient Button
            ElevatedButton(
              onPressed: () async {
                String id = randomAlphaNumeric(10);
                String imageUrl = "";

                // Only upload if an image has been selected
                if (_imageFile != null) {
                  imageUrl = await DatabaseMethods().uploadImage(_imageFile!, id);
                  if (imageUrl.isEmpty) {
                    Fluttertoast.showToast(
                      msg: "Image upload failed",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                    return; // Stop execution if upload fails
                  }
                }

                // Create patient info map
                Map<String, dynamic> patientInfoMap = {
                  "Name": nameController.text,
                  "Age": ageController.text,
                  "Gender": genderController.text,
                  "id": id,
                  "imageUrl": imageUrl,  // Add image URL to Firestore
                };

                await DatabaseMethods().addPatient(patientInfoMap, id).then((value) {
                  Fluttertoast.showToast(
                    msg: "Patient Details Added",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  Get.to(()=>Home());
                });
              },
              child: Center(child: const Text("Add Patient")),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }
}
