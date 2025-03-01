class AppConstants {
  // Imgur API
  static const String imgurApiBaseUrl = 'https://api.imgur.com/3';
  static const String clientId = 'e867d4c068baf94'; // Replace with your actual Imgur API client ID
  static const String clientSecret = '8a55433c43f5b93e3bde1807514acc42b760091c';
  static const String accessToken = '0d06782d0b2fc189806bf3c232c9861cabf2dda6';
  static const String refreshToken = '154173f8d09031ffa198fefdcab2e167ae28343c';
  
  // Default parameters
  static const int defaultPageSize = 20;
  
  // Local storage keys
  static const String favoriteImagesKey = 'favorite_images';
  static const String recentSearchesKey = 'recent_searches';
  
  // Error messages
  static const String networkErrorMessage = 'Network error. Please check your connection and try again.';
  static const String genericErrorMessage = 'Something went wrong. Please try again later.';
} 