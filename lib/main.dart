import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// Firebase imports commented out - not currently used in the app
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/user_provider.dart';
import 'providers/gallery_provider.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_screen.dart';

/// Main entry point for the AliExpress Clone app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization commented out - not currently used in the app
  // Uncomment when Firebase is properly configured
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const AliExpressCloneApp());
}

/// Root widget with MultiProvider setup
class AliExpressCloneApp extends StatelessWidget {
  const AliExpressCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Product Provider - manages products and admin operations
        ChangeNotifierProvider(create: (_) => ProductProvider()),

        // Cart Provider - manages shopping cart
        ChangeNotifierProvider(create: (_) => CartProvider()..loadCart()),

        // User Provider - manages user profile
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),

        // Gallery Provider - manages media gallery for admin
        ChangeNotifierProvider(create: (_) => GalleryProvider()..loadImages()),
      ],
      child: MaterialApp(
        title: 'AliExpress Clone',
        debugShowCheckedModeBanner: false,

        // Professional Business Theme
        theme: ThemeData(
          useMaterial3: true,

          // Professional color scheme - Navy Blue & Teal
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0), // Professional Blue
            primary: const Color(0xFF1565C0),
            secondary: const Color(0xFF00897B), // Teal accent
            surface: Colors.white,
            brightness: Brightness.light,
          ),

          // Professional Typography with better hierarchy
          textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme)
              .copyWith(
                displayLarge: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                displayMedium: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                displaySmall: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.25,
                ),
                headlineLarge: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                headlineMedium: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                titleLarge: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.15,
                ),
                titleMedium: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
                bodyLarge: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.5,
                ),
                bodyMedium: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.25,
                ),
                bodySmall: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.4,
                ),
              ),

          // Professional Card Design
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),

          // Professional Button Styles
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Professional Input Fields
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
          ),

          // App Bar Theme
          appBarTheme: AppBarTheme(
            elevation: 0,
            centerTitle: false,
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            titleTextStyle: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.15,
            ),
          ),

          // Chip Theme
          chipTheme: ChipThemeData(
            backgroundColor: Colors.grey[100],
            selectedColor: const Color(0xFF1565C0),
            labelStyle: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // Divider Theme
          dividerTheme: DividerThemeData(
            color: Colors.grey[200],
            thickness: 1,
            space: 24,
          ),
        ),

        home: const MainNavigationScreen(),
      ),
    );
  }
}

/// Main navigation screen with bottom navigation bar
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Screen list for bottom navigation
  final List<Widget> _screens = const [
    HomeScreen(), // Home / Product Catalog
    CartScreen(), // Shopping Cart
    ProfileScreen(), // User Profile
    AdminScreen(), // Admin Panel
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      // Bottom Navigation Bar
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          // Home Tab
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: 'Home',
          ),

          // Cart Tab with badge
          NavigationDestination(
            icon: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return Badge(
                  label: Text('${cartProvider.itemCount}'),
                  isLabelVisible: cartProvider.itemCount > 0,
                  child: const Icon(Icons.shopping_cart_outlined),
                );
              },
            ),
            selectedIcon: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return Badge(
                  label: Text('${cartProvider.itemCount}'),
                  isLabelVisible: cartProvider.itemCount > 0,
                  child: const Icon(Icons.shopping_cart),
                );
              },
            ),
            label: 'Cart',
          ),

          // Profile Tab
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),

          // Admin Tab
          const NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}
