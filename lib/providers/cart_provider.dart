// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final String _appId; // App ID for Firestore path

  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CartProvider({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required String appId,
  })  : _firestore = firestore,
        _auth = auth,
        _appId = appId {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        fetchCart(); // Fetch cart when auth state changes (e.g., user logs in/out)
      } else {
        // Clear cart if user logs out or is not authenticated
        _cartItems = [];
        notifyListeners();
      }
    });
  }

  // Get the current user ID or a random UUID for anonymous users
  String get _userId {
    return _auth.currentUser?.uid ??
        'anonymous-${_appId}'; // Fallback for anonymous
  }

  // Firestore collection reference for the user's cart
  CollectionReference get _userCartCollection {
    return _firestore
        .collection('artifacts')
        .doc(_appId)
        .collection('users')
        .doc(_userId)
        .collection('cart');
  }

  // Fetch cart items from Firestore
  Future<void> fetchCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await _userCartCollection.get();
      _cartItems = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Assuming Product.fromJson can handle the product data structure stored in Firestore
        // You might need to adjust Product.fromJson or how product data is stored
        return CartItem(
          product: Product.fromJson(
              data['product']), // Reconstruct Product from stored data
          quantity: data['quantity'],
        );
      }).toList();
      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Failed to load cart: $e';
      _isLoading = false;
      debugPrint('Cart fetch error: $_errorMessage');
    } finally {
      notifyListeners();
    }
  }

  // Add item to cart or update quantity
  Future<void> addItem(Product product, {int quantity = 1}) async {
    final existingItemIndex =
        _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex != -1) {
      // Item already in cart, update quantity
      _cartItems[existingItemIndex].quantity += quantity;
      await _userCartCollection.doc(product.id).update({
        'quantity': _cartItems[existingItemIndex].quantity,
      });
    } else {
      // Add new item to cart
      _cartItems.add(CartItem(product: product, quantity: quantity));
      await _userCartCollection.doc(product.id).set({
        'product': product.toJson(), // Store product data as JSON
        'quantity': quantity,
      });
    }
    notifyListeners();
  }

  // Update item quantity
  Future<void> updateItemQuantity(Product product, int newQuantity) async {
    final existingItemIndex =
        _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex != -1) {
      if (newQuantity > 0) {
        _cartItems[existingItemIndex].quantity = newQuantity;
        await _userCartCollection.doc(product.id).update({
          'quantity': newQuantity,
        });
      } else {
        // Remove item if quantity is 0 or less
        await removeItem(product);
      }
    }
    notifyListeners();
  }

  // Remove item from cart
  Future<void> removeItem(Product product) async {
    _cartItems.removeWhere((item) => item.product.id == product.id);
    await _userCartCollection.doc(product.id).delete();
    notifyListeners();
  }

  // Clear the entire cart (local and Firestore)
  Future<void> clearCart() async {
    _cartItems.clear();
    final batch = _firestore.batch();
    final querySnapshot = await _userCartCollection.get();
    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    notifyListeners();
  }

  double get subtotal {
    return _cartItems.fold(
        0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  // NEW: Dynamic Delivery Fee Calculation
  double get deliveryFee {
    if (subtotal < 250.0) {
      // You might want to prevent checkout or show a warning here in the UI
      // For now, let's return a higher fee to indicate it's below threshold
      return 50.0; // Example: Minimum order fee or high shipping below threshold
    } else if (subtotal >= 250.0 && subtotal <= 499.0) {
      return 50.0;
    } else {
      return 0.0; // Free shipping
    }
  }

  double get total {
    return subtotal + deliveryFee;
  }
}
