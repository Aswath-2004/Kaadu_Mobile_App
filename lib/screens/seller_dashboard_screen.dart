  // lib/screens/seller_dashboard_screen.dart
  import 'package:flutter/material.dart';

  class SellerDashboardScreen extends StatelessWidget {
    const SellerDashboardScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Seller Dashboard'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.store_rounded,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24.0),
                Text(
                  'Welcome, Seller!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'This is your seller dashboard. Here you can manage your products, view orders, track earnings, and more.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withAlpha((255 * 0.8).round()),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () {
                    // Placeholder for navigating to product management
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Manage Products (Coming Soon!)')),
                    );
                  },
                  child: const Text('Manage Products'),
                ),
                const SizedBox(height: 12.0),
                OutlinedButton(
                  onPressed: () {
                    // Placeholder for navigating to order management
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('View Orders (Coming Soon!)')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: Text(
                    'View Orders',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
