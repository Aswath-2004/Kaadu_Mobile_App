// screens/add_new_account_screen.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

class AddNewAccountScreen extends StatefulWidget {
  const AddNewAccountScreen({super.key});

  @override
  State<AddNewAccountScreen> createState() => _AddNewAccountScreenState();
}

class _AddNewAccountScreenState extends State<AddNewAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  void _addNewAccount() {
    if (_formKey.currentState!.validate()) {
      final newAccount = UserAccount(
        id: const Uuid().v4(),
        name: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneNumberController.text,
        isActive: false, // New account is not active by default
        profileImageUrl:
            'https://placehold.co/140x140/34A853/FFFFFF?text=${_nameController.text.substring(0, 1).toUpperCase()}', // Generate initial
      );
      Navigator.pop(context, newAccount);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter details for the new account:',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24.0),
              _buildTextField(
                controller: _nameController,
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
                controller: _emailController,
                labelText: 'Email',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
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
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addNewAccount,
                  child: const Text('Create Account'),
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
          prefixIcon: Icon(icon, color: const Color(0xFF5CB85C)),
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
}
