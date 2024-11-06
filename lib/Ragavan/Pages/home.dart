import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_app/Ragavan/Pages/patient.dart';
import 'package:crud_app/Ragavan/service/database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
  
}

class _HomeState extends State<Home> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  Stream? patientStream;
  
  // Declare the image file at the class level
  File? _imageFile;

  // Initialize the image picker
  final ImagePicker _picker = ImagePicker();

  getontheload() async {
    patientStream = await DatabaseMethods().getPatientDetails();
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  Widget allPatientDetails() {
    return StreamBuilder(
      stream: patientStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            Map<String, dynamic>? data = ds.data() as Map<String, dynamic>?;

            // Retrieve imageUrl or use placeholder
            String imageUrl = (data != null && data.containsKey("imageUrl") && data["imageUrl"] != null)
                ? data["imageUrl"]
                : "";

            return Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    // Circular Avatar to display patient's image
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : AssetImage("assets/placeholder.jpg") as ImageProvider,
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(width: 20),
                    // Patient details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Name: ${data?["Name"] ?? 'N/A'}",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 50),
                              GestureDetector(
                                onTap: () {
                                  nameController.text = data?["Name"] ?? "";
                                  ageController.text = data?["Age"] ?? "";
                                  genderController.text = data?["Gender"] ?? "";
                                  editPatientDetails(ds.id); // Pass the document ID here
                                },
                                child: Icon(Icons.edit),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await DatabaseMethods().deletePatientDetails(ds["id"]).then((value) {
                                  Fluttertoast.showToast(
                                    msg: "Patient Details Deleted",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                });
                                },
                                child: Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                          Text("Age: ${data?["Age"] ?? 'N/A'}", style: TextStyle(fontSize: 14)),
                          Text("Gender: ${data?["Gender"] ?? 'N/A'}", style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future editPatientDetails(String id) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: StatefulBuilder(
            // Use StatefulBuilder to handle updates within the dialog
            builder: (context, setState) {
              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.cancel),
                        ),
                        SizedBox(
                          width: 40,
                        ),
                        const SizedBox(width: 1),
                        Text("Edit Patient Details"),
                      ],
                    ),
                    const SizedBox(height: 10),
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

                    // Button to pick a new image
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() {
                              _imageFile = File(pickedFile.path); // Store new image file
                            });
                          }
                        },
                        icon: const Icon(Icons.image),
                        label: const Text("Select New Image"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Display selected image if available
                    _imageFile != null
                        ? Image.file(_imageFile!, height: 100)
                        : Center(
                          child: const Text(
                              "No new image selected",
                              style: TextStyle(color: Colors.red),
                            ),
                        ),
                    const SizedBox(height: 20),

                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          String imageUrl = "";
                          
                          // If a new image is selected, upload it to Firebase Storage
                          if (_imageFile != null) {
                            imageUrl = await DatabaseMethods().uploadImage(_imageFile!, id);
                          }
                      
                          // Create map for updated details, including new image URL if available
                          Map<String, dynamic> updateInfoMap = {
                            "Name": nameController.text,
                            "Age": ageController.text,
                            "Gender": genderController.text,
                            if (imageUrl.isNotEmpty) "imageUrl": imageUrl,  // Update imageUrl only if a new image was uploaded
                          };
                      
                          await DatabaseMethods().updatePatientDetails(id, updateInfoMap).then((value) {
                          Fluttertoast.showToast(
                            msg: "Patient Details Updated",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.blue,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                            Navigator.pop(context);
                          });
                        },
                        child: const Text("Update"),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => Patient());
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("Patient Details"),
      ),
      body: Column(
        children: [
          Expanded(child: allPatientDetails()),
        ],
      ),
    );
  }
}
