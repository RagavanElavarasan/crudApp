import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_app/Pavithra/create.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crud_app/Pavithra/database.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController yearcontroller = TextEditingController();
  TextEditingController departmentcontroller = TextEditingController();
  Stream? StudentStream;
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
  void initState() {
    super.initState();
    getontheload();
  }

  getontheload() async {
    StudentStream = await DatabaseMethods().getStudentdetails();
    setState(() {});
  }

  Widget allStudentDetails() {
    return StreamBuilder(
      stream: StudentStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return Material(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 8, bottom: 8),
                      child: Container(
                        height: 82,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 224, 223, 223)
                                  .withOpacity(0.5),
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 27,
                                backgroundColor: Colors.grey,
                                backgroundImage:
                                    (ds.data() as Map<String, dynamic>)
                                                .containsKey("imageUrl") &&
                                            ds["imageUrl"] != null
                                        ? NetworkImage(ds["imageUrl"])
                                        : null,
                                child: !(ds.data() as Map<String, dynamic>)
                                            .containsKey("imageUrl") ||
                                        ds["imageUrl"] == null
                                    ? Icon(Icons.person,
                                        size: 30, color: Colors.white)
                                    : null,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Name: " + ds["Name"],
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            namecontroller.text = ds["Name"];
                                            yearcontroller.text = ds["Year"];
                                            departmentcontroller.text =
                                                ds["Department"];
                                            editStudentdetails(ds.id);
                                          },
                                          child: Icon(Icons.edit,
                                              color: const Color.fromARGB(
                                                  255, 15, 145, 82)),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Year: " + ds["Year"],
                                            style: TextStyle(fontSize: 16)),
                                        GestureDetector(
                                          onTap: () async {
                                            await DatabaseMethods()
                                                .deleteStudentdetails(ds.id);
                                            Fluttertoast.showToast(
                                              msg:
                                                  "Student data deleted successfully",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0,
                                            );
                                          },
                                          child: Icon(Icons.delete,
                                              color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                          "Department: " + ds["Department"],
                                          style: TextStyle(fontSize: 16)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "CRUD ",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
                Text(
                  "Using FireBase",
                  style: TextStyle(
                      //color: Colors.orange,
                      fontWeight: FontWeight.w500,
                      fontSize: 20),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  SizedBox(
                    height: 750,
                    child: allStudentDetails(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 130.0, vertical: 20.0),
        child: SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: () {
              Get.to(() => Student());
            },
            child: Text(
              ' + NEW ',
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
    );
  }

  Future editStudentdetails(String id) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: SingleChildScrollView(
              child: Container(
                width: double.maxFinite,
                child: Column(
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
                        SizedBox(width: 60),
                        Text(
                          "Edit Details",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : null,
                          child: _imageFile == null
                              ? Icon(Icons.add_a_photo,
                                  size: 50, color: Colors.grey)
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Name",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextField(
                        controller: namecontroller,
                        decoration: InputDecoration(
                          labelText: 'Enter the Name',
                          hintText: 'Name',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(height: 25),
                    Text(
                      "Year",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextField(
                        controller: yearcontroller,
                        decoration: InputDecoration(
                          labelText: 'Enter the Year of study',
                          hintText: 'Year',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(height: 25),
                    Text(
                      "Department",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextField(
                        controller: departmentcontroller,
                        decoration: InputDecoration(
                          labelText: 'Enter Department',
                          hintText: 'Department',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        String? imageUrl;
                        if (_imageFile != null) {
                          imageUrl = await DatabaseMethods()
                              .uploadImage(id, _imageFile!);
                        }
                        Map<String, dynamic> updateInfoMap = {
                          "Name": namecontroller.text,
                          "Year": yearcontroller.text,
                          "Department": departmentcontroller.text,
                          "imageUrl": imageUrl,
                          "id": id,
                        };

                        await DatabaseMethods()
                            .updateStudentdetails(id, updateInfoMap)
                            .then((value) {
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                            msg: "Student data updated successfully",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        });
                      },
                      child: Text(
                        'UPDATE',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 15, 145, 82),
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ));
}
