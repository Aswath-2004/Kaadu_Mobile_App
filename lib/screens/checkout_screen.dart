// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart'; // Import models for Address and PaymentMethod
import 'package:provider/provider.dart';
import 'package:kaadu_organics_app/providers/cart_provider.dart'; // NEW: Import CartProvider
import 'package:kaadu_organics_app/services/api_service.dart'; // For creating WooCommerce order
import 'package:razorpay_flutter/razorpay_flutter.dart'; // NEW: Import Razorpay
import 'package:flutter/foundation.dart'; // For debugPrint

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Address? _selectedAddress;
  PaymentMethod? _selectedPaymentMethod;
  final ApiService _apiService = ApiService();
  late Razorpay _razorpay; // NEW: Razorpay instance

  // Razorpay Test Key ID (Replace with your actual test key)
  static const String _razorpayKeyId =
      'rzp_test_SQtpGxikB1WOqM'; // Replace with your actual Razorpay Test Key ID

  @override
  void initState() {
    super.initState();
    // Initialize with default address and payment method if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedAddress = dummyAddressesNotifier.value.firstWhere(
          (addr) => addr.isDefault,
          orElse: () => dummyAddressesNotifier.value.isNotEmpty
              ? dummyAddressesNotifier.value.first
              : Address(
                  // Fallback if no addresses exist
                  id: 'default',
                  fullName: 'Guest User',
                  phoneNumber: 'N/A',
                  streetAddress1: 'No Address Set',
                  city: '',
                  state: '',
                  postalCode: '',
                  addressType: 'Home',
                ),
        );
        _selectedPaymentMethod = dummyPaymentMethods.firstWhere(
          (method) => method.isDefault,
          orElse: () => dummyPaymentMethods.isNotEmpty
              ? dummyPaymentMethods.first
              : PaymentMethod(
                  id: 'default', type: 'Cash on Delivery'), // Fallback
        );
      });
    });

    // NEW: Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear(); // NEW: Dispose Razorpay instance
    super.dispose();
  }

  // NEW: Razorpay Payment Success Handler
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('Payment Success: ${response.paymentId}');
    // Here, you would typically verify the payment on your server
    // and then create the order in WooCommerce with a 'processing' or 'completed' status.

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Successful! Payment ID: ${response.paymentId}'),
        backgroundColor: Colors.green,
      ),
    );

    // Now, create the order in WooCommerce
    await _createWooCommerceOrder(
        'processing', 'Payment ID: ${response.paymentId}');
  }

  // NEW: Razorpay Payment Error Handler
  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint(
        'Payment Error: Code: ${response.code}, Description: ${response.message}');
    if (!mounted) return;
    String errorMessage =
        'Payment Failed: ${response.message ?? "Unknown error"}';
    // Corrected: Use Razorpay.PAYMENT_CANCELLED for user cancellation
    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      errorMessage = 'Payment cancelled by user.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }

  // NEW: Razorpay External Wallet Handler
  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet Selected: ${response.walletName}'),
      ),
    );
  }

  // NEW: Method to open Razorpay checkout
  void _openCheckout() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final UserAccount currentUser = dummyUserAccountsNotifier.value.firstWhere(
      (account) => account.isActive,
      orElse: () => dummyUserAccountsNotifier.value.first,
    );

    if (cartProvider.subtotal < 250.0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum order value is ₹250.')),
      );
      return;
    }

    if (_selectedAddress == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a shipping address.')),
      );
      return;
    }
    if (_selectedPaymentMethod == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );
      return;
    }

    if (cartProvider.cartItems.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty!')),
      );
      return;
    }

    // Convert total amount from double to int (paise)
    int amountInPaise = (cartProvider.total * 100).round();

    var options = {
      'key': _razorpayKeyId, // Replace with your actual key ID
      'amount': amountInPaise,
      'name': 'Kaadu Organics',
      'description': 'Order from Kaadu Organics App',
      'prefill': {
        'email': currentUser.email,
        'contact': currentUser.phoneNumber,
      },
      'external': {
        'wallets': ['paytm'] // Optional: enable specific external wallets
      },
      'currency': 'INR', // Indian Rupees
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay checkout: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error initiating payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to create WooCommerce order (called after successful payment or for COD)
  Future<void> _createWooCommerceOrder(
      String status, String paymentNote) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final UserAccount currentUser = dummyUserAccountsNotifier.value.firstWhere(
      (account) => account.isActive,
      orElse: () => dummyUserAccountsNotifier.value.first,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Finalizing order with WooCommerce...')),
    );

    try {
      final orderResponse = await _apiService.createWooCommerceOrder(
        cartProvider.cartItems,
        customerEmail: currentUser.email,
        paymentMethod: _selectedPaymentMethod!.type == 'Cash on Delivery'
            ? 'cod'
            : 'razorpay', // Use 'razorpay' for online payments
        paymentMethodTitle: _selectedPaymentMethod!.displayText,
        billingAddress: _selectedAddress,
        shippingAddress: _selectedAddress,
        status: status, // Set the status based on payment outcome
        customerNote: 'Order placed via Flutter mobile app. $paymentNote',
      );

      if (!mounted) return;

      if (orderResponse['id'] != null) {
        await cartProvider
            .clearCart(); // Clear cart on successful order creation
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Order #${orderResponse['id']} placed! Status: ${orderResponse['status']}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.popUntil(
            context, (route) => route.isFirst); // Go back to home
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to finalize order with WooCommerce.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('WooCommerce order creation error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error finalizing order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to handle final order placement (calls Razorpay or direct COD)
  Future<void> _placeOrder() async {
    if (_selectedPaymentMethod?.type == 'Cash on Delivery') {
      await _createWooCommerceOrder('on-hold', 'Payment: Cash on Delivery');
    } else {
      _openCheckout(); // Initiate Razorpay payment
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    // Determine if the "Place Order" button should be enabled
    bool canPlaceOrder = cartProvider.cartItems.isNotEmpty &&
        _selectedAddress != null &&
        _selectedPaymentMethod != null &&
        cartProvider.subtotal >= 250.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shipping Address Section
            _buildSectionTitle('1. Shipping Address'),
            const SizedBox(height: 12.0),
            _selectedAddress == null
                ? _buildEmptySelectionCard(
                    context,
                    'No address selected',
                    Icons.location_on_rounded,
                    'Add/Select Address',
                    () async {
                      final result =
                          await Navigator.pushNamed(context, '/addresses');
                      if (!mounted) return;
                      if (result != null && result is Address) {
                        setState(() {
                          _selectedAddress = result;
                        });
                      }
                    },
                  )
                : AddressSummaryCard(
                    address: _selectedAddress!,
                    onEdit: () async {
                      final result =
                          await Navigator.pushNamed(context, '/addresses');
                      if (!mounted) return;
                      if (result != null && result is Address) {
                        setState(() {
                          _selectedAddress = result;
                        });
                      }
                    },
                  ),
            const SizedBox(height: 24.0),

            // Payment Method Section
            _buildSectionTitle('2. Payment Method'),
            const SizedBox(height: 12.0),
            _selectedPaymentMethod == null
                ? _buildEmptySelectionCard(
                    context,
                    'No payment method selected',
                    Icons.payment_rounded,
                    'Add/Select Payment Method',
                    () async {
                      final result = await Navigator.pushNamed(
                          context, '/payment_methods');
                      if (!mounted) return;
                      if (result != null && result is PaymentMethod) {
                        setState(() {
                          _selectedPaymentMethod = result;
                        });
                      }
                    },
                  )
                : PaymentMethodSummaryCard(
                    paymentMethod: _selectedPaymentMethod!,
                    onEdit: () async {
                      final result = await Navigator.pushNamed(
                          context, '/payment_methods');
                      if (!mounted) return;
                      if (result != null && result is PaymentMethod) {
                        setState(() {
                          _selectedPaymentMethod = result;
                        });
                      }
                    },
                  ),
            const SizedBox(height: 24.0),

            // Order Summary Section
            _buildSectionTitle('3. Order Summary'),
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((255 * 0.1).round()),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Subtotal',
                      '₹${cartProvider.subtotal.toStringAsFixed(2)}', context),
                  const SizedBox(height: 8.0),
                  _buildSummaryRow(
                      'Delivery',
                      '₹${cartProvider.deliveryFee.toStringAsFixed(2)}',
                      context),
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
                ],
              ),
            ),
            const SizedBox(height: 32.0),

            // Minimum Order Value Warning
            if (cartProvider.subtotal < 250.0)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Minimum order value for checkout is ₹250.00',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canPlaceOrder ? _placeOrder : null,
                child: const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildEmptySelectionCard(
    BuildContext context,
    String message,
    IconData icon,
    String buttonText,
    VoidCallback onPressed,
  ) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon,
                size: 40,
                color: Theme.of(context)
                    .iconTheme
                    .color
                    ?.withAlpha((255 * 0.5).round())),
            const SizedBox(height: 8.0),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withAlpha((255 * 0.7).round()),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: onPressed,
              child: Text(buttonText),
            ),
          ],
        ),
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

