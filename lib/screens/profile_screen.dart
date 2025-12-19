import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/user_provider.dart';

/// User profile screen with edit capabilities
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Load user data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      userProvider.loadUser();
      _nameController.text = userProvider.user.name;
      _regNumberController.text = userProvider.user.registrationNumber;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Cancel editing - reset to original values
                  final userProvider = context.read<UserProvider>();
                  _nameController.text = userProvider.user.name;
                  _regNumberController.text =
                      userProvider.user.registrationNumber;
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),

                // Profile Picture
                _buildProfilePicture(userProvider),
                const SizedBox(height: 32),

                // Profile Form
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Show text fields only when editing
                        if (_isEditing) ...[
                          // Name Field
                          _buildTextField(
                            controller: _nameController,
                            label: 'Name',
                            icon: Icons.person,
                            enabled: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Registration Number Field
                          _buildTextField(
                            controller: _regNumberController,
                            label: 'Registration Number',
                            icon: Icons.badge,
                            enabled: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter registration number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Save Button
                          _buildSaveButton(userProvider),
                        ],

                        // Profile Info Card (shown when not editing)
                        if (!_isEditing) _buildProfileInfoCard(userProvider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Profile picture with edit option
  Widget _buildProfilePicture(UserProvider userProvider) {
    return Stack(
      children: [
        // Profile Picture
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: userProvider.user.profileImagePath != null
                ? Image.file(
                    File(userProvider.user.profileImagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar();
                    },
                  )
                : _buildDefaultAvatar(),
          ),
        ),

        // Edit Button
        if (_isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                onPressed: () => _pickImage(userProvider),
              ),
            ),
          ),
      ],
    );
  }

  /// Default avatar icon
  Widget _buildDefaultAvatar() {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        Icons.person,
        size: 70,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  /// Text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
      ),
      style: GoogleFonts.poppins(),
      validator: validator,
    );
  }

  /// Save button
  Widget _buildSaveButton(UserProvider userProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _saveProfile(userProvider),
        icon: const Icon(Icons.save),
        label: Text(
          'Save Changes',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Profile info card (shown when not editing)
  Widget _buildProfileInfoCard(UserProvider userProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.person,
              label: 'Name',
              value: userProvider.user.name,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.badge,
              label: 'Registration #',
              value: userProvider.user.registrationNumber,
            ),
          ],
        ),
      ),
    );
  }

  /// Info row widget
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Pick image from gallery or camera
  Future<void> _pickImage(UserProvider userProvider) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Profile Picture',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        await userProvider.updateProfileImage(pickedFile.path);
      }
    }
  }

  /// Save profile changes
  Future<void> _saveProfile(UserProvider userProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await userProvider.updateUser(
      name: _nameController.text,
      registrationNumber: _regNumberController.text,
    );

    setState(() {
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
