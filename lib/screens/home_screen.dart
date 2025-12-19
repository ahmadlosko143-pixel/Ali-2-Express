import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

/// Professional Home screen displaying product catalog
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Product Catalog'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return IconButton(
                icon: Badge(
                  label: Text('${cart.itemCount}'),
                  isLabelVisible: cart.itemCount > 0,
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                onPressed: () {},
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          return Column(
            children: [
              // Professional Header Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Text
                    Text(
                      'Discover Products',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${productProvider.products.length} items available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Professional Search Bar
                    _buildSearchBar(productProvider, theme),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Category Filter Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCategoryFilter(productProvider, theme),
              ),
              const SizedBox(height: 12),

              // Product Grid
              Expanded(
                child: productProvider.products.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildProductGrid(productProvider.products, theme),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Professional search bar
  Widget _buildSearchBar(ProductProvider provider, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products, categories...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, size: 20, color: Colors.grey[600]),
                  onPressed: () {
                    _searchController.clear();
                    provider.searchProducts('');
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          filled: false,
        ),
        onChanged: (value) {
          provider.searchProducts(value);
          setState(() {});
        },
      ),
    );
  }

  /// Professional category filter
  Widget _buildCategoryFilter(ProductProvider provider, ThemeData theme) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final category = provider.categories[index];
          final isSelected = provider.selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                provider.filterByCategory(category);
              },
              backgroundColor: Colors.white,
              selectedColor: theme.colorScheme.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey[300]!,
                width: 1,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  /// Professional product grid
  Widget _buildProductGrid(List<Product> products, ThemeData theme) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6, // Increased to give more vertical space
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index], theme);
      },
    );
  }

  /// Professional product card
  Widget _buildProductCard(Product product, ThemeData theme) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart = cartProvider.isInCart(product.id);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Image with Badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _buildProductImage(product),
                      ),
                    ),

                    // Category Badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Product Details
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          height: 1.2,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Rating
                      Row(
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.amber[700]),
                          const SizedBox(width: 3),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '(${product.reviews})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Price and Add to Cart
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              color: isInCart
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                isInCart ? Icons.check : Icons.add,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: () async {
                                await cartProvider.addToCart(product);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${product.name} added to cart',
                                      ),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Professional empty state
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No Products Found', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Build product image from local file or network URL
  Widget _buildProductImage(Product product) {
    // Check if it's a local file path
    if (product.imageUrl.startsWith('/') || product.imageUrl.contains('\\')) {
      return Image.file(
        File(product.imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageErrorWidget();
        },
      );
    } else {
      // It's a network URL
      return Image.network(
        product.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageErrorWidget();
        },
      );
    }
  }

  /// Build error widget for images
  Widget _buildImageErrorWidget() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(Icons.image_outlined, size: 40, color: Colors.grey[400]),
      ),
    );
  }
}
