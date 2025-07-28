// lib/models.dart
import 'package:flutter/material.dart'; // Required for ValueNotifier

class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double originalPrice; // For sale items
  final String farmShop;
  final double rating;
  final int reviews;
  final String description;
  final String unit; // e.g., "1 kg", "500 gm"
  final String category;
  final bool isAvailable; // New: To indicate if a product is in stock
  List<Review> reviewsList; // New: List of reviews for the product

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.originalPrice = 0.0,
    required this.farmShop,
    this.rating = 0.0,
    this.reviews = 0,
    required this.description,
    required this.unit,
    required this.category,
    this.isAvailable = true, // Default to true (in stock)
    List<Review>? reviewsList, // Initialize with empty list if null
  }) : this.reviewsList = reviewsList ?? [];

  // Add a factory constructor to parse from API JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? 'N/A',
      imageUrl: json['images'] != null && json['images'].isNotEmpty
          ? json['images'][0]['src'] // Take the first image URL
          : 'https://placehold.co/600x400?text=No+Image',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      originalPrice: double.tryParse(json['regular_price'].toString()) ?? 0.0,
      farmShop: 'Kaadu Organics Store', // Default or fetch from product meta
      rating: double.tryParse(json['average_rating'].toString()) ?? 0.0,
      reviews: json['rating_count'] ?? 0,
      description: json['description'] ?? 'No description available.',
      unit:
          'N/A', // You'll need to map this from product attributes if available
      category: json['categories'] != null && json['categories'].isNotEmpty
          ? json['categories'][0]['name'] // Take the first category name
          : 'Uncategorized',
      isAvailable: json['stock_status'] == 'instock',
      reviewsList: [], // Initialize empty, fetch separately if needed
    );
  }

  // NEW: toJson method for Product model
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'originalPrice': originalPrice,
      'farmShop': farmShop,
      'rating': rating,
      'reviews': reviews,
      'description': description,
      'unit': unit,
      'category': category,
      'isAvailable': isAvailable,
      // reviewsList is typically not stored with the product in cart for simplicity,
      // but if needed, you'd add: 'reviewsList': reviewsList.map((r) => r.toJson()).toList(),
    };
  }
}

