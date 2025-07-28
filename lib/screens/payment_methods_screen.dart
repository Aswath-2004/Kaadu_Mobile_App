// screens/payment_methods_screen.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart'; // Import the PaymentMethod model
import 'package:provider/provider.dart'; // NEW: Import Provider
import 'package:kaadu_organics_app/providers/payment_method_provider.dart'; // NEW: Import PaymentMethodProvider

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentMethodProvider>(context, listen: false)
          .fetchPaymentMethods();
    });
  }

  void _setDefaultPaymentMethod(String methodId) {
    final paymentMethodProvider =
        Provider.of<PaymentMethodProvider>(context, listen: false);
    final methodToSetDefault = paymentMethodProvider.paymentMethods
        .firstWhere((method) => method.id == methodId);
    paymentMethodProvider
        .updatePaymentMethod(methodToSetDefault.copyWith(isDefault: true));
    if (!mounted) return; // Guard against context use after async operation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Default payment method updated!')),
    );
  }

  void _deletePaymentMethod(String methodId) {
    final paymentMethodProvider =
        Provider.of<PaymentMethodProvider>(context, listen: false);
    paymentMethodProvider.deletePaymentMethod(methodId);
    if (!mounted) return; // Guard against context use after async operation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment method deleted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethodProvider = Provider.of<PaymentMethodProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
      ),
      body: paymentMethodProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : paymentMethodProvider.errorMessage != null
              ? Center(
                  child: Text('Error: ${paymentMethodProvider.errorMessage}'))
              : paymentMethodProvider.paymentMethods.isEmpty
                  ? Center(
                      child: Text(
                        'No payment methods saved. Add one!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withAlpha((255 * 0.5).round())),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: paymentMethodProvider.paymentMethods.length,
                      itemBuilder: (context, index) {
                        final method =
                            paymentMethodProvider.paymentMethods[index];
                        return PaymentMethodCard(
                          paymentMethod: method,
                          onSetDefault: _setDefaultPaymentMethod,
                          onDelete: _deletePaymentMethod,
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newMethod =
              await Navigator.pushNamed(context, '/add_edit_payment_method');
          if (!mounted) return; // Check if the widget is still mounted
          if (newMethod != null && newMethod is PaymentMethod) {
            // PaymentMethodProvider.addPaymentMethod is already called in add_edit_payment_method_screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Payment method added successfully!')),
            );
          }
        },
        label: const Text('Add New Method'),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: const Color(0xFF5CB85C),
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final Function(String) onSetDefault;
  final Function(String) onDelete;

  const PaymentMethodCard({
    super.key,
    required this.paymentMethod,
    required this.onSetDefault,
    required this.onDelete,
  });

  IconData _getPaymentIcon(String type) {
    switch (type) {
      case 'Credit Card':
        return Icons.credit_card_rounded;
      case 'Debit Card':
        return Icons.credit_card_rounded;
      case 'UPI':
        return Icons.qr_code_rounded; // Or a custom UPI icon if available
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
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                if (paymentMethod.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5CB85C),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => onSetDefault(paymentMethod.id),
                    child: const Text('Set as Default'),
                  ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              paymentMethod.displayText,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withAlpha((255 * 0.8).round()),
              ),
            ),
            if (paymentMethod.type == 'Credit Card' ||
                paymentMethod.type == 'Debit Card') ...[
              const SizedBox(height: 4.0),
              Text(
                'Card Holder: ${paymentMethod.cardHolderName}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withAlpha((255 * 0.7).round()),
                ),
              ),
              Text(
                'Expires: ${paymentMethod.expiryDate}',
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
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    // Navigate to edit screen with the current payment method
                    final updatedMethod = await Navigator.pushNamed(
                      context,
                      '/add_edit_payment_method',
                      arguments: paymentMethod,
                    );
                    if (!context.mounted)
                      return; // Check if the widget is still mounted
                    if (updatedMethod != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Payment method updated successfully!')),
                      );
                    }
                  },
                  child: const Text('Edit'),
                ),
                TextButton(
                  onPressed: () => onDelete(paymentMethod.id),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
