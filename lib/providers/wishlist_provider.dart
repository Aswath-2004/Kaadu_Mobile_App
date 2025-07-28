// lib/providers/wishlist_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaadu_organics_app/models.dart'; // Import your Product model
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:uuid/uuid.dart'; // NEW: Import for generating unique IDs

class WishlistProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final String _appId; // NEW: Store the app ID

  List<Product> _wishlistItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get wishlistItems => _wishlistItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // NEW: Modified constructor to accept Firebase instances and appId
  WishlistProvider({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required String appId,
  })  : _firestore = firestore,
        _auth = auth,
        _appId = appId {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        fetchWishlist(); // Fetch wishlist when user signs in
      } else {
        clearWishlist(); // Clear wishlist if user signs out
      }
    });
  }

  // Helper to get the user ID for Firestore path
  String get _userId {
    // If authenticated, use Firebase Auth UID. Otherwise, generate a random ID.
    return _auth.currentUser?.uid ??
        const Uuid().v4(); // Use Uuid for anonymous
  }

  // Firestore collection path for wishlist
  String get _wishlistCollectionPath {
    return 'artifacts/$_appId/users/$_userId/wishlist';
  }

  Future<void> fetchWishlist() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot =
          await _firestore.collection(_wishlistCollectionPath).get();
      _wishlistItems = snapshot.docs
          .map((doc) => Product.fromJson(doc.data())) // Use Product.fromJson
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch wishlist: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching wishlist: $e');
    }
  }

  Future<void> addItem(Product product) async {
    try {
      // Add a document with the product's ID as the document ID
      await _firestore
          .collection(_wishlistCollectionPath)
          .doc(product.id) // Use product.id as document ID
          .set(product.toJson()); // Use product.toJson()
      _wishlistItems.add(product);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add item to wishlist: $e';
      notifyListeners();
      debugPrint('Error adding item to wishlist: $e');
    }
  }

  Future<void> removeItem(Product product) async {
    try {
      await _firestore
          .collection(_wishlistCollectionPath)
          .doc(product.id) // Use product.id as document ID
          .delete();
      _wishlistItems.removeWhere((item) => item.id == product.id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to remove item from wishlist: $e';
      notifyListeners();
      debugPrint('Error removing item from wishlist: $e');
    }
  }

  bool isInWishlist(Product product) {
    return _wishlistItems.any((item) => item.id == product.id);
  }

  // NEW: Add clearWishlist method
  void clearWishlist() {
    _wishlistItems = [];
    notifyListeners();
  }
}
