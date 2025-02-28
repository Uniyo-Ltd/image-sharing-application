import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ImgurApiClient {
  final http.Client _httpClient;
  
  ImgurApiClient({http.Client? httpClient}) 
      : _httpClient = httpClient ?? http.Client();
  
  // Fetch gallery images
  Future<Map<String, dynamic>> getGalleryImages({
    String section = 'hot',
    String sort = 'viral',
    int page = 0,
    String window = 'day',
  }) async {
    final Uri url = Uri.parse(
      '${AppConstants.imgurApiBaseUrl}/gallery/$section/$sort/$window/$page'
    );
    
    return _getRequest(url);
  }
  
  // Search for images
  Future<Map<String, dynamic>> searchImages({
    required String query,
    String sort = 'viral',
    int page = 0,
    String window = 'all',
  }) async {
    final Uri url = Uri.parse(
      '${AppConstants.imgurApiBaseUrl}/gallery/search/$sort/$window/$page?q=$query'
    );
    
    return _getRequest(url);
  }
  
  // Get image details
  Future<Map<String, dynamic>> getImageDetails(String imageId) async {
    final Uri url = Uri.parse('${AppConstants.imgurApiBaseUrl}/image/$imageId');
    
    return _getRequest(url);
  }
  
  // Get album details
  Future<Map<String, dynamic>> getAlbumDetails(String albumId) async {
    final Uri url = Uri.parse('${AppConstants.imgurApiBaseUrl}/album/$albumId');
    
    return _getRequest(url);
  }
  
  // Helper method for GET requests
  Future<Map<String, dynamic>> _getRequest(Uri url) async {
    final response = await _httpClient.get(
      url,
      headers: {
        'Authorization': 'Client-ID ${AppConstants.clientId}',
      },
    );
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'API request failed with status code: ${response.statusCode}'
      );
    }
  }
} 