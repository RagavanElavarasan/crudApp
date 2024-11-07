import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:random_string/random_string.dart';

class Product extends StatefulWidget {
  final String? id;
  final String? name;
  final String? quantity;
  final String? price;
  final String? imageURL;

  const Product({
    Key? key,
    this.id,
    this.name,
    this.quantity,
    this.price,
    this.imageURL,
  }) : super(key: key);

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  String? selectedQuantity;
  final TextEditingController priceController = TextEditingController();
  String? imageURL;
  File? imageFile;
  final ImagePicker picker = ImagePicker();

  final List<String> quantityOptions = ['1', '2', '3', '4', '5'];

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      nameController.text = widget.name ?? '';
      selectedQuantity = widget.quantity;
      priceController.text = widget.price ?? '';
      imageURL = widget.imageURL;
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadImageAndSaveData() async {
    if (_formKey.currentState!.validate()) {
      String? url;
      if (imageFile != null) {
        // Upload to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child(
            'product_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(imageFile!);
        url = await storageRef.getDownloadURL();
      }

      // Save to Firestore
      if (widget.id != null) {
        // Update existing product
        await FirebaseFirestore.instance
            .collection('product')
            .doc(widget.id)
            .update({
          'Name': nameController.text,
          'Quantity': selectedQuantity,
          'Price': priceController.text,
          'ImageURL': url ?? imageURL, // Use the new URL if available
        });
      } else {
        await FirebaseFirestore.instance.collection('product').add({
          'Name': nameController.text,
          'Quantity': selectedQuantity,
          'Price': priceController.text,
          'ImageURL': url,
        });
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text(
          widget.id != null ? 'Edit Product' : 'Add Product',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: imageFile != null
                      ? FileImage(imageFile!)
                      : (imageURL != null ? NetworkImage(imageURL!) : null)
                          as ImageProvider,
                  child: imageFile == null && imageURL == null
                      ? Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedQuantity,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      items: quantityOptions.map((String quantity) {
                        return DropdownMenuItem<String>(
                          value: quantity,
                          child: Text(quantity),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedQuantity = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Select quantity' : null,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter price' : null,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue),
                      onPressed: uploadImageAndSaveData,
                      child: Text(
                        widget.id != null ? 'Update' : 'Add Product',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
