import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import 'payment_screen.dart';

/// Shopping cart screen displaying all cart items
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shopping Cart',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          // Clear cart button
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showClearCartDialog(context, cartProvider),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              // Cart items list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    return _buildCartItem(
                      context,
                      cartProvider.items[index],
                      cartProvider,
                    );
                  },
                ),
              ),

              // Bottom summary and checkout
              _buildBottomSummary(context, cartProvider),
            ],
          );
        },
      ),
    );
  }

  /// Empty cart state
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// Individual cart item
  Widget _buildCartItem(
    BuildContext context,
    CartItem item,
    CartProvider cartProvider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildCartImage(item.product.imageUrl),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Price per unit
                  Text(
                    '\$${item.product.price.toStringAsFixed(2)} each',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Quantity Controls
                  Row(
                    children: [
                      // Decrease button
                      IconButton(
                        onPressed: () {
                          if (item.quantity > 1) {
                            cartProvider.updateQuantity(
                              item.product.id,
                              item.quantity - 1,
                            );
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),

                      // Quantity
                      Text(
                        item.quantity.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Increase button
                      IconButton(
                        onPressed: () {
                          if (item.quantity < 10) {
                            cartProvider.updateQuantity(
                              item.product.id,
                              item.quantity + 1,
                            );
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),

                      // Total price for this item
                      Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Remove button
            IconButton(
              onPressed: () =>
                  _showRemoveItemDialog(context, cartProvider, item),
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom summary and checkout button
  Widget _buildBottomSummary(BuildContext context, CartProvider cartProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Items count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items (${cartProvider.itemCount})',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Checkout button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Proceed to Checkout',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show remove item confirmation dialog
  void _showRemoveItemDialog(
    BuildContext context,
    CartProvider cartProvider,
    CartItem item,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove Item',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Remove ${item.product.name} from cart?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              cartProvider.removeFromCart(item.product.id);
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  /// Show clear cart confirmation dialog
  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear Cart',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Remove all items from cart?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  /// Build cart image - handles both local files and network URLs
  Widget _buildCartImage(String imageUrl) {
    // Check if it's a local file path
    if (imageUrl.startsWith('/') || imageUrl.contains('\\')) {
      return Image.file(
        File(imageUrl),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[300],
            child: const Icon(Icons.image),
          );
        },
      );
    } else {
      // It's a network URL
      return Image.network(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[300],
            child: const Icon(Icons.image),
          );
        },
      );
    }
  }
}
