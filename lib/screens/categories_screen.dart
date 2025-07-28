// categories_screen.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart';
import 'package:kaadu_organics_app/screens/category_products_screen.dart'; // Import the new screen
import 'package:provider/provider.dart';
import 'package:kaadu_organics_app/providers/product_provider.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: productProvider.isLoading // Show loading indicator
          ? const Center(child: CircularProgressIndicator())
          : productProvider.errorMessage != null // Show error message
              ? Center(child: Text('Error: ${productProvider.errorMessage}'))
              : ValueListenableBuilder<List<Category>>(
                  valueListenable:
                      dummyCategoriesNotifier, // Still using dummy for now, but provider fetches
                  builder: (context, dummyCategories, child) {
                    // Use categories from the provider if available, otherwise fallback to dummy
                    final categoriesToDisplay =
                        productProvider.categories.isNotEmpty
                            ? productProvider.categories
                            : dummyCategories;

                    if (categoriesToDisplay.isEmpty) {
                      return Center(
                        child: Text(
                          'No categories found.',
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
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 1.2, // Adjust as needed
                        ),
                        itemCount: categoriesToDisplay.length,
                        itemBuilder: (context, index) {
                          final category = categoriesToDisplay[index];
                          return GestureDetector(
                            onTap: () {
                              // Navigate to products filtered by this category
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryProductsScreen(
                                      category: category),
                                ),
                              );
                            },
                            child: Card(
                              color: Theme.of(context).cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              elevation: 4,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context)
                                          .cardColor, // Use card color or a light background
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
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
                                          child: const Icon(Icons.broken_image,
                                              color: Colors.white, size: 40),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12.0),
                                  Text(
                                    category.name,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
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
                    );
                  },
                ),
    );
  }
}
