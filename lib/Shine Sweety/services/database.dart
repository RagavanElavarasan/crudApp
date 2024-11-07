import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new product to firebase
  Future<void> addProduct(String name, String id, int quantity, double price) {
    return _db.collection('product').add({
      'Name': name,
      'Id': id,
      'Quantity': quantity,
      'Price': price,
    });
  }

  // Update an existing product
  Future<void> updateProduct(
      String id, String name, String quantity, String price) {
    return _db.collection('product').doc(id).update({
      'Name': name,
      'Quantity': quantity,
      'Price': price,
    });
  }

  // Delete a product
  Future<void> deleteProduct(String id) {
    return _db.collection('product').doc(id).delete();
  }

  // Stream to get products
  Stream<QuerySnapshot> getProductStream() {
    return _db.collection('product').snapshots();
  }
}
