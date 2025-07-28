// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart'
    hide CarouselController; // Hide CarouselController from material.dart
import 'package:kaadu_organics_app/models.dart';
import 'package:carousel_slider/carousel_slider.dart'
    as carousel_slider; // Import with a prefix
import 'package:provider/provider.dart'; // NEW: Import Provider
import 'package:kaadu_organics_app/providers/cart_provider.dart'; // NEW: Import CartProvider
import 'package:kaadu_organics_app/providers/wishlist_provider.dart'; // Import WishlistProvider

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentQuantity = 1;
  int _userRating = 0; // For user's new rating
  final TextEditingController _userReviewController = TextEditingController();

  void _incrementQuantity() {
    setState(() {
      _currentQuantity++;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_currentQuantity > 1) {
        _currentQuantity--;
      }
    });
  }

  void _submitReview(Product product) {
    if (_userRating > 0 && _userReviewController.text.isNotEmpty) {
      // For demonstration, we'll add to the dummy product's reviewsList
      // In a real app, this would involve sending data to a backend
      setState(() {
        product.reviewsList.add(
          Review(
            reviewerName: 'Current User', // Replace with actual user name
            rating: _userRating.toDouble(),
            comment: _userReviewController.text,
            date: DateTime.now()
                .toIso8601String()
                .substring(0, 10), // Simplified date format
          ),
        );
        // Optionally, update the product's overall rating and review count
        // This is a simplified calculation and might need more robust logic
        double totalRating =
            product.reviewsList.fold(0.0, (sum, review) => sum + review.rating);
        // Create a new Product instance with updated rating and reviews
        // This is important because Product is final and its properties cannot be directly modified
        final updatedProduct = Product(
          id: product.id,
          name: product.name,
          imageUrl: product.imageUrl,
          price: product.price,
          originalPrice: product.originalPrice,
          farmShop: product.farmShop,
          rating: totalRating / product.reviewsList.length,
          reviews: product.reviewsList.length,
          description: product.description,
          unit: product.unit,
          category: product.category,
          isAvailable: product.isAvailable,
          reviewsList: product.reviewsList, // Pass the updated list
        );

        // Find the product in dummyProducts and replace it with the updated one
        final index =
            dummyProducts.indexWhere((p) => p.id == updatedProduct.id);
        if (index != -1) {
          dummyProducts[index] = updatedProduct;
        }

        _userRating = 0; // Reset rating
        _userReviewController.clear(); // Clear review text
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your review has been submitted!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and a review.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the product from arguments.
    final product = ModalRoute.of(context)!.settings.arguments as Product;

    // Access the CartProvider
    final cartProvider = Provider.of<CartProvider>(context);
    final wishlistProvider =
        Provider.of<WishlistProvider>(context); // Access WishlistProvider

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          // Wishlist button
          IconButton(
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
                      content: Text('${product.name} removed from wishlist!')),
                );
              } else {
                wishlistProvider.addItem(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.name} added to wishlist!')),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.share_rounded,
                color: Theme.of(context).iconTheme.color),
            onPressed: () {
              // Handle share
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Carousel
            carousel_slider.CarouselSlider(
              options: carousel_slider.CarouselOptions(
                height: 250.0,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                scrollDirection: Axis.horizontal,
              ),
              items: [product.imageUrl, product.imageUrl, product.imageUrl]
                  .map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.network(
                          i,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey[700],
                            child: Icon(Icons.image_not_supported,
                                color: Theme.of(context).iconTheme.color,
                                size: 80),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Text(
                        product.farmShop,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withAlpha((255 * 0.7).round()),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 20),
                      Text(
                        '${product.rating.toStringAsFixed(1)} (${product.reviews} reviews)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withAlpha((255 * 0.7).round()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${product.price.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF5CB85C),
                                ),
                          ),
                          Text(
                            product.unit,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withAlpha((255 * 0.7).round()),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_rounded,
                                  color: Theme.of(context).iconTheme.color),
                              onPressed: _decrementQuantity,
                              visualDensity: VisualDensity.compact,
                            ),
                            Text(
                              '$_currentQuantity',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_rounded,
                                  color: Theme.of(context).iconTheme.color),
                              onPressed: _incrementQuantity,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    'Descriptions',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withAlpha((255 * 0.8).round()),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  // Customer Reviews Section
                  Text(
                    'Customer Reviews (${product.reviewsList.length})',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12.0),
                  if (product.reviewsList.isEmpty)
                    Text(
                      'No reviews yet. Be the first to review this product!',
                      style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withAlpha((255 * 0.7).round())),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: product.reviewsList.length,
                      itemBuilder: (context, index) {
                        final review = product.reviewsList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    review.reviewerName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Row(
                                    children: List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < review.rating
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        color: Colors.amber,
                                        size: 18,
                                      );
                                    }),
                                  ),
                                  const Spacer(),
                                  Text(
                                    review.date,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withAlpha((255 * 0.6).round())),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                review.comment,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withAlpha((255 * 0.8).round())),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 24.0),
                  Text(
                    'Write a Review',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12.0),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _userRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: index < _userRating
                                ? Colors.amber
                                : Theme.of(context)
                                    .iconTheme
                                    .color
                                    ?.withAlpha((255 * 0.5).round()),
                            size: 35,
                          ),
                          onPressed: () {
                            setState(() {
                              _userRating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _userReviewController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts about this product...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _submitReview(product),
                      child: const Text('Submit Review'),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Add to cart logic using CartProvider
                  cartProvider.addItem(product, quantity: _currentQuantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Added $_currentQuantity x ${product.name} to cart!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF5CB85C), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: const Icon(Icons.shopping_cart_rounded,
                    color: Color(0xFF5CB85C)),
                label: const Text(
                  'Add To Cart',
                  style: TextStyle(
                      color: Color(0xFF5CB85C),
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Buy Now logic: Add to cart and then navigate to cart/checkout
                  cartProvider.addItem(product, quantity: _currentQuantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Adding $_currentQuantity x ${product.name} to cart and proceeding to checkout!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  Navigator.pushNamed(
                      context, '/cart'); // Navigate to cart screen
                },
                child: const Text('Buy Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
