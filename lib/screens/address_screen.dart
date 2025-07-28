// address_screen.dart (Updated File)
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart'; // Import the Address model
import 'package:provider/provider.dart'; // NEW: Import Provider
import 'package:kaadu_organics_app/providers/address_provider.dart'; // NEW: Import AddressProvider

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AddressProvider>(context, listen: false).fetchAddresses();
    });
  }

  void _setDefaultAddress(String addressId) {
    final addressProvider =
        Provider.of<AddressProvider>(context, listen: false);
    final addressToSetDefault =
        addressProvider.addresses.firstWhere((addr) => addr.id == addressId);
    addressProvider
        .updateAddress(addressToSetDefault.copyWith(isDefault: true));
    if (!mounted) return; // Guard against context use after async operation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Default address updated!')),
    );
  }

  void _deleteAddress(String addressId) {
    final addressProvider =
        Provider.of<AddressProvider>(context, listen: false);
    addressProvider.deleteAddress(addressId);
    if (!mounted) return; // Guard against context use after async operation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address deleted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
      ),
      body: addressProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : addressProvider.errorMessage != null
              ? Center(child: Text('Error: ${addressProvider.errorMessage}'))
              : addressProvider.addresses.isEmpty
                  ? Center(
                      child: Text(
                        'No addresses saved. Add one!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withAlpha((255 * 0.5).round())),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: addressProvider.addresses.length,
                      itemBuilder: (context, index) {
                        final address = addressProvider.addresses[index];
                        return AddressCard(
                          address: address,
                          onSetDefault: _setDefaultAddress,
                          onDelete: _deleteAddress,
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newAddress =
              await Navigator.pushNamed(context, '/add_edit_address');
          if (!mounted) return; // Check if the widget is still mounted
          if (newAddress != null && newAddress is Address) {
            // AddressProvider.addAddress is already called in add_edit_address_screen
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
                    if (!context.mounted)
                      return; // Check if the widget is still mounted
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
