import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/product.dart';
import '../providers/cart_provider.dart';

/// Professional Product detail screen
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Section
            _buildImageSection(theme),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  _buildCategoryBadge(theme),
                  const SizedBox(height: 12),

                  // Product Name
                  Text(
                    widget.product.name,
                    style: theme.textTheme.displaySmall,
                  ),
                  const SizedBox(height: 12),

                  // Rating and Reviews
                  _buildRatingSection(theme),
                  const SizedBox(height: 20),

                  // Price Section
                  _buildPriceSection(theme),
                  const SizedBox(height: 24),

                  // Divider
                  Divider(color: Colors.grey[200]),
                  const SizedBox(height: 24),

                  // Description Section
                  Text(
                    'Product Description',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.product.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Divider(color: Colors.grey[200]),
                  const SizedBox(height: 24),

                  // Quantity Selector
                  _buildQuantitySelector(theme),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      // Fixed bottom bar
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  /// Image section with modern design
  Widget _buildImageSection(ThemeData theme) {
    return Container(
      height: 320,
      width: double.infinity,
      color: Colors.grey[50],
      child: Stack(children: [Center(child: _buildProductImage(theme))]),
    );
  }

  /// Build product image from local file or network URL
  Widget _buildProductImage(ThemeData theme) {
    final errorWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 12),
        Text(
          'Image not available',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
        ),
      ],
    );

    // Check if it's a local file path
    if (widget.product.imageUrl.startsWith('/') ||
        widget.product.imageUrl.contains('\\')) {
      return Image.file(
        File(widget.product.imageUrl),
        fit: BoxFit.contain,
        height: 280,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    } else {
      // It's a network URL
      return Image.network(
        widget.product.imageUrl,
        fit: BoxFit.contain,
        height: 280,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    }
  }

  /// Category badge
  Widget _buildCategoryBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        widget.product.category,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Rating and reviews section
  Widget _buildRatingSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Star Rating
          Icon(Icons.star, color: Colors.amber[700], size: 24),
          const SizedBox(width: 8),
          Text(
            widget.product.rating.toStringAsFixed(1),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '/5.0',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),

          const Spacer(),

          // Divider
          Container(width: 1, height: 24, color: Colors.grey[300]),

          const Spacer(),

          // Reviews Count
          Icon(Icons.rate_review_outlined, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Text(
            '${widget.product.reviews} Reviews',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Price section with emphasis
  Widget _buildPriceSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '\$${widget.product.price.toStringAsFixed(2)}',
                style: theme.textTheme.displayMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 16,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Free Shipping',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Quantity selector with modern design
  Widget _buildQuantitySelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Quantity', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),

        Row(
          children: [
            // Quantity controls
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Decrease button
                  IconButton(
                    onPressed: _quantity > 1
                        ? () {
                            setState(() {
                              _quantity--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.remove),
                    iconSize: 20,
                  ),

                  // Quantity display
                  Container(
                    constraints: const BoxConstraints(minWidth: 50),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _quantity.toString(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Increase button
                  IconButton(
                    onPressed: _quantity < 10
                        ? () {
                            setState(() {
                              _quantity++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.add),
                    iconSize: 20,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Max quantity note
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Max 10 items',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Fixed bottom bar with add to cart
  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return Row(
              children: [
                // Total price
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Price',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${(widget.product.price * _quantity).toStringAsFixed(2)}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Add to Cart Button
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await cartProvider.addToCart(
                        widget.product,
                        quantity: _quantity,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '$_quantity x ${widget.product.name} added to cart',
                                  ),
                                ),
                              ],
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            action: SnackBarAction(
                              label: 'VIEW CART',
                              textColor: Colors.white,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Add to Cart'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 56),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
