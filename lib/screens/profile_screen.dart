// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart'; // Import models to access UserAccount

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Get the currently active user for display
  UserAccount get _currentUser =>
      dummyUserAccountsNotifier.value.firstWhere((account) => account.isActive,
          orElse: () => dummyUserAccountsNotifier.value.first);

  void _switchAccount(UserAccount account) {
    setState(() {
      // Create a new list with updated isActive status for all accounts
      final updatedAccounts = dummyUserAccountsNotifier.value.map((user) {
        return user.copyWith(isActive: (user.id == account.id));
      }).toList();
      dummyUserAccountsNotifier.value =
          updatedAccounts; // Assign new list to trigger update
    });
    if (mounted) {
      // Guard against using BuildContext across async gaps
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Switched to ${account.name}\'s account!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to dummyUserAccountsNotifier for real-time updates to the profile
    return ValueListenableBuilder<List<UserAccount>>(
      valueListenable: dummyUserAccountsNotifier,
      builder: (context, users, child) {
        final currentUser =
            _currentUser; // Get current user from the notifier's value

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            actions: [
              IconButton(
                icon: Icon(Icons.edit_rounded,
                    color: Theme.of(context).iconTheme.color),
                onPressed: () {
                  // Navigate to Edit Profile screen (for current active user)
                  Navigator.pushNamed(context, '/edit_profile');
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey[800],
                        backgroundImage:
                            NetworkImage(currentUser.profileImageUrl),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF5CB85C),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
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
                _buildProfileInfoCard(
                    context, currentUser.name, Icons.person_rounded),
                _buildProfileInfoCard(
                    context, currentUser.phoneNumber, Icons.phone_rounded),
                _buildProfileInfoCard(
                    context, currentUser.email, Icons.email_rounded),
                _buildProfileInfoCard(
                    context,
                    '26 July, 2004',
                    Icons
                        .calendar_today_rounded), // Birth date is static for now
                const SizedBox(height: 24.0),
                ListTile(
                  leading: Icon(Icons.shopping_bag_rounded,
                      color: Theme.of(context).iconTheme.color),
                  title: Text('My Orders',
                      style: Theme.of(context).textTheme.titleMedium),
                  trailing: Icon(Icons.arrow_forward_ios_rounded,
                      color: Theme.of(context)
                          .iconTheme
                          .color
                          ?.withAlpha((255 * 0.5).round()),
                      size: 18),
                  onTap: () {
                    // Navigate to My Orders screen
                    Navigator.pushNamed(context, '/my_orders');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.location_on_rounded,
                      color: Theme.of(context)
                          .iconTheme
                          .color), // Added Address option
                  title: Text('My Addresses',
                      style: Theme.of(context).textTheme.titleMedium),
                  trailing: Icon(Icons.arrow_forward_ios_rounded,
                      color: Theme.of(context)
                          .iconTheme
                          .color
                          ?.withAlpha((255 * 0.5).round()),
                      size: 18),
                  onTap: () {
                    // Navigate to My Addresses screen
                    Navigator.pushNamed(context, '/addresses');
                  },
                ),
                ListTile(
                  // New Payment Methods ListTile
                  leading: Icon(Icons.payment_rounded,
                      color: Theme.of(context).iconTheme.color),
                  title: Text('Payment Methods',
                      style: Theme.of(context).textTheme.titleMedium),
                  trailing: Icon(Icons.arrow_forward_ios_rounded,
                      color: Theme.of(context)
                          .iconTheme
                          .color
                          ?.withAlpha((255 * 0.5).round()),
                      size: 18),
                  onTap: () {
                    // Navigate to Payment Methods screen
                    Navigator.pushNamed(context, '/payment_methods');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings_rounded,
                      color: Theme.of(context).iconTheme.color),
                  title: Text('Settings',
                      style: Theme.of(context).textTheme.titleMedium),
                  trailing: Icon(Icons.arrow_forward_ios_rounded,
                      color: Theme.of(context)
                          .iconTheme
                          .color
                          ?.withAlpha((255 * 0.5).round()),
                      size: 18),
                  onTap: () {
                    // Navigate to Settings
                  },
                ),
                Divider(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withAlpha((255 * 0.3).round()),
                    height: 24),
                // Account Management Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Account Management',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Column(
                  children: users.map((account) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(account.profileImageUrl),
                        radius: 20,
                      ),
                      title: Text(account.name,
                          style: Theme.of(context).textTheme.titleMedium),
                      trailing: Row(
                        // Use a Row to contain multiple trailing widgets
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!account
                              .isActive) // Only show Switch button if not active
                            TextButton(
                              onPressed: () => _switchAccount(account),
                              child: const Text('Switch'),
                            ),
                          if (account.isActive) // Show checkmark only if active
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF5CB85C)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                ListTile(
                  // New Add Account ListTile
                  leading: Icon(Icons.person_add_rounded,
                      color: Theme.of(context).iconTheme.color),
                  title: Text('Add New Account',
                      style: Theme.of(context).textTheme.titleMedium),
                  trailing: Icon(Icons.arrow_forward_ios_rounded,
                      color: Theme.of(context)
                          .iconTheme
                          .color
                          ?.withAlpha((255 * 0.5).round()),
                      size: 18),
                  onTap: () async {
                    final newAccount = await Navigator.pushNamed(context,
                        '/add_new_account'); // Navigate to AddNewAccountScreen
                    if (newAccount != null && newAccount is UserAccount) {
                      // Add the new account to the notifier's value
                      final updatedAccounts = List<UserAccount>.from(
                          dummyUserAccountsNotifier.value)
                        ..add(newAccount);
                      dummyUserAccountsNotifier.value = updatedAccounts;
                      // Optionally set the new account as active
                      _switchAccount(newAccount);
                      if (mounted) {
                        // Guard against using BuildContext across async gaps
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('New account added successfully!')),
                        );
                      }
                    }
                  },
                ),
                // Become a Seller section
                Divider(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withAlpha((255 * 0.3).round()),
                    height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Seller Options',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Conditionally render based on isSeller and isSellerProfileComplete
                if (!currentUser.isSeller)
                  ListTile(
                    leading: Icon(Icons.store_rounded,
                        color: Theme.of(context).iconTheme.color),
                    title: Text('Become a Seller',
                        style: Theme.of(context).textTheme.titleMedium),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white54, size: 18),
                    onTap: () {
                      Navigator.pushNamed(context, '/become_seller',
                          arguments: currentUser);
                    },
                  )
                else if (!currentUser.isSellerProfileComplete)
                  ListTile(
                    leading: Icon(Icons.store_rounded,
                        color: Theme.of(context).iconTheme.color),
                    title: Text('Complete Seller Profile',
                        style: Theme.of(context).textTheme.titleMedium),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white54, size: 18),
                    onTap: () {
                      Navigator.pushNamed(context, '/become_seller',
                          arguments: currentUser);
                    },
                  )
                else // Seller profile is complete
                  ListTile(
                    leading: Icon(Icons.dashboard_rounded,
                        color: Theme.of(context).iconTheme.color),
                    title: Text('Seller Dashboard',
                        style: Theme.of(context).textTheme.titleMedium),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white54, size: 18),
                    onTap: () {
                      Navigator.pushNamed(context, '/seller_dashboard');
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.red),
                  title: Text('Logout',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.red)),
                  onTap: () {
                    // Handle logout
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileInfoCard(
      BuildContext context, String text, IconData icon) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF5CB85C)),
            const SizedBox(width: 16.0),
            Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ],
        ),
      ),
    );
  }
}
