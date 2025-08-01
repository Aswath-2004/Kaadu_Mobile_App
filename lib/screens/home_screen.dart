// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart';
import 'package:provider/provider.dart';
import 'package:kaadu_organics_app/providers/product_provider.dart';
import 'package:kaadu_organics_app/providers/wishlist_provider.dart';
import 'package:kaadu_organics_app/providers/cart_provider.dart';
import 'package:kaadu_organics_app/providers/address_provider.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const HomeScreen({super.key, required this.toggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Helper to get the current active user
  UserAccount _getCurrentActiveUser(List<UserAccount> users) {
    return users.firstWhere((user) => user.isActive, orElse: () => users.first);
  }

  @override
  void initState() {
    super.initState();
    // Trigger data fetch when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Access the provider and call fetchProducts and fetchCategories
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      Provider.of<ProductProvider>(context, listen: false).fetchCategories();
      // Fetch wishlist and cart when HomeScreen initializes
      Provider.of<WishlistProvider>(context, listen: false).fetchWishlist();
      Provider.of<CartProvider>(context, listen: false).fetchCart();
      Provider.of<AddressProvider>(context, listen: false).fetchAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the ProductProvider for state changes
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100, // Increased toolbar height to accommodate address
        leadingWidth: 0, // Remove leading space
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Listen to dummyUserAccountsNotifier for user name updates
            ValueListenableBuilder<List<UserAccount>>(
              valueListenable: dummyUserAccountsNotifier,
              builder: (context, users, child) {
                final currentUser = _getCurrentActiveUser(users);
                return Text(
                  'Hello ${currentUser.name}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                );
              },
            ),
            // Listen to AddressProvider for address updates
            Consumer<AddressProvider>(
              builder: (context, addressProvider, child) {
                final currentAddress = addressProvider.getDefaultAddress();
                return GestureDetector(
                  onTap: () async {
                    await Navigator.pushNamed(context, '/addresses');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: Color(0xFF5CB85C)),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            currentAddress != null
                                ? 'Delivering to ${currentAddress.fullName} - Update location'
                                : 'No address set - Add location',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 24,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withAlpha((255 * 0.5).round()),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_rounded,
                color: Theme.of(context).iconTheme.color),
            onPressed: () {
              // Navigate to NotificationsScreen
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          IconButton(
            // Added theme toggle button
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: widget.toggleTheme, // Call the toggleTheme callback
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ValueListenableBuilder<List<UserAccount>>(
              valueListenable: dummyUserAccountsNotifier,
              builder: (context, users, child) {
                final currentUser = _getCurrentActiveUser(users);
                return CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  backgroundImage: NetworkImage(currentUser.profileImageUrl),
                );
              },
            ),
          ),
        ],
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productProvider.errorMessage != null
              ? Center(child: Text('Error: ${productProvider.errorMessage}'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search anything here',
                          prefixIcon: Icon(Icons.search_rounded,
                              color: Theme.of(context).hintColor),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.filter_list_rounded,
                                color: Theme.of(context).iconTheme.color),
                            onPressed: () {
                              Navigator.pushNamed(context, '/filter');
                            },
                          ),
                        ),
                        onTap: () {
                          // Navigate to search screen
                          Navigator.pushNamed(context, '/search');
                        },
                      ),
                      const SizedBox(height: 24.0),

                      // Shop by Category - NOW USES FETCHED CATEGORIES
                      Text(
                        'Shop by Category',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        height: 100, // Height for category icons
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: productProvider.categories.length,
                          itemBuilder: (context, index) {
                            final category = productProvider.categories[index];
                            return GestureDetector(
                              onTap: () {
                                // Navigate to category products screen
                                Navigator.pushNamed(context, '/categories',
                                    arguments: category);
                              },
                              child: Container(
                                width: 80,
                                margin: const EdgeInsets.only(right: 12.0),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).cardColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Image.network(
                                          category.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            color: Colors.grey[700],
                                            child: const Icon(
                                                Icons.broken_image,
                                                color: Colors.white,
                                                size: 30),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      category.name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Get special offer banner
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5CB85C).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Get special offer',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                  ),
                                  Text(
                                    'up to 80%',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF5CB85C),
                                        ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Handle offer button tap
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5CB85C),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: const Text(
                                      'Shop Now',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            // Placeholder for offer image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.network(
                                'https://img.pikbest.com/origin/10/06/32/65bpIkbEsTIfr.png!bw700',
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey[700],
                                  child: const Icon(Icons.image_not_supported,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Flash Sale / People's Favorite Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Flash Sale',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              // View all flash sale items
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        height: 220, // Height for product cards
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: productProvider.products.take(3).length,
                          itemBuilder: (context, index) {
                            final product = productProvider.products[index];
                            return SizedBox(
                              width: 180,
                              child: ProductCard(product: product),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // New Arrivals Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'New Arrivals',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              // View all new arrivals
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: productProvider.products.length,
                        itemBuilder: (context, index) {
                          final product = productProvider.products[index];
                          return ProductCard(product: product);
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Access the WishlistProvider and CartProvider
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product_detail', arguments: product);
      },
      child: Card(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Stack(
                    // Use Stack to overlay the favorite icon
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint(
                                'Failed to load image for product ${product.name}: ${product.imageUrl}'); // Debug print
                            return Container(
                              color: Colors.grey[700],
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.white),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        // Use Consumer to rebuild only the IconButton when wishlist changes
                        child: IconButton(
                          icon: Icon(
                            wishlistProvider.isInWishlist(product)
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: wishlistProvider.isInWishlist(product)
                                ? Colors.red
                                : Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            if (wishlistProvider.isInWishlist(product)) {
                              wishlistProvider.removeItem(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        '${product.name} removed from wishlist!')),
                              );
                            } else {
                              wishlistProvider.addItem(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        '${product.name} added to wishlist!')),
                              );
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                product.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                product.farmShop,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withAlpha((255 * 0.6).round()),
                ),
              ),
              const SizedBox(height: 4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF5CB85C), // Green price
                            ),
                      ),
                      if (product.originalPrice > 0)
                        Text(
                          '₹${product.originalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withAlpha((255 * 0.5).round()),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF5CB85C),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      onPressed: () {
                        // Add to cart functionality using CartProvider
                        cartProvider.addItem(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
