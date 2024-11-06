import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'product.dart';
import 'dart:io'; // Import for File

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Products',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('product').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data()
                  as Map<String, dynamic>; // Cast document data to a map

              // Retrieve data safely
              String? imagePath = data['ImagePath'];
              String name = data['Name'] ?? '';
              String quantity = data['Quantity'] ?? '';
              String price = data['Price'] ?? '';

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (imagePath != null && imagePath.isNotEmpty)
                        ? FileImage(File(imagePath))
                        : null,
                    child: (imagePath == null || imagePath.isEmpty)
                        ? Icon(Icons.camera_alt)
                        : null,
                  ),
                  title: Text('Name : $name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantity : $quantity'),
                      Text('Price : $price')
                    ],
                  ) //('Quantity: $quantity ')//Price: $price'),
                  ,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: Product(
                                  id: doc.id,
                                  name: name,
                                  quantity: quantity,
                                  price: price,
                                  imagePath: imagePath,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('product')
                              .doc(doc.id)
                              .delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Product()),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
