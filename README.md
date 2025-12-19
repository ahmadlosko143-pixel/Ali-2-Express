# AliExpress Clone - Flutter E-Commerce App

A comprehensive Flutter-based e-commerce mobile application inspired by AliExpress, featuring a modern UI with Material 3 design principles.

## Student Information

- **Name:** Ahmad Ali Raza
- **Registration #:** FA22-BSE-062

## Features

### Main App Features

#### 1. Home / Product Catalog Screen
- Grid/list view of products with images, names, prices
- Search functionality to find products by name
- Category filter chips (Electronics, Fashion, Home, Sports, etc.)
- Add to cart functionality from product cards
- Loading states and empty states

#### 2. Product Detail Screen
- Full product information display
- Product image, name, description, price
- Star rating and review count
- Category chip
- Quantity selector (1-10 items)
- Add to cart with selected quantity

#### 3. Shopping Cart Screen
- Display all cart items with images and details
- Update quantity controls (+/-)
- Remove individual items
- Clear entire cart option
- Real-time total calculation
- Checkout button to proceed to payment

#### 4. Payment Gateway (Frontend Only)
- Simulated payment form
- Card number input with auto-formatting
- Card holder name field
- Expiry date (MM/YY format)
- CVV field (masked)
- Order summary display
- Payment success animation
- Automatic cart clearing after successful payment

#### 5. User Profile Screen
- Display user information (name, registration number)
- Profile picture management (camera/gallery)
- Edit profile functionality
- Toggle between view and edit modes
- Data persistence using SharedPreferences

### Admin Panel

#### Authentication
- Simple login system (username: `admin`, password: `1234`)
- Session persistence
- Logout functionality

#### Product Management (CRUD Operations)
- **Create:** Add new products with name, price, category, description, image URL
- **Read:** View all products in a list
- **Update:** Edit existing product details
- **Delete:** Remove products with confirmation
- Product statistics dashboard

## Project Structure

```
lib/
├── main.dart                          # App entry point with MultiProvider
├── models/                            # Data models
│   ├── product.dart
│   ├── user.dart
│   └── cart_item.dart
├── providers/                         # State management
│   ├── product_provider.dart
│   ├── cart_provider.dart
│   └── user_provider.dart
└── screens/                           # UI screens
    ├── home_screen.dart
    ├── product_detail_screen.dart
    ├── cart_screen.dart
    ├── payment_screen.dart
    ├── profile_screen.dart
    ├── admin_screen.dart
    └── admin_panel_screen.dart

assets/
├── data/
│   └── products.json                  # Sample product data (15 products)
└── images/                            # Image assets directory
```

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the app**
   ```bash
   flutter run
   ```

## Usage Guide

### Admin Credentials
- **Username:** admin
- **Password:** 1234

### Navigation
- **Home:** Browse and search products
- **Cart:** View cart items and checkout
- **Profile:** Manage user profile (Ahmad Ali Raza - FA22-BSE-062)
- **Admin:** Login to manage products (CRUD operations)

## Technical Stack

- **Framework:** Flutter with Material 3
- **State Management:** Provider
- **Local Storage:** SharedPreferences
- **Typography:** Google Fonts (Poppins)
- **Image Handling:** image_picker
- **Architecture:** MVVM pattern

## Key Features

- ✅FireBase backend with automate authentication and data save
- ✅ Material 3 design system
- ✅ Persistent shopping cart
- ✅ Admin product management
- ✅ Profile image upload
- ✅ Simulated payment gateway
- ✅ Search and filter products
- ✅ Form validation
- ✅ Responsive UI

## Notes

- All product images use placeholder URLs
- Payment is simulated (no real transactions)
- Admin credentials are hardcoded for demo
- Profile images stored locally on device

## Author

**Ahmad Ali Raza**
- Registration: FA22-BSE-062
- Course: Mobile Application Development

---

Built with Flutter & Dart
