import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'gallery_screen.dart';

/// Admin panel screen with CRUD operations
class AdminPanelScreen extends StatelessWidget {
  final Future<void> Function() onLogout;

  const AdminPanelScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Panel',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            tooltip: 'Media Gallery',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GalleryScreen(isSelectMode: false),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return Column(
            children: [
              // Stats Card
              _buildStatsCard(productProvider),

              // Products List
              Expanded(
                child: productProvider.allProducts.isEmpty
                    ? _buildEmptyState()
                    : _buildProductsList(context, productProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  /// Stats card showing product count
  Widget _buildStatsCard(ProductProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.inventory, size: 32, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Products',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${provider.allProducts.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No products yet',
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add products',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// Products list
  Widget _buildProductsList(BuildContext context, ProductProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.allProducts.length,
      itemBuilder: (context, index) {
        final product = provider.allProducts[index];
        return _buildProductItem(context, product, provider);
      },
    );
  }

  /// Individual product item
  Widget _buildProductItem(
    BuildContext context,
    Product product,
    ProductProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildProductThumbnail(product),
        ),
        title: Text(
          product.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(product.category, style: GoogleFonts.poppins(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditProductDialog(context, product),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  _showDeleteConfirmation(context, product, provider),
            ),
          ],
        ),
      ),
    );
  }

  /// Build product thumbnail from local file or network URL
  Widget _buildProductThumbnail(Product product) {
    final errorWidget = Container(
      width: 60,
      height: 60,
      color: Colors.grey[300],
      child: const Icon(Icons.image),
    );

    // Check if it's a local file path
    if (product.imageUrl.startsWith('/') || product.imageUrl.contains('\\')) {
      return Image.file(
        File(product.imageUrl),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    } else {
      // It's a network URL
      return Image.network(
        product.imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    }
  }

  /// Show add product dialog
  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ProductFormDialog(
        title: 'Add Product',
        onSubmit: (product) async {
          await context.read<ProductProvider>().addProduct(product);
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product added successfully'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  /// Show edit product dialog
  void _showEditProductDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => _ProductFormDialog(
        title: 'Edit Product',
        product: product,
        onSubmit: (updatedProduct) async {
          await context.read<ProductProvider>().updateProduct(
            product.id,
            updatedProduct,
          );
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product updated successfully'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  /// Show delete confirmation
  void _showDeleteConfirmation(
    BuildContext context,
    Product product,
    ProductProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Product',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}"?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await provider.deleteProduct(product.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product deleted successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Show logout dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

/// Product form dialog for adding/editing products
class _ProductFormDialog extends StatefulWidget {
  final String title;
  final Product? product;
  final Function(Product) onSubmit;

  const _ProductFormDialog({
    required this.title,
    this.product,
    required this.onSubmit,
  });

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _imageUrlController;
  final _imagePicker = ImagePicker();
  String? _selectedImagePath;

  final List<String> _categories = [
    'Electronics',
    'Fashion',
    'Home',
    'Sports',
    'Books',
    'Toys',
    'Beauty',
    'Food',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.product?.category ?? _categories[0],
    );

    // Check if product has a local image path or URL
    if (widget.product?.imageUrl != null) {
      if (widget.product!.imageUrl.startsWith('/') ||
          widget.product!.imageUrl.contains('\\')) {
        // It's a local file path
        _selectedImagePath = widget.product!.imageUrl;
        _imageUrlController = TextEditingController(text: '');
      } else {
        // It's a network URL
        _imageUrlController = TextEditingController(
          text: widget.product!.imageUrl,
        );
        _selectedImagePath = null;
      }
    } else {
      _imageUrlController = TextEditingController(text: '');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  /// Show image source selection bottom sheet
  Future<void> _pickImage() async {
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Select Image Source',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              // Media Gallery option (NEW)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.photo_library_outlined,
                    color: Colors.purple[700],
                  ),
                ),
                title: const Text('Media Gallery'),
                subtitle: const Text('Select from uploaded images'),
                onTap: () => Navigator.pop(context, 'gallery'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),

              // Gallery option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library, color: Colors.blue[700]),
                ),
                title: const Text('Device Gallery'),
                subtitle: const Text('Choose from photo gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),

              // Camera option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.green[700]),
                ),
                title: const Text('Camera'),
                subtitle: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),

              // Files option (using gallery but with different description)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.folder_open, color: Colors.orange[700]),
                ),
                title: const Text('Files'),
                subtitle: const Text('Browse device files'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      if (result == 'gallery') {
        await _selectFromMediaGallery();
      } else if (result is ImageSource) {
        await _pickImageFromSource(result);
      }
    }
  }

  /// Select image from media gallery
  Future<void> _selectFromMediaGallery() async {
    final selectedImagePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const GalleryScreen(isSelectMode: true),
      ),
    );

    if (selectedImagePath != null) {
      setState(() {
        _selectedImagePath = selectedImagePath;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(child: Text('Image selected from gallery')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  /// Pick image from selected source
  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Image selected: ${pickedFile.name}')),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Price
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (double.tryParse(value!) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Category
                DropdownButtonFormField<String>(
                  initialValue: _categoryController.text.isNotEmpty
                      ? _categoryController.text
                      : _categories[0],
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _categoryController.text = value;
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Image Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Image',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),

                    // Image Preview
                    if (_selectedImagePath != null ||
                        _imageUrlController.text.isNotEmpty)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildImagePreview(),
                        ),
                      ),
                    if (_selectedImagePath != null ||
                        _imageUrlController.text.isNotEmpty)
                      const SizedBox(height: 12),

                    // Image URL Input
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        labelText: 'Image URL from Google/Web',
                        border: const OutlineInputBorder(),
                        hintText: 'https://example.com/image.jpg',
                        prefixIcon: const Icon(Icons.link),
                        suffixIcon: _imageUrlController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _imageUrlController.clear();
                                  });
                                },
                              )
                            : null,
                      ),
                      keyboardType: TextInputType.url,
                      onChanged: (value) {
                        setState(() {});
                      },
                      validator: (value) {
                        if (_selectedImagePath == null &&
                            (value?.isEmpty ?? true)) {
                          return 'Please provide an image URL or pick from device';
                        }
                        if (value != null && value.isNotEmpty) {
                          if (!value.startsWith('http://') &&
                              !value.startsWith('https://')) {
                            return 'URL must start with http:// or https://';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Divider with "OR"
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Pick Image Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: Text(
                          _selectedImagePath != null
                              ? 'Change Local Image'
                              : 'Pick Image from Device',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Helper text
                    Text(
                      'Tip: Right-click on any Google image → Copy image address → Paste above',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitForm,
          child: Text(widget.product == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  /// Build image preview for both local files and URLs
  Widget _buildImagePreview() {
    // Prioritize local file if selected
    if (_selectedImagePath != null) {
      return Image.file(
        File(_selectedImagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageErrorWidget();
        },
      );
    }

    // Otherwise use URL if provided
    if (_imageUrlController.text.isNotEmpty) {
      return Image.network(
        _imageUrlController.text,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildImageErrorWidget();
        },
      );
    }

    return _buildImageErrorWidget();
  }

  /// Build error widget for image preview
  Widget _buildImageErrorWidget() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Image failed to load',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Submit form
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Use selected image path if available, otherwise use URL
    final imageSource = _selectedImagePath ?? _imageUrlController.text;

    final product = Product(
      id:
          widget.product?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      category: _categoryController.text,
      imageUrl: imageSource,
      rating: widget.product?.rating ?? 4.0,
      reviews: widget.product?.reviews ?? 0,
    );

    widget.onSubmit(product);
  }
}
