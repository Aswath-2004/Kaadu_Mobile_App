// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaadu_organics_app/models.dart'; // Ensure models.dart is imported for Order type
import 'package:kaadu_organics_app/screens/home_screen.dart';
import 'package:kaadu_organics_app/screens/product_detail_screen.dart';
import 'package:kaadu_organics_app/screens/my_cart_screen.dart';
import 'package:kaadu_organics_app/screens/categories_screen.dart';
import 'package:kaadu_organics_app/screens/profile_screen.dart';
import 'package:kaadu_organics_app/screens/search_screen.dart';
import 'package:kaadu_organics_app/screens/filter_screen.dart';
import 'package:kaadu_organics_app/screens/my_orders_screen.dart';
import 'package:kaadu_organics_app/screens/invoice_screen.dart';
import 'package:kaadu_organics_app/screens/rate_now_screen.dart';
import 'package:kaadu_organics_app/screens/edit_profile_screen.dart';
import 'package:kaadu_organics_app/screens/address_screen.dart';
import 'package:kaadu_organics_app/screens/add_edit_address_screen.dart';
import 'package:kaadu_organics_app/screens/wishlist_screen.dart';
import 'package:kaadu_organics_app/screens/notifications_screen.dart';
import 'package:kaadu_organics_app/screens/payment_methods_screen.dart';
import 'package:kaadu_organics_app/screens/add_edit_payment_method_screen.dart';
import 'package:kaadu_organics_app/screens/add_new_account_screen.dart';
import 'package:kaadu_organics_app/screens/become_seller_screen.dart';
import 'package:kaadu_organics_app/screens/seller_dashboard_screen.dart';
import 'package:kaadu_organics_app/screens/seller_details_screen.dart';
import 'package:kaadu_organics_app/screens/category_products_screen.dart'; // Import CategoryProductsScreen
import 'package:kaadu_organics_app/screens/checkout_screen.dart'; // NEW: Import CheckoutScreen
import 'package:provider/provider.dart';
import 'package:kaadu_organics_app/providers/product_provider.dart';
import 'package:kaadu_organics_app/providers/wishlist_provider.dart';
import 'package:kaadu_organics_app/providers/cart_provider.dart';

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'
    hide Order; // HIDE Order to resolve ambiguity

// Dart convert for JSON decoding
import 'dart:convert';

// Declare global variables for Canvas environment.
// These will be overridden by the Canvas runtime if provided.
// Using String.fromEnvironment to correctly access environment variables in Dart.
const String appId =
    String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');
const String firebaseConfigString =
    String.fromEnvironment('FIREBASE_CONFIG', defaultValue: '{}');
const String initialAuthToken =
    String.fromEnvironment('INITIAL_AUTH_TOKEN', defaultValue: '');

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    final Map<String, dynamic> firebaseConfig =
        json.decode(firebaseConfigString);

    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: firebaseConfig['apiKey'] ?? '',
        appId: firebaseConfig['appId'] ?? '',
        messagingSenderId: firebaseConfig['messagingSenderId'] ?? '',
        projectId: firebaseConfig['projectId'] ?? '',
        authDomain: firebaseConfig['authDomain'] ?? '',
        storageBucket: firebaseConfig['storageBucket'] ?? '',
      ),
    );

    // Authenticate anonymously if no initial token, or with token if provided
    final auth = FirebaseAuth.instance;
    if (initialAuthToken.isNotEmpty) {
      await auth.signInWithCustomToken(initialAuthToken);
    } else {
      await auth.signInAnonymously();
    }
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
    // Handle Firebase initialization error gracefully, e.g., show an error message
  }

  // Set preferred orientations to portrait only
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      // Wrap your app with MultiProvider
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ProductProvider()),
          ChangeNotifierProvider(
            create: (context) => WishlistProvider(
              firestore: FirebaseFirestore.instance,
              auth: FirebaseAuth.instance,
              appId: appId,
            ),
          ),
          // Add CartProvider
          ChangeNotifierProvider(
            create: (context) => CartProvider(
              firestore: FirebaseFirestore.instance,
              auth: FirebaseAuth.instance,
              appId: appId,
            ),
          ),
        ],
        child: const KaaduOrganicsApp(),
      ),
    );
  });
}

class KaaduOrganicsApp extends StatefulWidget {
  const KaaduOrganicsApp({super.key});

  @override
  State<KaaduOrganicsApp> createState() => _KaaduOrganicsAppState();
}