// Helper widgets for summary cards (can be moved to a separate file later)
class AddressSummaryCard extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;

  const AddressSummaryCard({
    super.key,
    required this.address,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  address.fullName,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: onEdit,
                  child: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              address.streetAddress1,
              style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withAlpha((255 * 0.8).round())),
            ),
            if (address.streetAddress2.isNotEmpty)
              Text(
                address.streetAddress2,
                style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withAlpha((255 * 0.8).round())),
              ),
            Text(
              '${address.city}, ${address.state} - ${address.postalCode}',
              style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withAlpha((255 * 0.8).round())),
            ),
            Text(
              'Phone: ${address.phoneNumber}',
              style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withAlpha((255 * 0.8).round())),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodSummaryCard extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final VoidCallback onEdit;

  const PaymentMethodSummaryCard({
    super.key,
    required this.paymentMethod,
    required this.onEdit,
  });

  IconData _getPaymentIcon(String type) {
    switch (type) {
      case 'Credit Card':
      case 'Debit Card':
        return Icons.credit_card_rounded;
      case 'UPI':
        return Icons.qr_code_rounded;
      case 'Net Banking':
        return Icons.account_balance_rounded;
      case 'Cash on Delivery':
        return Icons.payments_rounded;
      default:
        return Icons.money_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_getPaymentIcon(paymentMethod.type),
                        color: const Color(0xFF5CB85C), size: 28),
                    const SizedBox(width: 12.0),
                    Text(
                      paymentMethod.type,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onEdit,
                  child: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              paymentMethod.displayText,
              style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withAlpha((255 * 0.8).round())),
            ),
          ],
        ),
      ),
    );
  }
}
