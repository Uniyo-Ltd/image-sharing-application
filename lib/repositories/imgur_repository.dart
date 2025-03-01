import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/imgur_api_client.dart';
import '../models/imgur_gallery_item.dart';
import '../models/imgur_image.dart';
import '../utils/constants.dart';
import 'package:flutter/foundation.dart';

class ImgurRepository {
  final ImgurApiClient apiClient;
  final SharedPreferences sharedPreferences;
  
  ImgurRepository({
    required this.apiClient,
    required this.sharedPreferences,
  });
  
  // Get popular gallery images
  Future<List<ImgurGalleryItem>> getGalleryImages({
    String section = 'hot',
    String sort = 'viral',
    String window = 'day',
    int page = 0,
  }) async {
    try {
      final response = await apiClient.getGalleryImages(
        section: section,
        sort: sort,
        window: window,
        page: page,
      );
      
      if (response['success'] == true && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => ImgurGalleryItem.fromJson(item))
            .where((item) => !item.isNsfw) // Filter out NSFW content
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to fetch gallery images: $e');
    }
  }
  
  // Search for gallery images
  Future<List<ImgurGalleryItem>> searchGalleryImages({
    required String query,
    String sort = 'viral',
    String window = 'all',
    int page = 0,
  }) async {
    try {
      final response = await apiClient.searchImages(
        query: query,
        sort: sort,
        window: window,
        page: page,
      );
      
      if (response['success'] == true && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => ImgurGalleryItem.fromJson(item))
            .where((item) => !item.isNsfw) // Filter out NSFW content
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to search images: $e');
    }
  }
  
  // Get image details by ID
  Future<ImgurImage> getImageDetails(String imageId) async {
    try {
      final response = await apiClient.getImageDetails(imageId);
      
      if (response['success'] == true && response['data'] != null) {
        return ImgurImage.fromJson(response['data']);
      }
      
      throw Exception('Failed to get image details');
    } catch (e) {
      throw Exception('Failed to fetch image details: $e');
    }
  }
  
  // Get album details by ID
  Future<ImgurGalleryItem> getAlbumDetails(String albumId) async {
    try {
      final response = await apiClient.getAlbumDetails(albumId);
      
      if (response['success'] == true && response['data'] != null) {
        return ImgurGalleryItem.fromJson(response['data']);
      }
      
      throw Exception('Failed to get album details');
    } catch (e) {
      throw Exception('Failed to fetch album details: $e');
    }
  }
  
  // Add an image to favorites
  Future<void> addToFavorites(ImgurImage image) async {
    try {
      // Get current favorites
      final favorites = getFavoriteImages();
      
      // Check if already in favorites
      if (favorites.any((item) => item.id == image.id)) {
        return;
      }
      
      // Add to favorites
      favorites.add(image);
      
      // Save to shared preferences
      await sharedPreferences.setString(
        AppConstants.favoriteImagesKey,
        jsonEncode(favorites.map((img) => img.toJson()).toList()),
      );
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }
  
  // Remove an image from favorites
  Future<void> removeFromFavorites(String imageId) async {
    try {
      // Get current favorites
      final favorites = getFavoriteImages();
      
      // Remove from favorites
      final updatedFavorites = favorites.where((img) => img.id != imageId).toList();
      
      // Save to shared preferences
      await sharedPreferences.setString(
        AppConstants.favoriteImagesKey,
        jsonEncode(updatedFavorites.map((img) => img.toJson()).toList()),
      );
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }
  
  // Get all favorite images
  List<ImgurImage> getFavoriteImages() {
    try {
      final favoritesJson = sharedPreferences.getString(AppConstants.favoriteImagesKey);
      
      if (favoritesJson == null) {
        return [];
      }
      
      final List<dynamic> decodedJson = jsonDecode(favoritesJson);
      return decodedJson.map((item) => ImgurImage.fromJson(item)).toList();
    } catch (e) {
      // If there's an error, return empty list (don't throw)
      return [];
    }
  }
  
  // Add a search term to recent searches
  Future<void> addRecentSearch(String searchTerm) async {
    try {
      final recentSearches = getRecentSearches();
      
      // Remove if already exists (to move it to the top)
      recentSearches.removeWhere((term) => term == searchTerm);
      
      // Add to the beginning
      recentSearches.insert(0, searchTerm);
      
      // Keep only the latest 10 searches
      final updatedSearches = recentSearches.take(10).toList();
      
      // Save to shared preferences
      await sharedPreferences.setStringList(
        AppConstants.recentSearchesKey,
        updatedSearches,
      );
    } catch (e) {
      debugPrint('Failed to add recent search: $e');
      // Don't throw, just log the error
    }
  }
  
  // Remove a specific search term from recent searches
  Future<void> removeRecentSearch(String searchTerm) async {
    try {
      final recentSearches = getRecentSearches();
      
      // Remove the specific search term
      recentSearches.removeWhere((term) => term == searchTerm);
      
      // Save to shared preferences
      await sharedPreferences.setStringList(
        AppConstants.recentSearchesKey,
        recentSearches,
      );
    } catch (e) {
      debugPrint('Failed to remove recent search: $e');
      // Don't throw, just log the error
    }
  }
  
  // Get all recent searches
  List<String> getRecentSearches() {
    try {
      return sharedPreferences.getStringList(AppConstants.recentSearchesKey) ?? [];
    } catch (e) {
      debugPrint('Error getting recent searches: $e');
      // If there's an error, return empty list
      return [];
    }
  }
  
  // Clear all recent searches
  Future<void> clearRecentSearches() async {
    try {
      await sharedPreferences.remove(AppConstants.recentSearchesKey);
    } catch (e) {
      debugPrint('Failed to clear recent searches: $e');
      // Don't throw, just log the error
    }
  }
} 