class _KaaduOrganicsAppState extends State<KaaduOrganicsApp> {
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark mode

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kaadu Organics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Light theme properties
        brightness: Brightness.light,
        primaryColor: const Color(0xFFFFFFFF), // White background
        scaffoldBackgroundColor: const Color(0xFFFFFFFF), // White background
        cardColor: const Color(0xFFF0F0F0), // Light grey for cards
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.black,
                displayColor: Colors.black,
              ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFE0E0E0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xFF5CB85C), width: 1.5),
          ),
          hintStyle: TextStyle(color: Colors.black.withAlpha(153)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5CB85C), // Green button
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF5CB85C),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFF0F0F0), // Lighter grey for nav bar
          selectedItemColor: Color(0xFF5CB85C), // Green for selected item
          unselectedItemColor: Colors.black54, // Black for unselected
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontSize: 12),
          unselectedLabelStyle: TextStyle(fontSize: 12),
        ),
      ),
      darkTheme: ThemeData(
        // Dark theme properties (your original theme)
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1E2125), // Dark background
        scaffoldBackgroundColor: const Color(0xFF1E2125), // Dark background
        cardColor: const Color(0xFF2C2F33), // Slightly lighter dark for cards
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E2125),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2F33),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xFF5CB85C), width: 1.5),
          ),
          hintStyle: TextStyle(color: Colors.white.withAlpha(153)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5CB85C), // Green button
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF5CB85C),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF2C2F33), // Darker grey for nav bar
          selectedItemColor: Color(0xFF5CB85C), // Green for selected item
          unselectedItemColor: Colors.white54, // White for unselected
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontSize: 12),
          unselectedLabelStyle: TextStyle(fontSize: 12),
        ),
      ),
      themeMode: _themeMode, // Use the theme mode state
      initialRoute: '/',
      routes: {
        '/': (context) =>
            MainScreenWrapper(toggleTheme: toggleTheme), // Pass toggleTheme
        '/product_detail': (context) => const ProductDetailScreen(),
        '/cart': (context) => const MyCartScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/search': (context) => const SearchScreen(),
        '/filter': (context) => const FilterScreen(),
        '/my_orders': (context) => const MyOrdersScreen(),
        '/invoice': (context) => InvoiceScreen(
            order: ModalRoute.of(context)?.settings.arguments as Order?),
        '/rate_now': (context) => RateNowScreen(
            order: ModalRoute.of(context)?.settings.arguments as Order?),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/addresses': (context) => const AddressScreen(), // New route
        '/add_edit_address': (context) => AddEditAddressScreen(
              address: ModalRoute.of(context)?.settings.arguments as Address?,
            ), // New route with optional argument
        '/wishlist': (context) =>
            const WishlistScreen(), // New import for WishlistScreen
        '/notifications': (context) =>
            const NotificationsScreen(), // New import for NotificationsScreen
        '/payment_methods': (context) =>
            const PaymentMethodsScreen(), // New import for PaymentMethodsScreen
        '/add_edit_payment_method': (context) => AddEditPaymentMethodScreen(
              paymentMethod:
                  ModalRoute.of(context)?.settings.arguments as PaymentMethod?,
            ), // New route for AddEditPaymentMethodScreen
        '/add_new_account': (context) =>
            const AddNewAccountScreen(), // New route for AddNewAccountScreen
        '/become_seller': (context) => BecomeSellerScreen(
              // <--- UPDATED ROUTE
              userAccount:
                  ModalRoute.of(context)?.settings.arguments as UserAccount?,
            ),
        '/seller_dashboard': (context) => const SellerDashboardScreen(),
        '/seller_details': (context) => SellerDetailsScreen(
              sellerAccount:
                  ModalRoute.of(context)?.settings.arguments as UserAccount,
            ),
        '/category_products': (context) => CategoryProductsScreen(
              category: ModalRoute.of(context)?.settings.arguments as Category,
            ),
        '/checkout': (context) => const CheckoutScreen(), // NEW ROUTE
      },
    );
  }
}

// This wrapper handles the bottom navigation bar
class MainScreenWrapper extends StatefulWidget {
  final VoidCallback toggleTheme; // Add toggleTheme callback
  const MainScreenWrapper({super.key, required this.toggleTheme});

  @override
  State<MainScreenWrapper> createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
  int _selectedIndex = 0;

  late List<Widget> _widgetOptions; // Make it late and initialize in initState

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomeScreen(
          toggleTheme: widget.toggleTheme), // Pass toggleTheme to HomeScreen
      const CategoriesScreen(),
      const MyCartScreen(),
      const WishlistScreen(), // Added WishlistScreen
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_rounded),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_rounded),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            // New Wishlist tab
            icon: Icon(Icons.favorite_rounded),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
