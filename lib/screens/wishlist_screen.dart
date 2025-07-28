// lib/screens/wishlist_screen.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart';
import 'package:kaadu_organics_app/screens/home_screen.dart'; // To reuse ProductCard
import 'package:provider/provider.dart'; // NEW: Import Provider
import 'package:kaadu_organics_app/providers/wishlist_provider.dart'; // NEW: Import WishlistProvider

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure wishlist is fetched when the screen is initialized or revisited
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WishlistProvider>(context, listen: false).fetchWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to changes in WishlistProvider
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        if (wishlistProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('My Wishlist')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (wishlistProvider.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('My Wishlist')),
            body: Center(
              child: Text(
                'Error: ${wishlistProvider.errorMessage}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
              ),
            ),
          );
        }

        final wishlist = wishlistProvider.wishlistItems;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Wishlist'),
          ),
          body: wishlist.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border_rounded,
                          size: 80,
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withAlpha((255 * 0.3).round())),
                      const SizedBox(height: 16.0),
                      Text(
                        'Your Wishlist is Empty!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withAlpha((255 * 0.5).round())),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Add items you love to your wishlist.',
                        style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withAlpha((255 * 0.7).round())),
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to home screen to browse products
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/', (route) => false);
                        },
                        child: const Text('Start Shopping'),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.75, // Adjust as needed for card size
                  ),
                  itemCount: wishlist.length,
                  itemBuilder: (context, index) {
                    final product = wishlist[index];
                    return ProductCard(product: product); // Reuse ProductCard
                  },
                ),
        );
      },
    );
  }
}
