// rate_now_screen.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart';

class RateNowScreen extends StatefulWidget {
  final Order? order; // Made nullable for route initialization
  const RateNowScreen({super.key, this.order}); // Made order optional

  @override
  State<RateNowScreen> createState() => _RateNowScreenState();
}

class _RateNowScreenState extends State<RateNowScreen> {
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Use dummy order if not provided for route testing or if accessed directly
    final order = widget.order ?? dummyOrders.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Now'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Rate this order',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8.0),
            Center(
              child: Text(
                'Share your experience on the comment field below',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withAlpha((255 * 0.7).round())),
              ),
            ),
            const SizedBox(height: 24.0),
            Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            order.items.first.product
                                .imageUrl, // Show first item's image
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[700],
                              child: Icon(Icons.image_not_supported,
                                  color: Theme.of(context).iconTheme.color,
                                  size: 40),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.items.first.product.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                order.items.first.product.farmShop,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withAlpha((255 * 0.7).round())),
                              ),
                              Text(
                                '₹${order.items.first.product.price.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(color: const Color(0xFF5CB85C)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withAlpha((255 * 0.3).round()),
                        height: 24),
                    Text(
                      'The delivery process is fast, and all the products are very fresh. Thank you Farmer Shop',
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withAlpha((255 * 0.8).round())),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _selectedRating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: index < _selectedRating
                          ? Colors.amber
                          : Theme.of(context)
                              .iconTheme
                              .color
                              ?.withAlpha((255 * 0.5).round()),
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedRating = index + 1;
                      });
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Add Image',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                    color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withAlpha((255 * 0.3).round()) ??
                        Colors.white54),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_a_photo_rounded,
                      color: Theme.of(context)
                          .iconTheme
                          .color
                          ?.withAlpha((255 * 0.5).round())),
                  const SizedBox(width: 12.0),
                  Text(
                    'Select Folder',
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withAlpha((255 * 0.5).round())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Your Review',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your review here...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            const SizedBox(height: 32.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Submit review logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Review submitted with $_selectedRating stars!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context); // Go back after submission
                },
                child: const Text(
                    'Pay Now'), // The image shows "Pay Now" here, assuming it means "Submit Review"
              ),
            ),
          ],
        ),
      ),
    );
  }
}
