import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/item_model.dart';

/// Service for managing item CRUD operations in Firestore
///
/// Provides methods for creating, reading, updating, and deleting items
/// in the 'items' collection.
class ItemService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _collectionName = 'items';

  /// Fetches all items from Firestore, ordered by nama_barang
  ///
  /// Returns a list of ItemModel objects
  /// Throws an exception if the fetch operation fails
  Future<List<ItemModel>> getItems() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('nama_barang')
          .get();

      return querySnapshot.docs.map((doc) {
        return ItemModel.fromMap(doc.data());
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  /// Adds a new item to Firestore
  ///
  /// Returns the document ID of the newly created item
  /// Throws an exception if the add operation fails
  Future<String> addItem(ItemModel item) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add(item.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }

  /// Updates an existing item in Firestore
  ///
  /// Finds the item by id_barang and updates it with the new data
  /// Throws an exception if the update operation fails
  Future<void> updateItem(ItemModel item) async {
    try {
      // Query to find the document with matching id_barang
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('id_barang', isEqualTo: item.idBarang)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Item with id_barang "${item.idBarang}" not found');
      }

      final docId = querySnapshot.docs.first.id;
      await _firestore
          .collection(_collectionName)
          .doc(docId)
          .update(item.toMap());
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  /// Deletes an item from Firestore by id_barang
  ///
  /// Throws an exception if the delete operation fails
  Future<void> deleteItem(String idBarang) async {
    try {
      // Query to find the document with matching id_barang
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('id_barang', isEqualTo: idBarang)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Item with id_barang "$idBarang" not found');
      }

      final docId = querySnapshot.docs.first.id;
      await _firestore.collection(_collectionName).doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  /// Gets a single item by id_barang
  ///
  /// Returns the ItemModel if found, null otherwise
  /// Throws an exception if the query operation fails
  Future<ItemModel?> getItemById(String idBarang) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('id_barang', isEqualTo: idBarang)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return ItemModel.fromMap(querySnapshot.docs.first.data());
    } catch (e) {
      throw Exception('Failed to get item by ID: $e');
    }
  }

  /// Checks if an item with the given id_barang already exists
  ///
  /// Returns true if the item exists, false otherwise
  Future<bool> checkIdBarangExists(String idBarang) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('id_barang', isEqualTo: idBarang)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check ID existence: $e');
    }
  }
}
