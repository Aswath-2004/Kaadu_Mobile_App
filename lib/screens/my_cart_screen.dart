// lib/screens/my_cart_screen.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart';
import 'package:provider/provider.dart';
import 'package:kaadu_organics_app/providers/cart_provider.dart'; // Import CartProvider
import 'package:kaadu_organics_app/services/api_service.dart'; // Import ApiService
import 'package:kaadu_organics_app/screens/checkout_screen.dart'; // NEW: Import CheckoutScreen
import 'package:flutter/foundation.dart'; // For debugPrint

class MyCartScreen extends StatefulWidget {
  const MyCartScreen({super.key});

  @override
  State<MyCartScreen> createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  final ApiService _apiService = ApiService(); // Initialize ApiService

  @override
  void initState() {
    super.initState();
    // Fetch cart items when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCart();
    });
  }

  // Removed _handleCheckout as navigation will now go to CheckoutScreen
  // The order placement logic will reside in CheckoutScreen

  @override
  Widget build(BuildContext context) {
    // Listen to the CartProvider for state changes
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: cartProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : cartProvider.errorMessage != null
                    ? Center(child: Text('Error: ${cartProvider.errorMessage}'))
                    : cartProvider.cartItems.isEmpty
                        ? Center(
                            child: Text(
                              'Your cart is empty!',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color
                                          ?.withAlpha((255 * 0.5).round())),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: cartProvider.cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartProvider.cartItems[index];
                              return CartItemCard(
                                cartItem: item,
                                onQuantityChanged: (newQuantity) {
                                  cartProvider.updateItemQuantity(
                                      item.product, newQuantity);
                                },
                                onRemove: () {
                                  cartProvider.removeItem(item.product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            '${item.product.name} removed from cart!')),
                                  );
                                },
                              );
                            },
                          ),
          ),
          // Cart Summary and Checkout
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withAlpha((255 * 0.1).round()), // Fixed withOpacity
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSummaryRow('Subtotal',
                    '₹${cartProvider.subtotal.toStringAsFixed(2)}', context),
                const SizedBox(height: 8.0),
                _buildSummaryRow('Delivery',
                    '₹${cartProvider.deliveryFee.toStringAsFixed(2)}', context),
                Divider(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withAlpha((255 * 0.3).round()),
                    height: 24),
                _buildSummaryRow(
                  'Total',
                  '₹${cartProvider.total.toStringAsFixed(2)}',
                  context,
                  isTotal: true,
                ),
                const SizedBox(height: 24.0),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Select Voucher logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Voucher selection coming soon!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFF5CB85C), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Select Voucher',
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
                        onPressed: cartProvider.cartItems.isEmpty
                            ? null
                            : () {
                                // Navigate to the new CheckoutScreen
                                Navigator.pushNamed(context, '/checkout');
                              },
                        child: const Text('Checkout'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, BuildContext context,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: isTotal
              ? Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)
              : TextStyle(
                  fontSize: 16,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withAlpha((255 * 0.8).round())),
        ),
        Text(
          value,
          style: isTotal
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: const Color(0xFF5CB85C))
              : TextStyle(
                  fontSize: 16,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withAlpha((255 * 0.8).round())),
        ),
      ],
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove; // New callback for removing item

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove, // Initialize new callback
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                cartItem.product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint(
                      'CartItemCard: Failed to load image for ${cartItem.product.name}: ${cartItem.product.imageUrl}'); // DEBUG PRINT
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[700],
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.white),
                  );
                },
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    cartItem.product.farmShop,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withAlpha((255 * 0.6).round()),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '₹${(cartItem.product.price * cartItem.quantity).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5CB85C),
                        ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF5CB85C),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    onPressed: () => onQuantityChanged(cartItem.quantity + 1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '${cartItem.quantity}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(
                        color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withAlpha((255 * 0.3).round()) ??
                            Colors.white30), // Fixed null-safety
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.remove_rounded,
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                    onPressed: () => onQuantityChanged(cartItem.quantity - 1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                // NEW: Remove button
                IconButton(
                  icon: const Icon(Icons.delete_rounded, color: Colors.red),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
