// screens/add_edit_payment_method_screen.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart'; // Import the PaymentMethod model
import 'package:uuid/uuid.dart'; // For generating unique IDs
import 'package:provider/provider.dart'; // NEW: Import Provider
import 'package:kaadu_organics_app/providers/payment_method_provider.dart'; // NEW: Import PaymentMethodProvider

class AddEditPaymentMethodScreen extends StatefulWidget {
  final PaymentMethod? paymentMethod; // Nullable for adding new method
  const AddEditPaymentMethodScreen({super.key, this.paymentMethod});

  @override
  State<AddEditPaymentMethodScreen> createState() =>
      _AddEditPaymentMethodScreenState();
}

class _AddEditPaymentMethodScreenState
    extends State<AddEditPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedPaymentType;
  late TextEditingController _cardHolderNameController;
  late TextEditingController _cardNumberController;
  late TextEditingController _expiryDateController;
  late TextEditingController _cvvController;
  late TextEditingController _upiIdController;
  late TextEditingController _bankNameController;
  bool _isDefault = false;

  final List<String> _paymentTypes = [
    'Credit Card',
    'Debit Card',
    'UPI',
    'Net Banking',
    'Cash on Delivery',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPaymentType = widget.paymentMethod?.type ?? _paymentTypes.first;
    _cardHolderNameController =
        TextEditingController(text: widget.paymentMethod?.cardHolderName ?? '');
    _cardNumberController = TextEditingController(
        text: widget.paymentMethod?.lastFourDigits ??
            ''); // We only store last 4 for security
    _expiryDateController =
        TextEditingController(text: widget.paymentMethod?.expiryDate ?? '');
    _cvvController = TextEditingController(); // CVV is never stored
    _upiIdController =
        TextEditingController(text: widget.paymentMethod?.upiId ?? '');
    _bankNameController =
        TextEditingController(text: widget.paymentMethod?.bankName ?? '');
    _isDefault = widget.paymentMethod?.isDefault ?? false;
  }

  @override
  void dispose() {
    _cardHolderNameController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _upiIdController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  void _savePaymentMethod() async {
    if (_formKey.currentState!.validate()) {
      final paymentMethodProvider =
          Provider.of<PaymentMethodProvider>(context, listen: false);
      String id = widget.paymentMethod?.id ?? const Uuid().v4();
      PaymentMethod newMethod;

      switch (_selectedPaymentType) {
        case 'Credit Card':
        case 'Debit Card':
          newMethod = PaymentMethod(
            id: id,
            type: _selectedPaymentType,
            cardHolderName: _cardHolderNameController.text,
            lastFourDigits: _cardNumberController.text.substring(
                _cardNumberController.text.length - 4), // Store only last 4
            expiryDate: _expiryDateController.text,
            isDefault: _isDefault,
          );
          break;
        case 'UPI':
          newMethod = PaymentMethod(
            id: id,
            type: _selectedPaymentType,
            upiId: _upiIdController.text,
            isDefault: _isDefault,
          );
          break;
        case 'Net Banking':
          newMethod = PaymentMethod(
            id: id,
            type: _selectedPaymentType,
            bankName: _bankNameController.text,
            isDefault: _isDefault,
          );
          break;
        case 'Cash on Delivery':
          newMethod = PaymentMethod(
            id: id,
            type: _selectedPaymentType,
            isDefault: _isDefault,
          );
          break;
        default:
          newMethod = PaymentMethod(
            id: id,
            type: 'Unknown',
            isDefault: _isDefault,
          );
      }

      if (widget.paymentMethod == null) {
        // Adding new payment method
        await paymentMethodProvider.addPaymentMethod(newMethod);
      } else {
        // Editing existing payment method
        await paymentMethodProvider.updatePaymentMethod(newMethod);
      }

      if (!mounted) return; // Check if the widget is still mounted
      Navigator.pop(context, newMethod);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paymentMethod == null
            ? 'Add New Payment Method'
            : 'Edit Payment Method'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPaymentTypeDropdown(),
              const SizedBox(height: 24.0),
              if (_selectedPaymentType == 'Credit Card' ||
                  _selectedPaymentType == 'Debit Card') ...[
                _buildTextField(
                  controller: _cardHolderNameController,
                  labelText: 'Card Holder Name',
                  icon: Icons.person_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card holder name';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _cardNumberController,
                  labelText: 'Card Number',
                  icon: Icons.credit_card_rounded,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 16) {
                      return 'Please enter a valid 16-digit card number';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _expiryDateController,
                        labelText: 'Expiry Date (MM/YY)',
                        icon: Icons.calendar_today_rounded,
                        keyboardType: TextInputType.datetime,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$')
                                  .hasMatch(value)) {
                            return 'Enter MM/YY';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildTextField(
                        controller: _cvvController,
                        labelText: 'CVV',
                        icon: Icons.lock_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length != 3) {
                            return 'Enter 3-digit CVV';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ] else if (_selectedPaymentType == 'UPI') ...[
                _buildTextField(
                  controller: _upiIdController,
                  labelText: 'UPI ID',
                  icon: Icons.qr_code_rounded,
                  keyboardType: TextInputType
                      .emailAddress, // UPI IDs often look like emails
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter UPI ID';
                    }
                    return null;
                  },
                ),
              ] else if (_selectedPaymentType == 'Net Banking') ...[
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
              ],
              const SizedBox(height: 16.0),
              _buildDefaultMethodToggle(),
              const SizedBox(height: 32.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savePaymentMethod,
                  child: Text(widget.paymentMethod == null
                      ? 'Add Payment Method'
                      : 'Save Changes'),
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
          prefixIcon:
              Icon(icon, color: const Color(0xFF5CB85C)), // Removed const
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPaymentTypeDropdown() {
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
        value: _selectedPaymentType,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.payment_rounded,
              color: Color(0xFF5CB85C)), // Added const
          labelText: 'Payment Type',
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
            _selectedPaymentType = newValue!;
            // Clear controllers when changing type to avoid stale data
            _cardHolderNameController.clear();
            _cardNumberController.clear();
            _expiryDateController.clear();
            _cvvController.clear();
            _upiIdController.clear();
            _bankNameController.clear();
          });
        },
        items: _paymentTypes.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a payment type';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDefaultMethodToggle() {
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
          'Set as default payment method',
          style:
              TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
      ],
    );
  }
}
