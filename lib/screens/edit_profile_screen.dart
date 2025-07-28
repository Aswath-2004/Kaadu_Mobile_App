// edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart'; // Import models to access dummyUserAccountsNotifier

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  final TextEditingController _birthDateController =
      TextEditingController(text: '26 July, 2004'); // Static for now

  // Helper to get the current active user
  UserAccount get _currentUser => dummyUserAccountsNotifier.value.firstWhere(
        (account) => account.isActive,
        orElse: () => dummyUserAccountsNotifier.value.first,
      );

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user's data
    _nameController = TextEditingController(text: _currentUser.name);
    _phoneController = TextEditingController(text: _currentUser.phoneNumber);
    _emailController = TextEditingController(text: _currentUser.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2004, 7, 26),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF5CB85C), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.white, // Body text color
              surface: Theme.of(context).cardColor, // Dialog background color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF5CB85C), // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            '${picked.day} ${_getMonthName(picked.month)}, ${picked.year}';
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  void _saveChanges() {
    // Create an updated UserAccount object
    final updatedUser = _currentUser.copyWith(
      name: _nameController.text,
      phoneNumber: _phoneController.text,
      email: _emailController.text,
      // Birthdate is static for now, so no need to update it here
    );

    // Find the index of the current user in the list
    final userAccounts =
        List<UserAccount>.from(dummyUserAccountsNotifier.value);
    final index = userAccounts.indexWhere((user) => user.id == updatedUser.id);

    if (index != -1) {
      userAccounts[index] = updatedUser;
      dummyUserAccountsNotifier.value =
          userAccounts; // Update the ValueNotifier
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context); // Go back after saving
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Could not find user to update.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  ValueListenableBuilder<List<UserAccount>>(
                    valueListenable: dummyUserAccountsNotifier,
                    builder: (context, users, child) {
                      final currentUser = _currentUser;
                      return CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey[800],
                        backgroundImage:
                            NetworkImage(currentUser.profileImageUrl),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF5CB85C),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 3),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () {
                          // Change profile picture
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            _buildTextField(
                context, 'Name', _nameController, Icons.person_rounded),
            _buildTextField(
                context, 'Phone Number', _phoneController, Icons.phone_rounded,
                keyboardType: TextInputType.phone),
            _buildTextField(
                context, 'Email', _emailController, Icons.email_rounded,
                keyboardType: TextInputType.emailAddress),
            _buildTextField(context, 'Birth Date', _birthDateController,
                Icons.calendar_today_rounded,
                readOnly: true, onTap: () => _selectDate(context)),
            const SizedBox(height: 32.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges, // Call the new save method
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label,
      TextEditingController controller, IconData icon,
      {TextInputType keyboardType = TextInputType.text,
      bool readOnly = false,
      VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          labelText: label,
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
      ),
    );
  }
}
