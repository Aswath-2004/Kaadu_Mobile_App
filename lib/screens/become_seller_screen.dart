// lib/screens/become_seller_screen.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart'; // Import your models
import 'package:uuid/uuid.dart'; // For generating unique IDs

class BecomeSellerScreen extends StatefulWidget {
  final UserAccount? userAccount; // The user account to potentially update
  const BecomeSellerScreen({super.key, this.userAccount});

  @override
  State<BecomeSellerScreen> createState() => _BecomeSellerScreenState();
}

class _BecomeSellerScreenState extends State<BecomeSellerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _storeNameController;
  late TextEditingController _sellerAddress1Controller;
  late TextEditingController _sellerAddress2Controller;
  late TextEditingController _sellerCityController;
  late TextEditingController _sellerStateController;
  late TextEditingController _sellerPostalCodeController;
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscCodeController;
  late TextEditingController _accountHolderNameController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing seller data if available
    _storeNameController =
        TextEditingController(text: widget.userAccount?.storeName ?? '');
    _sellerAddress1Controller =
        TextEditingController(text: widget.userAccount?.sellerAddress1 ?? '');
    _sellerAddress2Controller =
        TextEditingController(text: widget.userAccount?.sellerAddress2 ?? '');
    _sellerCityController =
        TextEditingController(text: widget.userAccount?.sellerCity ?? '');
    _sellerStateController =
        TextEditingController(text: widget.userAccount?.sellerState ?? '');
    _sellerPostalCodeController =
        TextEditingController(text: widget.userAccount?.sellerPostalCode ?? '');

    // Initialize bank details controllers
    _bankNameController = TextEditingController(
        text: widget.userAccount?.bankDetails?.bankName ?? '');
    _accountNumberController = TextEditingController(
        text: widget.userAccount?.bankDetails?.accountNumber ?? '');
    _ifscCodeController = TextEditingController(
        text: widget.userAccount?.bankDetails?.ifscCode ?? '');
    _accountHolderNameController = TextEditingController(
        text: widget.userAccount?.bankDetails?.accountHolderName ?? '');
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _sellerAddress1Controller.dispose();
    _sellerAddress2Controller.dispose();
    _sellerCityController.dispose();
    _sellerStateController.dispose();
    _sellerPostalCodeController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _accountHolderNameController.dispose();
    super.dispose();
  }

  void _saveSellerProfile() {
    if (_formKey.currentState!.validate()) {
      // Create BankDetails object
      final BankDetails bankDetails = BankDetails(
        bankName: _bankNameController.text,
        accountNumber: _accountNumberController.text,
        ifscCode: _ifscCodeController.text,
        accountHolderName: _accountHolderNameController.text,
      );

      // Create an updated UserAccount object with seller details
      final updatedUserAccount = widget.userAccount!.copyWith(
        isSeller: true, // Mark as seller
        isSellerProfileComplete: true, // Mark profile as complete
        storeName: _storeNameController.text,
        sellerAddress1: _sellerAddress1Controller.text,
        sellerAddress2: _sellerAddress2Controller.text,
        sellerCity: _sellerCityController.text,
        sellerState: _sellerStateController.text,
        sellerPostalCode: _sellerPostalCodeController.text,
        bankDetails: bankDetails,
      );

      // Find the current user in the dummyUserAccountsNotifier and update it
      final currentAccounts =
          List<UserAccount>.from(dummyUserAccountsNotifier.value);
      final index = currentAccounts
          .indexWhere((user) => user.id == updatedUserAccount.id);

      if (index != -1) {
        currentAccounts[index] = updatedUserAccount;
        dummyUserAccountsNotifier.value =
            currentAccounts; // Update the ValueNotifier
      } else {
        // This case should ideally not happen if a userAccount is passed
        // but as a fallback, you might add it or handle it as an error.
        print('Error: User account not found for update.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seller profile saved successfully!')),
      );
      Navigator.pop(context); // Go back after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Seller'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell us about your store:',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _storeNameController,
                labelText: 'Store Name',
                icon: Icons.store_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your store name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              Text(
                'Store Address:',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _sellerAddress1Controller,
                labelText: 'Address Line 1',
                icon: Icons.location_on_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address line 1';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _sellerAddress2Controller,
                labelText: 'Address Line 2 (Optional)',
                icon: Icons.location_on_rounded,
                required: false,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _sellerCityController,
                      labelText: 'City',
                      icon: Icons.location_city_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter city';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildTextField(
                      controller: _sellerStateController,
                      labelText: 'State',
                      icon: Icons.map_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter state';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: _sellerPostalCodeController,
                labelText: 'Postal Code',
                icon: Icons.local_post_office_rounded,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Please enter a valid postal code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              Text(
                'Bank Details for Payouts:',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _bankNameController,
                labelText: 'Bank Name',
                icon: Icons.account_balance_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter bank name';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _accountNumberController,
                labelText: 'Account Number',
                icon: Icons.credit_card_rounded,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account number';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _ifscCodeController,
                labelText: 'IFSC Code',
                icon: Icons.code_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter IFSC code';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _accountHolderNameController,
                labelText: 'Account Holder Name',
                icon: Icons.person_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account holder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSellerProfile,
                  child: const Text('Save Seller Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withAlpha((255 * 0.7).round())),
          prefixIcon: Icon(icon, color: const Color(0xFF5CB85C)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
        validator: required ? validator : null,
      ),
    );
  }
}
