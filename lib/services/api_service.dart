// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:kaadu_organics_app/models.dart'; // Import models for CartItem

class ApiService {
  // IMPORTANT: This should now point to your Vercel proxy URL including '/proxy'
  final String _baseUrl =
      'https://kaadu-app.vercel.app/api/proxy'; // Your Vercel proxy base URL

  // Replace with your actual WooCommerce Consumer Key and Secret
  // These keys will be sent to your Vercel proxy, which will then use them
  // to authenticate with your WooCommerce backend.
  final String _consumerKey =
      'ck_dd8d6bcd7e5c426609d192e8f9088b0cb55b1db4'; // <-- REPLACE THIS
  final String _consumerSecret =
      'cs_5f2739e4fa312f94e38dd0983da45ce4cd3c2aa1'; // <-- REPLACE THIS

  // Helper method to get authentication headers
  Map<String, String> _getAuthHeaders() {
    // Encode Consumer Key and Secret for Basic Authentication
    // This basic auth string will be sent to your Vercel proxy
    // Your Vercel proxy's 'api/index.js' should then decode this
    // and use the keys to authenticate with the actual WooCommerce API.
    String basicAuth =
        base64Encode(utf8.encode('$_consumerKey:$_consumerSecret'));
    return {
      'Authorization': 'Basic $basicAuth',
      'Content-Type': 'application/json',
    };
  }

  // Generic GET request method
  Future<List<dynamic>> _get(String endpoint,
      {Map<String, String>? queryParameters}) async {
    Uri url = Uri.parse('$_baseUrl/$endpoint');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      url = url.replace(queryParameters: queryParameters);
    }

    try {
      final response = await http.get(url, headers: _getAuthHeaders());

      if (response.statusCode == 200) {
        debugPrint(
            'Response for $endpoint: ${response.body}'); // Use debugPrint for Flutter
        return json.decode(response.body);
      } else {
        debugPrint('Error for $endpoint: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        // Provide a more specific error message if possible
        throw Exception(
            'Failed to load data from $endpoint: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception fetching $endpoint: $e');
      throw Exception('Failed to connect to API for $endpoint: $e');
    }
  }

  // Fetch all products, with optional category filtering
  Future<List<dynamic>> getProducts({String? categoryId}) async {
    Map<String, String> queryParams = {};
    if (categoryId != null && categoryId.isNotEmpty) {
      // WooCommerce API uses 'category' parameter for filtering by category ID
      queryParams['category'] = categoryId;
    }
    return await _get('products', queryParameters: queryParams);
  }

  // Fetch product categories
  Future<List<dynamic>> getCategories() async {
    return await _get(
        'products/categories'); // This will now hit /api/proxy/products/categories on Vercel
  }

  // NEW: Method to create a WooCommerce order
  Future<Map<String, dynamic>> createWooCommerceOrder(
    List<CartItem> cartItems, {
    required String customerEmail,
    required String paymentMethod,
    required String paymentMethodTitle,
    bool setPaid = false,
    Address? billingAddress,
    Address? shippingAddress,
    String? status, // NEW: Added status parameter
    String? customerNote, // NEW: Added customerNote parameter
  }) async {
    final url =
        Uri.parse('$_baseUrl/orders'); // Endpoint for WooCommerce orders

    // Prepare line items from cart items
    List<Map<String, dynamic>> lineItems = cartItems.map((item) {
      return {
        'product_id':
            int.parse(item.product.id), // WooCommerce expects int product_id
        'quantity': item.quantity,
      };
    }).toList();

    // Prepare billing and shipping addresses
    Map<String, dynamic>? billing = billingAddress != null
        ? {
            'first_name': billingAddress.fullName.split(' ').first,
            'last_name': billingAddress.fullName.split(' ').length > 1
                ? billingAddress.fullName.split(' ').last
                : '',
            'address_1': billingAddress.streetAddress1,
            'address_2': billingAddress.streetAddress2,
            'city': billingAddress.city,
            'state': billingAddress.state,
            'postcode': billingAddress.postalCode,
            'country': 'IN', // Assuming India for now, can be dynamic
            'email': customerEmail,
            'phone': billingAddress.phoneNumber,
          }
        : null;

    Map<String, dynamic>? shipping = shippingAddress != null
        ? {
            'first_name': shippingAddress.fullName.split(' ').first,
            'last_name': shippingAddress.fullName.split(' ').length > 1
                ? shippingAddress.fullName.split(' ').last
                : '',
            'address_1': shippingAddress.streetAddress1,
            'address_2': shippingAddress.streetAddress2,
            'city': shippingAddress.city,
            'state': shippingAddress.state,
            'postcode': shippingAddress.postalCode,
            'country': 'IN', // Assuming India for now, can be dynamic
          }
        : null;

    // Construct the order payload
    Map<String, dynamic> orderPayload = {
      'payment_method': paymentMethod,
      'payment_method_title': paymentMethodTitle,
      'set_paid': setPaid,
      'billing': billing,
      'shipping': shipping,
      'line_items': lineItems,
      // Conditionally add status and customer_note if provided
      if (status != null) 'status': status,
      if (customerNote != null) 'customer_note': customerNote,
    };

    try {
      final response = await http.post(
        url,
        headers: _getAuthHeaders(),
        body: json.encode(orderPayload),
      );

      if (response.statusCode == 201) {
        // 201 Created
        debugPrint('WooCommerce Order created successfully: ${response.body}');
        return json.decode(response.body);
      } else {
        debugPrint(
            'Failed to create WooCommerce order: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception(
            'Failed to create WooCommerce order: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception creating WooCommerce order: $e');
      throw Exception('Failed to connect to API for order creation: $e');
    }
  }
}