class Category {
  final String id;
  final String name;
  final String imageUrl; // Changed from IconData icon and Color color

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  // Updated factory constructor to parse from API JSON, safely handling 'image' field
  factory Category.fromJson(Map<String, dynamic> json) {
    // Safely get the image URL. The 'image' field can be null or have 'src' as false.
    String imageUrl =
        'https://placehold.co/600x400?text=No+Category+Image'; // Default placeholder
    if (json['image'] != null &&
        json['image']['src'] is String &&
        json['image']['src'].isNotEmpty) {
      imageUrl = json['image']['src'];
    }

    return Category(
      id: json['id'].toString(), // Categories also have an ID
      name: json['name'] ?? 'N/A',
      imageUrl: imageUrl,
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class Order {
  final String orderId;
  final String date;
  final String status; // e.g., 'Confirmed', 'On Delivery', 'Completed'
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;

  Order({
    required this.orderId,
    required this.date,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });
}

// New Address Model
class Address {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String streetAddress1;
  final String streetAddress2;
  final String city;
  final String state;
  final String postalCode;
  final String addressType; // e.g., 'Home', 'Work', 'Other'
  bool isDefault;

  Address({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.streetAddress1,
    this.streetAddress2 = '',
    required this.city,
    required this.state,
    required this.postalCode,
    this.addressType = 'Home',
    this.isDefault = false,
  });

  // Helper to get a formatted address string
  String get formattedAddress {
    String address = '$fullName\n$streetAddress1';
    if (streetAddress2.isNotEmpty) {
      address += '\n$streetAddress2';
    }
    address += '\n$city, $state $postalCode\nPhone: $phoneNumber';
    return address;
  }
}

// New Review Model
class Review {
  final String reviewerName;
  final double rating;
  final String comment;
  final String date;

  Review({
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

// New Notification Model
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type; // e.g., 'offer', 'delivery', 'general'
  final String timestamp;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}

// New PaymentMethod Model
class PaymentMethod {
  final String id;
  final String
      type; // e.g., 'Credit Card', 'Debit Card', 'UPI', 'Net Banking', 'Cash on Delivery'
  final String lastFourDigits; // For cards
  final String bankName; // For Net Banking
  final String
      upiId; // For UPI (changed from यूपीआईId to upiId for consistency)
  final String expiryDate; // For cards (MM/YY)
  final String cardHolderName; // For cards
  bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    this.lastFourDigits = '',
    this.bankName = '',
    this.upiId = '',
    this.expiryDate = '',
    this.cardHolderName = '',
    this.isDefault = false,
  });

  String get displayText {
    if (type == 'Credit Card' || type == 'Debit Card') {
      return '$type ending in $lastFourDigits';
    } else if (type == 'UPI') {
      return 'UPI: $upiId';
    } else if (type == 'Net Banking') {
      return 'Net Banking ($bankName)';
    } else if (type == 'Cash on Delivery') {
      return 'Cash on Delivery';
    }
    return type;
  }
}

// New BankDetails Model
class BankDetails {
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String accountHolderName;

  BankDetails({
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.accountHolderName,
  });
}

// Updated User Account Model
class UserAccount {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String profileImageUrl; // New: For profile picture
  bool isActive; // New: To indicate if this is the currently active account

  // Seller-specific fields
  final bool isSeller;
  final bool isSellerProfileComplete;
  final String? storeName;
  final String? sellerAddress1;
  final String? sellerAddress2;
  final String? sellerCity;
  final String? sellerState;
  final String? sellerPostalCode;
  final BankDetails? bankDetails; // New: Bank details for sellers

  UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl =
        'https://placehold.co/140x140/34A853/FFFFFF?text=A', // Default image
    this.isActive = false,
    // Initialize seller fields
    this.isSeller = false,
    this.isSellerProfileComplete = false,
    this.storeName,
    this.sellerAddress1,
    this.sellerAddress2,
    this.sellerCity,
    this.sellerState,
    this.sellerPostalCode,
    this.bankDetails,
  });

  // Added a copyWith method for easier updating of immutable UserAccount objects
  UserAccount copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isActive,
    bool? isSeller,
    bool? isSellerProfileComplete,
    String? storeName,
    String? sellerAddress1,
    String? sellerAddress2,
    String? sellerCity,
    String? sellerState,
    String? sellerPostalCode,
    BankDetails? bankDetails,
  }) {
    return UserAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      isSeller: isSeller ?? this.isSeller,
      isSellerProfileComplete:
          isSellerProfileComplete ?? this.isSellerProfileComplete,
      storeName: storeName ?? this.storeName,
      sellerAddress1: sellerAddress1 ?? this.sellerAddress1,
      sellerAddress2: sellerAddress2 ?? this.sellerAddress2,
      sellerCity: sellerCity ?? this.sellerCity,
      sellerState: sellerState ?? this.sellerState,
      sellerPostalCode: sellerPostalCode ?? this.sellerPostalCode,
      bankDetails: bankDetails ?? this.bankDetails,
    );
  }
}

