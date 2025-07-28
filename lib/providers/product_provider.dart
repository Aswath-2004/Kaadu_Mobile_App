// lib/providers/product_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kaadu_organics_app/models.dart';
import 'package:kaadu_organics_app/services/api_service.dart'; // Import ApiService
import 'package:flutter/foundation.dart'
    hide Category; // FIX: Hide Flutter's Category

class ProductProvider with ChangeNotifier {
  final ApiService _apiService =
      ApiService(); // Create an instance of ApiService

  List<Product> _products = [];
  List<Category> _categories = [];
  List<Product> _categoryProducts = []; // New list for products by category
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  List<Product> get categoryProducts =>
      _categoryProducts; // Getter for category products
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProductProvider() {
    fetchProducts();
    fetchCategories();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Use ApiService to fetch products
      List<dynamic> productJson = await _apiService.getProducts();
      _products = productJson.map((json) => Product.fromJson(json)).toList();
      debugPrint('Fetched Products: ${_products.length} items'); // Debug print
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error fetching products: $e';
      _isLoading = false;
      debugPrint('Product fetch error: $_errorMessage'); // Debug print
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Use ApiService to fetch categories with per_page parameter
      List<dynamic> categoryJson = await _apiService.getCategories();
      _categories =
          categoryJson.map((json) => Category.fromJson(json)).toList();
      debugPrint(
          'Fetched Categories: ${_categories.length} items'); // Debug print
      // You can add a loop here to print each category's name and image URL for debugging
      for (var cat in _categories) {
        debugPrint(
            'Category: ${cat.name}, ID: ${cat.id}, Image: ${cat.imageUrl}');
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error fetching categories: $e';
      _isLoading = false;
      debugPrint('Category fetch error: $_errorMessage'); // Debug print
      notifyListeners();
    }
  }

  // New method to fetch products by category ID
  Future<void> fetchProductsByCategory(String categoryId) async {
    _isLoading = true;
    _errorMessage = null;
    _categoryProducts = []; // Clear previous category products
    notifyListeners();

    try {
      // Use ApiService to fetch products by category
      List<dynamic> productJson =
          await _apiService.getProducts(categoryId: categoryId);
      _categoryProducts =
          productJson.map((json) => Product.fromJson(json)).toList();
      debugPrint(
          'Fetched Products for Category $categoryId: ${_categoryProducts.length} items'); // Debug print
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error fetching products for category $categoryId: $e';
      _isLoading = false;
      debugPrint(
          'Category products fetch error: $_errorMessage'); // Debug print
      notifyListeners();
    }
  }
}
