// screens/category_products_screen.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart';
import 'package:kaadu_organics_app/providers/product_provider.dart';
import 'package:kaadu_organics_app/screens/home_screen.dart'; // To reuse ProductCard
import 'package:provider/provider.dart';

class CategoryProductsScreen extends StatefulWidget {
  final Category category;
  const CategoryProductsScreen({super.key, required this.category});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch products for the specific category when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false)
          .fetchProductsByCategory(widget.category.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productProvider.errorMessage != null
              ? Center(child: Text('Error: ${productProvider.errorMessage}'))
              : productProvider.categoryProducts.isEmpty
                  ? Center(
                      child: Text(
                        'No products found in ${widget.category.name}.',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withAlpha((255 * 0.5).round())),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio:
                            0.75, // Adjust as needed for card size
                      ),
                      itemCount: productProvider.categoryProducts.length,
                      itemBuilder: (context, index) {
                        final product = productProvider.categoryProducts[index];
                        return ProductCard(product: product);
                      },
                    ),
    );
  }
}