// Dummy Data (for demonstration)
List<Product> dummyProducts = [
  Product(
    id: 'p1',
    name: 'Attur Kichili Samba Rice',
    imageUrl:
        'https://kaaduorganics.com/wp-content/uploads/2024/04/KaaduOrganics-Attur-kichili-samba-600x600.avif', // Updated URL
    price: 149.00,
    originalPrice: 160.00,
    farmShop: 'Kaadu Organics',
    rating: 4.5,
    reviews: 120,
    description:
        'Traditional organic rice, known for its unique aroma and taste. Perfect for daily consumption.',
    unit: '1 kg',
    category: 'Rice',
    isAvailable: true,
    reviewsList: [
      Review(
          reviewerName: 'Kiruba',
          rating: 5.0,
          comment: 'Excellent rice, great flavor!',
          date: '2023-01-15'),
      Review(
          reviewerName: 'Joey',
          rating: 4.0,
          comment: 'Good quality, but a bit pricey.',
          date: '2023-02-01'),
    ],
  ),
  Product(
    id: 'p2',
    name: 'Barnyard Millet',
    imageUrl:
        'https://kaaduorganics.com/wp-content/uploads/2024/04/Kaadu-Organics_Barnyard-Millet.webp', // Updated URL
    price: 98.00,
    farmShop: 'Kaadu Organics',
    rating: 4.2,
    reviews: 85,
    description:
        'Healthy and nutritious millet, great for a balanced diet. Rich in fiber and essential nutrients.',
    unit: '500 gm',
    category: 'Millets',
    isAvailable: true,
    reviewsList: [
      Review(
          reviewerName: 'Rachel',
          rating: 4.5,
          comment: 'Very healthy and easy to cook.',
          date: '2023-03-10'),
    ],
  ),
  Product(
    id: 'p3',
    name: 'Black Turmeric Powder',
    imageUrl:
        'https://kaaduorganics.com/wp-content/uploads/2025/01/KaaduOrganics_Blackturmeric-Powderimage.webp', // Updated URL
    price: 249.00,
    farmShop: 'Kaadu Organics',
    rating: 4.8,
    reviews: 50,
    description:
        'Rare and potent black turmeric powder, known for its medicinal properties. A must-have in your pantry.',
    unit: '100 gm',
    category: 'Spices',
    isAvailable: false, // Example of out of stock
    reviewsList: [
      Review(
          reviewerName: 'Nani',
          rating: 5.0,
          comment: 'Amazing product, highly recommend!',
          date: '2023-04-20'),
    ],
  ),
  Product(
    id: 'p4',
    name: 'Wood Pressed Groundnut Oil',
    imageUrl:
        'https://kaaduorganics.com/wp-content/uploads/2024/04/KaaduOrganics_woodpressedgroundnutoil.webp', // Updated URL
    price: 425.00,
    farmShop: 'Kaadu Organics',
    rating: 4.7,
    reviews: 95,
    description:
        'Pure and natural groundnut oil, extracted using traditional wood-pressed methods. Ideal for healthy cooking.',
    unit: '1 Litre',
    category: 'Oil / Honey',
    isAvailable: true,
    reviewsList: [
      Review(
          reviewerName: 'Robert Downey',
          rating: 4.5,
          comment: 'Great oil for cooking, very authentic.',
          date: '2023-05-05'),
      Review(
          reviewerName: 'Lewis',
          rating: 4.0,
          comment: 'Good quality, but the bottle was a bit leaky.',
          date: '2023-05-10'),
    ],
  ),
  Product(
    id: 'p5',
    name: 'Palm Jaggery / Karuppatti',
    imageUrl:
        'https://kaaduorganics.com/wp-content/uploads/2024/04/Kaadu-Organics_Palm-Jaggery.webp', // Updated URL
    price: 270.00,
    farmShop: 'Kaadu Organics',
    rating: 4.6,
    reviews: 70,
    description:
        'Natural sweetener made from palm sap. A healthier alternative to refined sugar with rich flavor.',
    unit: '500 gm',
    category: 'Jaggery',
    isAvailable: true,
    reviewsList: [
      Review(
          reviewerName: 'Danny Ric',
          rating: 5.0,
          comment: 'Love this jaggery! Perfect for my coffee.',
          date: '2023-06-01'),
    ],
  ),
  Product(
    id: 'p6',
    name: 'Urad Dal Papad',
    imageUrl:
        'https://kaaduorganics.com/wp-content/uploads/2024/04/Kaadu-Organics_Urad-Dal-Papad.png', // Updated URL
    price: 64.00,
    farmShop: 'Kaadu Organics',
    rating: 4.0,
    reviews: 30,
    description:
        'Crispy and delicious urad dal papad, perfect as a side dish or snack. Made with authentic ingredients.',
    unit: '100 gm',
    category: 'Snacks',
    isAvailable: true,
    reviewsList: [
      Review(
          reviewerName: 'Kiruba',
          rating: 4.0,
          comment: 'Crispy and tasty, good snack.',
          date: '2023-07-01'),
    ],
  ),
  Product(
    id: 'p7',
    name: 'Organic Honey',
    imageUrl:
        'https://kaaduorganics.com/wp-content/uploads/2024/04/Kaadu-Organics_honey-1.webp',
    price: 450.00,
    farmShop: 'Kaadu Organics',
    rating: 4.9,
    reviews: 150,
    description:
        'Pure organic honey, sourced from natural beehives. A natural and healthy sweetener.',
    unit: '250 gm',
    category: 'Oil / Honey',
    isAvailable: true,
    reviewsList: [
      Review(
          reviewerName: 'Joey',
          rating: 5.0,
          comment: 'The best honey I have ever tasted!',
          date: '2023-08-01'),
      Review(
          reviewerName: 'Rachel',
          rating: 4.8,
          comment: 'Very pure and natural. Great for health.',
          date: '2023-08-05'),
    ],
  ),
  Product(
    id: 'p8',
    name: 'Red Rice',
    imageUrl:
        'https://kaaduorganics.com/wp-content/uploads/2025/01/KaaduOrganics_RawRedRice.avif',
    price: 150.00,
    farmShop: 'Kaadu Organics',
    rating: 4.3,
    reviews: 60,
    description:
        'Nutrient-rich red rice, ideal for a healthy diet. Great source of fiber.',
    unit: '1 kg',
    category: 'Rice',
    isAvailable: true,
    reviewsList: [
      Review(
          reviewerName: 'Nani',
          rating: 4.0,
          comment: 'Healthy alternative, cooks well.',
          date: '2023-09-01'),
    ],
  ),
  Product(
    id: 'p9',
    name: 'Foxtail Millet',
    imageUrl:
        'https://kaaduorganics.com/wp-content/uploads/2024/04/Kaadu-Organics_Foxtail.webp',
    price: 110.0,
    farmShop: 'Kaadu Organics',
    rating: 4.0,
    reviews: 45,
    description: 'Another healthy millet option, versatile for various dishes.',
    unit: '500 gm',
    category: 'Millets',
    isAvailable: false, // Another example of out of stock
    reviewsList: [
      Review(
          reviewerName: 'Robert Downey',
          rating: 3.5,
          comment: 'Good, but takes a while to cook.',
          date: '2023-10-01'),
    ],
  ),
];

