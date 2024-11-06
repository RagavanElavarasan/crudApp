import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class Product extends StatefulWidget {
  final String? id;
  final String? name;
  final String? quantity;
  final String? price;
  final String? imagePath;

  const Product({
    Key? key,
    this.id,
    this.name,
    this.quantity,
    this.price,
    this.imagePath,
  }) : super(key: key);

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  String? selectedQuantity;
  final TextEditingController priceController = TextEditingController();
  String? imagePath;
  final ImagePicker picker = ImagePicker();

  final List<String> quantityOptions = ['1', '2', '3', '4', '5'];

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      nameController.text = widget.name ?? '';
      selectedQuantity = widget.quantity;
      priceController.text = widget.price ?? '';
      imagePath = widget.imagePath;
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  Future<void> addOrUpdateProduct() async {
    if (_formKey.currentState!.validate()) {
      if (widget.id != null) {
        // Update existing product
        await FirebaseFirestore.instance
            .collection('product')
            .doc(widget.id)
            .update({
          'Name': nameController.text,
          'Quantity': selectedQuantity,
          'Price': priceController.text,
          'ImagePath': imagePath,
        });
      } else {
        // Generate an ID with exactly 10 characters
        String newId = randomAlphaNumeric(10);
        await FirebaseFirestore.instance.collection('product').add({
          'id': newId,
          'Name': nameController.text,
          'Quantity': selectedQuantity,
          'Price': priceController.text,
          'ImagePath': imagePath,
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
                  backgroundImage:
                      imagePath != null ? FileImage(File(imagePath!)) : null,
                  child: imagePath == null
                      ? Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Product Name Field
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
                    // Product Quantity Field
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
                    // Product Price Field
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
                    // Add/Update Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue),
                      onPressed: addOrUpdateProduct,
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
