import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gallery_image.dart';

class GalleryProvider with ChangeNotifier {
  List<GalleryImage> _images = [];

  List<GalleryImage> get images => [..._images];

  Future<void> loadImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagesString = prefs.getString('gallery_images');

      if (imagesString != null && imagesString.isNotEmpty) {
        final List<dynamic> decodedData = json.decode(imagesString);
        _images = decodedData
            .map((item) => GalleryImage.fromJson(item))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading gallery images: $e');
      _images = [];
      notifyListeners();
    }
  }

  Future<void> _saveImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagesString = json.encode(
        _images.map((img) => img.toJson()).toList(),
      );
      await prefs.setString('gallery_images', imagesString);
    } catch (e) {
      debugPrint('Error saving gallery images: $e');
    }
  }

  // Add new image to gallery
  Future<void> addImage(String imagePath, String name) async {
    final newImage = GalleryImage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      name: name,
      uploadedAt: DateTime.now(),
    );

    _images.insert(0, newImage); // Add at the beginning
    notifyListeners();
    await _saveImages();
  }

  // Delete image from gallery
  Future<void> deleteImage(String id) async {
    _images.removeWhere((img) => img.id == id);
    notifyListeners();
    await _saveImages();
  }

  // Get image by ID
  GalleryImage? getImageById(String id) {
    try {
      return _images.firstWhere((img) => img.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get total images count
  int get totalImages => _images.length;
}