ValueNotifier<List<Category>> dummyCategoriesNotifier = ValueNotifier([
  Category(
      id: 'c1',
      name: 'Rice',
      imageUrl:
          'https://kaaduorganics.com/wp-content/uploads/2024/04/Kaadu-Organics_Whiteponnirice.webp'), // Rice
  Category(
      id: 'c2',
      name: 'Jaggery',
      imageUrl:
          'https://kaaduorganics.com/wp-content/uploads/2024/11/Kaadu-organics-palm-sugar.webp'), // Jaggery
  Category(
      id: 'c3',
      name: 'Cereals & Grains',
      imageUrl:
          'https://kaaduorganics.com/wp-content/uploads/2024/11/kaadu-organics-wheat-600x600.webp'), // Cereals & Grains (using rice for now)
  Category(
      id: 'c4',
      name: 'Spices',
      imageUrl:
          'https://kaaduorganics.com/wp-content/uploads/2024/04/KaaduOrganics_RedChillyPowder-600x600.webp'), // Spices
  Category(
      id: 'c5',
      name: 'Millets',
      imageUrl:
          'https://kaaduorganics.com/wp-content/uploads/2024/04/Kaadu-Organics_White-Jowar-600x600.webp'), // Millets
  Category(
      id: 'c6',
      name: 'Oil / Honey',
      imageUrl:
          'https://kaaduorganics.com/wp-content/uploads/2024/04/Kaadu-Organics_Sesame-Oil-600x600.webp'), // Oil / Honey (using honey for now)
  Category(
      id: 'c7',
      name: 'Fruits / Veg',
      imageUrl:
          'https://www.lalpathlabs.com/blog/wp-content/uploads/2019/01/Fruits-and-Vegetables.jpg'), // Fruits / Veg
  Category(
      id: 'c8',
      name: 'Snacks',
      imageUrl:
          'https://kaaduorganics.com/wp-content/uploads/2024/04/Kaadu-Organics_Urad-Dal-Papad-600x600.png'), // Snacks
  Category(
      id: 'c9',
      name: 'Coffee',
      imageUrl:
          'https://kaaduorganics.com/wp-content/uploads/2024/04/KaaduOrganics_ArabicaCoffeBeans.webp'), // Coffee
  Category(
      id: 'c10',
      name: 'Ready to Cook',
      imageUrl:
          'https://kaaduorganics.com/wp-content/uploads/2024/04/Kaadu-Organics_Mappilai-Samba-Rice-Flakes-600x600.webp'), // Ready to Cook
  Category(
      id: 'c11',
      name: 'Offers',
      imageUrl:
          'https://toppng.com/uploads/preview/hosting-special-offer-special-offer-11563533074prltuaav99.png'), // Offers (using jaggery for now)
  Category(
      id: 'c12',
      name: 'Seeds',
      imageUrl:
          'https://kaaduorganics.com/wp-content/uploads/2025/06/KaaduOrganics_Mixedseeds-600x600.avif'), // Seeds (using jaggery for now)
]);

