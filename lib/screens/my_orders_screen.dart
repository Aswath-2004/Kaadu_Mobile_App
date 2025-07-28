// my_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart'; // For Order and CartItem models
import 'package:kaadu_organics_app/screens/invoice_screen.dart'; // Added import
import 'package:kaadu_organics_app/screens/rate_now_screen.dart'; // Added import

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dummy order data
  final List<Order> _allOrders = [
    Order(
      orderId: '20231026-001',
      date: '26 Oct 2023',
      status: 'Completed',
      items: [
        CartItem(product: dummyProducts[0], quantity: 1),
        CartItem(product: dummyProducts[1], quantity: 1),
      ],
      subtotal: 247.00,
      deliveryFee: 5.00,
      total: 252.00,
    ),
    Order(
      orderId: '20231101-002',
      date: '01 Nov 2023',
      status: 'On Delivery',
      items: [
        CartItem(product: dummyProducts[3], quantity: 1),
      ],
      subtotal: 425.00,
      deliveryFee: 5.00,
      total: 430.00,
    ),
    Order(
      orderId: '20231105-003',
      date: '05 Nov 2023',
      status: 'Confirmed',
      items: [
        CartItem(product: dummyProducts[4], quantity: 2),
        CartItem(product: dummyProducts[5], quantity: 1),
      ],
      subtotal: 604.00,
      deliveryFee: 5.00,
      total: 609.00,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Order> _getOrdersByStatus(String status) {
    if (status == 'All') {
      return _allOrders;
    }
    return _allOrders.where((order) => order.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          // Assign _tabController to TabBar
          controller: _tabController,
          indicatorColor: const Color(0xFF5CB85C),
          labelColor: const Color(0xFF5CB85C),
          unselectedLabelColor: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.color
              ?.withAlpha((255 * 0.7).round()),
          tabs: const [
            Tab(text: 'Confirmed'),
            Tab(text: 'On Delivery'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(_getOrdersByStatus('Confirmed')),
          _buildOrderList(_getOrdersByStatus('On Delivery')),
          _buildOrderList(_getOrdersByStatus('Completed')),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'No orders in this category.',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.color
                  ?.withAlpha((255 * 0.5).round())),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(order: order);
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  const OrderCard({super.key, required this.order});

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
                Text(
                  'Order ID: ${order.orderId}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  order.date,
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withAlpha((255 * 0.7).round())),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'Status: ${order.status}',
              style: TextStyle(
                fontSize: 16,
                color: order.status == 'Completed'
                    ? const Color(0xFF5CB85C)
                    : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            Divider(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withAlpha((255 * 0.3).round()),
                height: 24),
            ...order.items
                .map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              item.product.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[700],
                                child: Icon(Icons.image_not_supported,
                                    color: Theme.of(context).iconTheme.color,
                                    size: 25),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: Theme.of(context).textTheme.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${item.quantity} x ₹${item.product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withAlpha((255 * 0.6).round())),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${(item.product.price * item.quantity).toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
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
                height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${order.total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5CB85C),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // View Invoice
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvoiceScreen(order: order),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withAlpha((255 * 0.3).round()) ??
                              Colors.white30,
                          width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'View Invoice',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 14),
                    ),
                  ),
                ),
                if (order.status == 'Completed') ...[
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Rate Now
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RateNowScreen(order: order),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5CB85C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Rate Now',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
