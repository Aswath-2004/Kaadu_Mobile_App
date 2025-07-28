// lib/providers/address_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaadu_organics_app/models.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:uuid/uuid.dart'; // For generating unique IDs

class AddressProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final String _appId;

  List<Address> _addresses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AddressProvider({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required String appId,
  })  : _firestore = firestore,
        _auth = auth,
        _appId = appId {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        fetchAddresses(); // Fetch addresses when user logs in
      } else {
        _addresses = []; // Clear addresses if user logs out
        notifyListeners();
      }
    });
  }

  String get _userId {
    return _auth.currentUser?.uid ??
        const Uuid().v4(); // Use UUID for anonymous users
  }

  CollectionReference get _userAddressesCollection {
    return _firestore
        .collection('artifacts')
        .doc(_appId)
        .collection('users')
        .doc(_userId)
        .collection('addresses');
  }

  Future<void> fetchAddresses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await _userAddressesCollection.get();
      _addresses = querySnapshot.docs
          .map((doc) => Address.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Ensure at least one address is default if available
      if (_addresses.isNotEmpty && !_addresses.any((addr) => addr.isDefault)) {
        _addresses.first.isDefault = true;
        await _userAddressesCollection
            .doc(_addresses.first.id)
            .update({'isDefault': true});
      }
      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Failed to load addresses: $e';
      _isLoading = false;
      debugPrint('Address fetch error: $_errorMessage');
    } finally {
      notifyListeners();
    }
  }

  Future<void> addAddress(Address address) async {
    try {
      // If the new address is set as default, unset others
      if (address.isDefault) {
        for (var addr in _addresses) {
          if (addr.isDefault) {
            addr.isDefault = false;
            await _userAddressesCollection
                .doc(addr.id)
                .update({'isDefault': false});
          }
        }
      } else if (_addresses.isEmpty) {
        // If this is the very first address, make it default regardless
        address.isDefault = true;
      }

      await _userAddressesCollection.doc(address.id).set(address.toJson());
      _addresses.add(address);
      _addresses.sort((a, b) => (b.isDefault ? 1 : 0)
          .compareTo(a.isDefault ? 1 : 0)); // Keep default first
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add address: $e';
      debugPrint('Add address error: $_errorMessage');
      notifyListeners();
    }
  }

  Future<void> updateAddress(Address updatedAddress) async {
    try {
      // If the updated address is set as default, unset others
      if (updatedAddress.isDefault) {
        for (var addr in _addresses) {
          if (addr.id != updatedAddress.id && addr.isDefault) {
            addr.isDefault = false;
            await _userAddressesCollection
                .doc(addr.id)
                .update({'isDefault': false});
          }
        }
      } else {
        // If the updated address is no longer default, and it was the only default,
        // set another one as default if available.
        if (_addresses.where((addr) => addr.isDefault).length == 1 &&
            _addresses.first.id == updatedAddress.id) {
          // If the one being updated was the only default, and it's being unset,
          // find another one to set as default.
          final otherAddresses =
              _addresses.where((addr) => addr.id != updatedAddress.id).toList();
          if (otherAddresses.isNotEmpty) {
            otherAddresses.first.isDefault = true;
            await _userAddressesCollection
                .doc(otherAddresses.first.id)
                .update({'isDefault': true});
          }
        }
      }

      await _userAddressesCollection
          .doc(updatedAddress.id)
          .update(updatedAddress.toJson());
      final index =
          _addresses.indexWhere((addr) => addr.id == updatedAddress.id);
      if (index != -1) {
        _addresses[index] = updatedAddress;
      }
      _addresses.sort((a, b) => (b.isDefault ? 1 : 0)
          .compareTo(a.isDefault ? 1 : 0)); // Keep default first
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update address: $e';
      debugPrint('Update address error: $_errorMessage');
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      final addressToDelete =
          _addresses.firstWhere((addr) => addr.id == addressId);

      // If deleting the default address, set another one as default if available
      if (addressToDelete.isDefault && _addresses.length > 1) {
        final otherAddresses =
            _addresses.where((addr) => addr.id != addressId).toList();
        if (otherAddresses.isNotEmpty) {
          otherAddresses.first.isDefault = true;
          await _userAddressesCollection
              .doc(otherAddresses.first.id)
              .update({'isDefault': true});
        }
      }

      await _userAddressesCollection.doc(addressId).delete();
      _addresses.removeWhere((addr) => addr.id == addressId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete address: $e';
      debugPrint('Delete address error: $_errorMessage');
      notifyListeners();
    }
  }

  // Helper to get the default address
  Address? getDefaultAddress() {
    return _addresses.firstWhereOrNull((addr) => addr.isDefault);
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