// Added dummyOrders for demonstration purposes
List<Order> dummyOrders = [
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

// Dummy Addresses
ValueNotifier<List<Address>> dummyAddressesNotifier = ValueNotifier([
  Address(
    id: 'a1',
    fullName: 'Home', // Changed from Ash
    phoneNumber: '+91 77777 77777',
    streetAddress1: '123, MS flats',
    city: 'Chennai',
    state: 'Tamil Nadu',
    postalCode: '600001',
    addressType: 'Home',
    isDefault: true,
  ),
  Address(
    id: 'a2',
    fullName: 'Work', // Changed from Ash Work
    phoneNumber: '+91 88888 88888',
    streetAddress1: '456, Office Park',
    city: 'Chennai',
    state: 'Tamil Nadu',
    postalCode: '600002',
    addressType: 'Work',
    isDefault: false,
  ),
]);

// Global ValueNotifier for wishlist
ValueNotifier<List<Product>> wishlistNotifier =
    ValueNotifier<List<Product>>([]);

// Dummy Notifications
List<NotificationItem> dummyNotifications = [
  NotificationItem(
    id: 'n1',
    title: '🎉 Mega Sale Alert!',
    message:
        'Get up to 50% off on all organic produce this week! Limited time offer!',
    type: 'offer',
    timestamp: '2 hours ago',
    isRead: false,
  ),
  NotificationItem(
    id: 'n2',
    title: '🚚 Your Order #20231101-002 is On Its Way!',
    message:
        'Your delicious organic honey is out for delivery. Estimated arrival: 30 mins.',
    type: 'delivery',
    timestamp: '1 hour ago',
    isRead: false,
  ),
  NotificationItem(
    id: 'n3',
    title: '✨ New Arrivals Just Dropped!',
    message:
        'Discover our fresh collection of seasonal fruits and vegetables. Shop now!',
    type: 'offer',
    timestamp: 'Yesterday',
    isRead: true,
  ),
  NotificationItem(
    id: 'n4',
    title: '✅ Order #20231026-001 Delivered!',
    message: 'Your order has been successfully delivered. Enjoy your products!',
    type: 'delivery',
    timestamp: '2 days ago',
    isRead: true,
  ),
  NotificationItem(
    id: 'n5',
    title: '💰 Earn Rewards with Every Purchase!',
    message:
        'Join our loyalty program and start earning points for exclusive discounts.',
    type: 'general',
    timestamp: '3 days ago',
    isRead: false,
  ),
  NotificationItem(
    id: 'n6',
    title: '📦 Order #20231105-003 Confirmed!',
    message:
        'Your order for Palm Jaggery and Urad Dal Papad has been confirmed.',
    type: 'delivery',
    timestamp: '5 days ago',
    isRead: true,
  ),
];

// Dummy Payment Methods
List<PaymentMethod> dummyPaymentMethods = [
  PaymentMethod(
    id: 'pm1',
    type: 'Credit Card',
    cardHolderName: 'Ash',
    lastFourDigits: '1234',
    expiryDate: '12/25',
    isDefault: true,
  ),
  PaymentMethod(
    id: 'pm2',
    type: 'Debit Card',
    cardHolderName: 'Ash',
    lastFourDigits: '5678',
    expiryDate: '06/27',
    isDefault: false,
  ),
  PaymentMethod(
    id: 'pm3',
    type: 'UPI',
    upiId: 'ash@upi',
    isDefault: false,
  ),
  PaymentMethod(
    id: 'pm4',
    type: 'Cash on Delivery',
    isDefault: false,
  ),
];

// Dummy User Accounts
ValueNotifier<List<UserAccount>> dummyUserAccountsNotifier = ValueNotifier([
  UserAccount(
    id: 'user1',
    name: 'Ash',
    email: 'ash@gmail.com',
    phoneNumber: '+91 77777 77777',
    profileImageUrl:
        'https://media.licdn.com/dms/image/v2/C4D12AQHdzXTeTTtCBQ/article-cover_image-shrink_720_1280/article-cover_image-shrink_720_1280/0/1597568529445?e=2147483647&v=beta&t=92p2XlkDwGdHlKfERzaI9_i_JZib65VNWu3PGLgONys',
    isActive: true, // This is the currently active user
    isSeller: true, // Ash is a seller
    isSellerProfileComplete: true, // Ash's seller profile is complete
    storeName: 'Ash\'s Organics',
    sellerAddress1: '789, Seller Street',
    sellerAddress2: 'Near Market',
    sellerCity: 'Coimbatore',
    sellerState: 'Tamil Nadu',
    sellerPostalCode: '641001',
    bankDetails: BankDetails(
      bankName: 'State Bank of India',
      accountNumber: '1234567890',
      ifscCode: 'SBIN0001234',
      accountHolderName: 'Ash',
    ),
  ),
  UserAccount(
    id: 'user2',
    name: 'Krupa',
    email: 'krupa@egmail.com',
    phoneNumber: '+91 55555 55555',
    profileImageUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_bfb2hnNWfeX-HGsWeLuWu7eUlyFbiPWoRw&s', // Updated to 'K'
    isActive: false,
    isSeller: false, // Krupa is not a seller
    isSellerProfileComplete: false,
  ),
]);
