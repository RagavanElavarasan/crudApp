import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:crud_app/Pavithra/database.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class Student extends StatefulWidget {
  const Student({super.key});
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController yearcontroller = TextEditingController();
  TextEditingController departmentcontroller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  Future<void> _pickImage() async {
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
        title: Text(
          'CREATE NEW STUDENT',
          style: TextStyle(
              color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage:
                        _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null
                        ? Icon(Icons.add_a_photo_rounded,
                            size: 45, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 25),
              Text(
                "Name",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 15),
              Container(
                height: 40,
                child: TextField(
                  controller: namecontroller,
                  decoration: InputDecoration(
                    labelText: 'Enter the Name',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
              ),
              SizedBox(height: 25),
              Text(
                "Year",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 15),
              Container(
                height: 40,
                child: TextField(
                  controller: yearcontroller,
                  decoration: InputDecoration(
                    labelText: 'Enter the Year of study',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
              ),
              SizedBox(height: 25),
              Text(
                "Department",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 15),
              Container(
                height: 40,
                child: TextField(
                  controller: departmentcontroller,
                  decoration: InputDecoration(
                    labelText: 'Enter Department',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
              ),
              SizedBox(height: 50),
              Center(
                child: SizedBox(
                  width: 150,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      String id = randomAlphaNumeric(5);

                      // Upload image if picked
                      String? imageUrl;
                      if (_imageFile != null) {
                        imageUrl = await DatabaseMethods()
                            .uploadImage(id, _imageFile!);
                      }

                      Map<String, dynamic> studentInfoMap = {
                        "id": id,
                        "Name": namecontroller.text,
                        "Year": yearcontroller.text,
                        "Department": departmentcontroller.text,
                        "imageUrl": imageUrl,
                      };

                      await DatabaseMethods()
                          .addStudentdetails(studentInfoMap, id)
                          .then((value) {
                        Fluttertoast.showToast(
                            msg:
                                "New Student data has been created successfully",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      });
                    },
                    child: Text(
                      'CREATE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      textStyle: TextStyle(
                        fontSize: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
