// screens/payment_methods_screen.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart'; // Import the PaymentMethod model

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  // Use a local list for now. In a real app, this would come from state management.
  List<PaymentMethod> _userPaymentMethods = List.from(dummyPaymentMethods);

  void _setDefaultPaymentMethod(String methodId) {
    setState(() {
      for (var method in _userPaymentMethods) {
        method.isDefault = (method.id == methodId);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Default payment method updated!')),
    );
  }

  void _deletePaymentMethod(String methodId) {
    setState(() {
      _userPaymentMethods.removeWhere((method) => method.id == methodId);
      // Ensure at least one method is default if any remain and no default is set
      if (_userPaymentMethods.isNotEmpty &&
          !_userPaymentMethods.any((method) => method.isDefault)) {
        _userPaymentMethods.first.isDefault = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment method deleted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
      ),
      body: _userPaymentMethods.isEmpty
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
              itemCount: _userPaymentMethods.length,
              itemBuilder: (context, index) {
                final method = _userPaymentMethods[index];
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
          if (newMethod != null && newMethod is PaymentMethod) {
            setState(() {
              _userPaymentMethods.add(newMethod);
              // If this is the first method, make it default
              if (_userPaymentMethods.length == 1) {
                _userPaymentMethods.first.isDefault = true;
              }
            });
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
                    // In a real app, you'd update your state management or refresh data
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
