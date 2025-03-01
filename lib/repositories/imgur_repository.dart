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
            .where((item) => !item.isNsfw) 
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to fetch gallery images: $e');
    }
  }
  
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
            .where((item) => !item.isNsfw) 
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to search images: $e');
    }
  }
  
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
  
  Future<void> addToFavorites(ImgurImage image) async {
    try {
      final favorites = getFavoriteImages();
      
      if (favorites.any((item) => item.id == image.id)) {
        return;
      }
      
      favorites.add(image);
      
      await sharedPreferences.setString(
        AppConstants.favoriteImagesKey,
        jsonEncode(favorites.map((img) => img.toJson()).toList()),
      );
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }
  
  Future<void> removeFromFavorites(String imageId) async {
    try {
      final favorites = getFavoriteImages();
      final updatedFavorites = favorites.where((img) => img.id != imageId).toList();
      
      await sharedPreferences.setString(
        AppConstants.favoriteImagesKey,
        jsonEncode(updatedFavorites.map((img) => img.toJson()).toList()),
      );
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }
  
  List<ImgurImage> getFavoriteImages() {
    try {
      final favoritesJson = sharedPreferences.getString(AppConstants.favoriteImagesKey);
      
      if (favoritesJson == null) {
        return [];
      }
      
      final List<dynamic> decodedJson = jsonDecode(favoritesJson);
      return decodedJson.map((item) => ImgurImage.fromJson(item)).toList();
    } catch (e) {
      
      return [];
    }
  }
  
  Future<void> addRecentSearch(String searchTerm) async {
    try {
      final recentSearches = getRecentSearches();
      
      
      recentSearches.removeWhere((term) => term == searchTerm);
      
      
      recentSearches.insert(0, searchTerm);
      
      
      final updatedSearches = recentSearches.take(10).toList();
      
      await sharedPreferences.setStringList(
        AppConstants.recentSearchesKey,
        updatedSearches,
      );
    } catch (e) {
      debugPrint('Failed to add recent search: $e');
      
    }
  }
  
  Future<void> removeRecentSearch(String searchTerm) async {
    try {
      final recentSearches = getRecentSearches();
      recentSearches.removeWhere((term) => term == searchTerm);
      
      await sharedPreferences.setStringList(
        AppConstants.recentSearchesKey,
        recentSearches,
      );
    } catch (e) {
      debugPrint('Failed to remove recent search: $e');
      
    }
  }
  
  List<String> getRecentSearches() {
    try {
      return sharedPreferences.getStringList(AppConstants.recentSearchesKey) ?? [];
    } catch (e) {
      debugPrint('Error getting recent searches: $e');
      return [];
    }
  }
  
  Future<void> clearRecentSearches() async {
    try {
      await sharedPreferences.remove(AppConstants.recentSearchesKey);
    } catch (e) {
      debugPrint('Failed to clear recent searches: $e');
    }
  }
}