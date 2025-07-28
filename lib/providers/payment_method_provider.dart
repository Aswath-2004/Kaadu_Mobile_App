// lib/providers/payment_method_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaadu_organics_app/models.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:uuid/uuid.dart'; // For generating unique IDs

class PaymentMethodProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final String _appId;

  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PaymentMethod> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PaymentMethodProvider({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required String appId,
  })  : _firestore = firestore,
        _auth = auth,
        _appId = appId {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        fetchPaymentMethods(); // Fetch payment methods when user logs in
      } else {
        _paymentMethods = []; // Clear payment methods if user logs out
        notifyListeners();
      }
    });
  }

  String get _userId {
    return _auth.currentUser?.uid ??
        const Uuid().v4(); // Use UUID for anonymous users
  }

  CollectionReference get _userPaymentMethodsCollection {
    return _firestore
        .collection('artifacts')
        .doc(_appId)
        .collection('users')
        .doc(_userId)
        .collection('paymentMethods');
  }

  Future<void> fetchPaymentMethods() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await _userPaymentMethodsCollection.get();
      _paymentMethods = querySnapshot.docs
          .map((doc) =>
              PaymentMethod.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Ensure at least one payment method is default if available
      if (_paymentMethods.isNotEmpty &&
          !_paymentMethods.any((method) => method.isDefault)) {
        _paymentMethods.first.isDefault = true;
        await _userPaymentMethodsCollection
            .doc(_paymentMethods.first.id)
            .update({'isDefault': true});
      }
      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Failed to load payment methods: $e';
      _isLoading = false;
      debugPrint('Payment method fetch error: $_errorMessage');
    } finally {
      notifyListeners();
    }
  }

  Future<void> addPaymentMethod(PaymentMethod method) async {
    try {
      // If the new method is set as default, unset others
      if (method.isDefault) {
        for (var pm in _paymentMethods) {
          if (pm.isDefault) {
            pm.isDefault = false;
            await _userPaymentMethodsCollection
                .doc(pm.id)
                .update({'isDefault': false});
          }
        }
      } else if (_paymentMethods.isEmpty) {
        // If this is the very first method, make it default regardless
        method.isDefault = true;
      }

      await _userPaymentMethodsCollection.doc(method.id).set(method.toJson());
      _paymentMethods.add(method);
      _paymentMethods.sort((a, b) => (b.isDefault ? 1 : 0)
          .compareTo(a.isDefault ? 1 : 0)); // Keep default first
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add payment method: $e';
      debugPrint('Add payment method error: $_errorMessage');
      notifyListeners();
    }
  }

  Future<void> updatePaymentMethod(PaymentMethod updatedMethod) async {
    try {
      // If the updated method is set as default, unset others
      if (updatedMethod.isDefault) {
        for (var pm in _paymentMethods) {
          if (pm.id != updatedMethod.id && pm.isDefault) {
            pm.isDefault = false;
            await _userPaymentMethodsCollection
                .doc(pm.id)
                .update({'isDefault': false});
          }
        }
      } else {
        // If the updated method is no longer default, and it was the only default,
        // set another one as default if available.
        if (_paymentMethods.where((pm) => pm.isDefault).length == 1 &&
            _paymentMethods.first.id == updatedMethod.id) {
          final otherMethods =
              _paymentMethods.where((pm) => pm.id != updatedMethod.id).toList();
          if (otherMethods.isNotEmpty) {
            otherMethods.first.isDefault = true;
            await _userPaymentMethodsCollection
                .doc(otherMethods.first.id)
                .update({'isDefault': true});
          }
        }
      }

      await _userPaymentMethodsCollection
          .doc(updatedMethod.id)
          .update(updatedMethod.toJson());
      final index =
          _paymentMethods.indexWhere((pm) => pm.id == updatedMethod.id);
      if (index != -1) {
        _paymentMethods[index] = updatedMethod;
      }
      _paymentMethods.sort((a, b) => (b.isDefault ? 1 : 0)
          .compareTo(a.isDefault ? 1 : 0)); // Keep default first
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update payment method: $e';
      debugPrint('Update payment method error: $_errorMessage');
      notifyListeners();
    }
  }

  Future<void> deletePaymentMethod(String methodId) async {
    try {
      final methodToDelete =
          _paymentMethods.firstWhere((pm) => pm.id == methodId);

      // If deleting the default method, set another one as default if available
      if (methodToDelete.isDefault && _paymentMethods.length > 1) {
        final otherMethods =
            _paymentMethods.where((pm) => pm.id != methodId).toList();
        if (otherMethods.isNotEmpty) {
          otherMethods.first.isDefault = true;
          await _userPaymentMethodsCollection
              .doc(otherMethods.first.id)
              .update({'isDefault': true});
        }
      }

      await _userPaymentMethodsCollection.doc(methodId).delete();
      _paymentMethods.removeWhere((pm) => pm.id == methodId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete payment method: $e';
      debugPrint('Delete payment method error: $_errorMessage');
      notifyListeners();
    }
  }

  // Helper to get the default payment method
  PaymentMethod? getDefaultPaymentMethod() {
    return _paymentMethods.firstWhereOrNull((method) => method.isDefault);
  }
}

// Extension to provide firstWhereOrNull, similar to what collection does
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
