// address_screen.dart (New File)
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart'; // Import the Address model

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  // Directly use the ValueNotifier's value for the list
  List<Address> get _userAddresses => dummyAddressesNotifier.value;

  void _setDefaultAddress(String addressId) {
    // Create a new list with the updated default status
    final updatedAddresses = _userAddresses.map((address) {
      return Address(
        id: address.id,
        fullName: address.fullName,
        phoneNumber: address.phoneNumber,
        streetAddress1: address.streetAddress1,
        streetAddress2: address.streetAddress2,
        city: address.city,
        state: address.state,
        postalCode: address.postalCode,
        addressType: address.addressType,
        isDefault: (address.id == addressId), // Set this address as default
      );
    }).toList();
    dummyAddressesNotifier.value =
        updatedAddresses; // Assign new list to trigger update
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Default address updated!')),
    );
  }

  void _deleteAddress(String addressId) {
    // Create a new list excluding the deleted address
    final updatedAddresses =
        _userAddresses.where((address) => address.id != addressId).toList();

    // Ensure at least one address is default if any remain and no default is set
    if (updatedAddresses.isNotEmpty &&
        !updatedAddresses.any((addr) => addr.isDefault)) {
      updatedAddresses.first.isDefault = true;
    }
    dummyAddressesNotifier.value =
        updatedAddresses; // Assign new list to trigger update
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address deleted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
      ),
      body: ValueListenableBuilder<List<Address>>(
        valueListenable: dummyAddressesNotifier,
        builder: (context, addresses, child) {
          if (addresses.isEmpty) {
            return Center(
              child: Text(
                'No addresses saved. Add one!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withAlpha((255 * 0.5).round())),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return AddressCard(
                address: address,
                onSetDefault: _setDefaultAddress,
                onDelete: _deleteAddress,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to add new address screen
          final newAddress =
              await Navigator.pushNamed(context, '/add_edit_address');
          if (newAddress != null && newAddress is Address) {
            // Create a new list with the added address
            final updatedAddresses =
                List<Address>.from(dummyAddressesNotifier.value);
            updatedAddresses.add(newAddress);
            // If this is the first address, make it default
            if (updatedAddresses.length == 1) {
              updatedAddresses.first.isDefault = true;
            }
            dummyAddressesNotifier.value =
                updatedAddresses; // Assign new list to trigger update
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Address added successfully!')),
            );
          }
        },
        label: const Text('Add New Address'),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: const Color(0xFF5CB85C),
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class AddressCard extends StatelessWidget {
  final Address address;
  final Function(String) onSetDefault;
  final Function(String) onDelete;

  const AddressCard({
    super.key,
    required this.address,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  address.fullName,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5CB85C),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => onSetDefault(address.id),
                    child: const Text('Set as Default'),
                  ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              address.streetAddress1,
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withAlpha((255 * 0.8).round())),
            ),
            if (address.streetAddress2.isNotEmpty)
              Text(
                address.streetAddress2,
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withAlpha((255 * 0.8).round())),
              ),
            Text(
              '${address.city}, ${address.state} - ${address.postalCode}',
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withAlpha((255 * 0.8).round())),
            ),
            Text(
              'Phone: ${address.phoneNumber}',
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withAlpha((255 * 0.8).round())),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    final updatedAddress = await Navigator.pushNamed(
                      context,
                      '/add_edit_address',
                      arguments: address,
                    );
                    // In a real app, you'd update your state management or refresh data
                    // For this dummy setup, we'll just show a snackbar for now.
                    if (updatedAddress != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Address updated successfully!')),
                      );
                    }
                  },
                  child: const Text('Edit'),
                ),
                TextButton(
                  onPressed: () => onDelete(address.id),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
