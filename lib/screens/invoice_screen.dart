// invoice_screen.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart';

class InvoiceScreen extends StatelessWidget {
  final Order? order; // Made nullable
  const InvoiceScreen({super.key, required this.order}); // Updated constructor

  @override
  Widget build(BuildContext context) {
    // Handle null order case for initial route access or unexpected nulls
    final currentOrder = order ?? dummyOrders.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Invoice',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24.0),
                _buildInvoiceRow('Order ID', currentOrder.orderId, context),
                _buildInvoiceRow('Date', currentOrder.date, context),
                _buildInvoiceRow('Status', currentOrder.status, context,
                    valueColor: currentOrder.status == 'Completed'
                        ? const Color(0xFF5CB85C)
                        : Colors.orange),
                Divider(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withAlpha((255 * 0.3).round()),
                    height: 32),
                Text(
                  'Order Details',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                ...currentOrder.items
                    .map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.product.name}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withAlpha((255 * 0.8).round())),
                                ),
                              ),
                              Text(
                                '₹${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withAlpha((255 * 0.8).round())),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                Divider(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withAlpha((255 * 0.3).round()),
                    height: 32),
                Text(
                  'Buyer Details',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                _buildInvoiceRow(
                    'Name', 'Ash', context), // Changed from Sharon to Ash
                _buildInvoiceRow(
                    'Address',
                    '123, MS flats, Chennai, Tamil Nadu',
                    context), // Updated address
                _buildInvoiceRow('Phone', '+91 77777 77777',
                    context), // Updated phone number
                Divider(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withAlpha((255 * 0.3).round()),
                    height: 32),
                Text(
                  'Payment Summary',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                _buildInvoiceRow('Subtotal Price',
                    '₹${currentOrder.subtotal.toStringAsFixed(2)}', context),
                _buildInvoiceRow('Delivery Charges',
                    '₹${currentOrder.deliveryFee.toStringAsFixed(2)}', context),
                _buildInvoiceRow('Total Price',
                    '₹${currentOrder.total.toStringAsFixed(2)}', context,
                    isTotal: true),
                const SizedBox(height: 24.0),
                Center(
                  child: Text(
                    'Thank you for your purchase!',
                    style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withAlpha((255 * 0.7).round())),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value, BuildContext context,
      {Color? valueColor, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)
                : TextStyle(
                    fontSize: 16,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withAlpha((255 * 0.7).round())),
          ),
          Text(
            value,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: const Color(0xFF5CB85C))
                : TextStyle(
                    fontSize: 16,
                    color: valueColor ??
                        Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ],
      ),
    );
  }
}
