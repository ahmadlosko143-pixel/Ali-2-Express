import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';

class GalleryScreen extends StatefulWidget {
  final bool isSelectMode;

  const GalleryScreen({super.key, this.isSelectMode = false});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load images when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<GalleryProvider>(context, listen: false).loadImages();
      }
    });
  }

  Future<void> _uploadImage() async {
    try {
      // Show bottom sheet to select source
      final dynamic source = await showModalBottomSheet<dynamic>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.link, color: Colors.purple[700]),
                ),
                title: const Text('Image URL'),
                subtitle: const Text('Add from Google/Web URL'),
                onTap: () => Navigator.pop(context, 'url'),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library, color: Colors.blue[700]),
                ),
                title: const Text('Gallery'),
                subtitle: const Text('Choose from photo gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
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
                subtitle: const Text('Take a new photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        if (source == 'url') {
          await _addImageFromUrl();
        } else if (source is ImageSource) {
          final pickedFile = await _imagePicker.pickImage(
            source: source,
            maxWidth: 1200,
            maxHeight: 1200,
            imageQuality: 85,
          );

          if (pickedFile != null && mounted) {
            // Show dialog to enter image name
            final String? imageName = await _showNameDialog();

            if (imageName != null && imageName.isNotEmpty && mounted) {
              await Provider.of<GalleryProvider>(
                context,
                listen: false,
              ).addImage(pickedFile.path, imageName);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image uploaded successfully!')),
                );
              }
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
    }
  }

  Future<void> _addImageFromUrl() async {
    final TextEditingController urlController = TextEditingController();
    final TextEditingController nameController = TextEditingController();

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Image from URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                hintText: 'https://example.com/image.jpg',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Image Name',
                hintText: 'e.g., Product Image 1',
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tip: Right-click on Google image → Copy image address',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final url = urlController.text.trim();
      final name = nameController.text.trim();

      if (url.isEmpty || name.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please provide both URL and name')),
          );
        }
        return;
      }

      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('URL must start with http:// or https://'),
            ),
          );
        }
        return;
      }

      await Provider.of<GalleryProvider>(
        context,
        listen: false,
      ).addImage(url, name);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image URL added successfully!')),
        );
      }
    }
  }

  Future<String?> _showNameDialog() async {
    final TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Enter image name',
            hintText: 'e.g., Product Image 1',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteImage(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              await Provider.of<GalleryProvider>(
                context,
                listen: false,
              ).deleteImage(id);

              if (mounted) {
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Image deleted successfully!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelectMode ? 'Select Image' : 'Gallery'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer<GalleryProvider>(
        builder: (context, galleryProvider, child) {
          if (galleryProvider.images.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No images in gallery',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap the + button to upload images',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: galleryProvider.images.length,
            itemBuilder: (context, index) {
              final image = galleryProvider.images[index];

              return GestureDetector(
                onTap: widget.isSelectMode
                    ? () => Navigator.pop(context, image.imagePath)
                    : null,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: _buildGalleryImage(image.imagePath),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              image.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDate(image.uploadedAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (!widget.isSelectMode)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _deleteImage(image.id),
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
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadImage,
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Build gallery image - handles both local files and network URLs
  Widget _buildGalleryImage(String imagePath) {
    // Check if it's a network URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
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
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 50),
        ),
      );
    } else {
      // It's a local file
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 50),
        ),
      );
    }
  }
}
