// add_edit_address_screen.dart (Updated File)
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart'; // Import the Address model
import 'package:uuid/uuid.dart'; // For generating unique IDs

class AddEditAddressScreen extends StatefulWidget {
  final Address? address; // Nullable for adding new address
  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _streetAddress1Controller;
  late TextEditingController _streetAddress2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late String _selectedAddressType;
  late TextEditingController
      _otherAddressTypeController; // New controller for 'Other'
  bool _isDefault = false;

  final List<String> _addressTypes = ['Home', 'Work', 'Other'];

  @override
  void initState() {
    super.initState();
    _fullNameController =
        TextEditingController(text: widget.address?.fullName ?? '');
    _phoneNumberController =
        TextEditingController(text: widget.address?.phoneNumber ?? '');
    _streetAddress1Controller =
        TextEditingController(text: widget.address?.streetAddress1 ?? '');
    _streetAddress2Controller =
        TextEditingController(text: widget.address?.streetAddress2 ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _postalCodeController =
        TextEditingController(text: widget.address?.postalCode ?? '');
    _selectedAddressType = widget.address?.addressType ?? _addressTypes.first;
    _otherAddressTypeController = TextEditingController(
      text: _addressTypes.contains(widget.address?.addressType)
          ? ''
          : widget.address?.addressType ?? '',
    ); // Initialize for 'Other'
    _isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _streetAddress1Controller.dispose();
    _streetAddress2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _otherAddressTypeController.dispose(); // Dispose new controller
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      String id = widget.address?.id ?? const Uuid().v4();
      String finalAddressType = _selectedAddressType == 'Other'
          ? _otherAddressTypeController.text
          : _selectedAddressType;

      Address newAddress = Address(
        id: id,
        fullName: _fullNameController.text,
        phoneNumber: _phoneNumberController.text,
        streetAddress1: _streetAddress1Controller.text,
        streetAddress2: _streetAddress2Controller.text,
        city: _cityController.text,
        state: _stateController.text,
        postalCode: _postalCodeController.text,
        addressType: finalAddressType,
        isDefault: _isDefault,
      );

      // Update the global dummyAddressesNotifier
      final currentAddresses = List<Address>.from(dummyAddressesNotifier.value);
      if (widget.address == null) {
        // Adding new address
        currentAddresses.add(newAddress);
      } else {
        // Editing existing address
        final index =
            currentAddresses.indexWhere((addr) => addr.id == newAddress.id);
        if (index != -1) {
          currentAddresses[index] = newAddress;
        }
      }

      // Ensure only one address is default if the new/edited one is set to default
      if (newAddress.isDefault) {
        for (int i = 0; i < currentAddresses.length; i++) {
          if (currentAddresses[i].id != newAddress.id) {
            currentAddresses[i].isDefault = false;
          }
        }
      } else if (!currentAddresses.any((addr) => addr.isDefault) &&
          currentAddresses.isNotEmpty) {
        // If no address is default after editing, set the first one as default
        currentAddresses.first.isDefault = true;
      }

      dummyAddressesNotifier.value = currentAddresses; // Trigger update
      Navigator.pop(context, newAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.address == null ? 'Add New Address' : 'Edit Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _fullNameController,
                labelText: 'Full Name',
                icon: Icons.person_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _phoneNumberController,
                labelText: 'Phone Number',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _streetAddress1Controller,
                labelText: 'Street Address 1',
                icon: Icons.location_on_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter street address';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _streetAddress2Controller,
                labelText: 'Street Address 2 (Optional)',
                icon: Icons.location_on_rounded,
                required: false,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
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
                      controller: _stateController,
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
                controller: _postalCodeController,
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
              _buildAddressTypeDropdown(),
              if (_selectedAddressType == 'Other')
                _buildTextField(
                  controller: _otherAddressTypeController,
                  labelText: 'Specify Other Type',
                  icon: Icons.category_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please specify address type';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16.0),
              _buildDefaultAddressToggle(),
              const SizedBox(height: 32.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAddress,
                  child: Text(
                      widget.address == null ? 'Add Address' : 'Save Changes'),
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
    VoidCallback? onTap,
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
        onTap: onTap,
      ),
    );
  }

  Widget _buildAddressTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
            color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withAlpha((255 * 0.3).round()) ??
                Colors.white30),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedAddressType,
        decoration: InputDecoration(
          prefixIcon:
              Icon(Icons.category_rounded, color: const Color(0xFF5CB85C)),
          labelText: 'Address Type',
          labelStyle: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withAlpha((255 * 0.7).round())),
          border: InputBorder.none, // Remove default dropdown border
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        dropdownColor: Theme.of(context).cardColor,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        icon: Icon(Icons.arrow_drop_down_rounded,
            color: Theme.of(context).iconTheme.color),
        onChanged: (String? newValue) {
          setState(() {
            _selectedAddressType = newValue!;
            if (newValue != 'Other') {
              _otherAddressTypeController.clear(); // Clear if not 'Other'
            }
          });
        },
        items: _addressTypes.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select an address type';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDefaultAddressToggle() {
    return Row(
      children: [
        Checkbox(
          value: _isDefault,
          onChanged: (bool? newValue) {
            setState(() {
              _isDefault = newValue ?? false;
            });
          },
          activeColor: const Color(0xFF5CB85C),
        ),
        Text(
          'Set as default address',
          style:
              TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
      ],
    );
  }
}
