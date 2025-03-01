import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_sharing_application/api/imgur_api_client.dart';
import 'package:image_sharing_application/models/imgur_image.dart';
import 'package:image_sharing_application/repositories/imgur_repository.dart';
import 'package:image_sharing_application/utils/constants.dart';
import 'dart:convert';

// Simple mock classes
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockImgurApiClient extends Mock implements ImgurApiClient {}

void main() {
  late MockImgurApiClient mockApiClient;
  late MockSharedPreferences mockSharedPreferences;
  late ImgurRepository repository;
  
  final testImage = ImgurImage(
    id: 'test123',
    title: 'Test Image',
    description: 'A test image',
    datetime: 1612345678,
    link: 'https://i.imgur.com/test123.jpg',
  );
  
  setUp(() {
    mockApiClient = MockImgurApiClient();
    mockSharedPreferences = MockSharedPreferences();
    repository = ImgurRepository(
      apiClient: mockApiClient,
      sharedPreferences: mockSharedPreferences,
    );
  });
  
  group('ImgurRepository - Favorites Storage', () {
    test('addToFavorites uses SharedPreferences to store favorites', () async {
      // Arrange
      when(mockSharedPreferences.getString(AppConstants.favoriteImagesKey))
          .thenReturn(null);
      when(mockSharedPreferences.setString(
        argThat(equals(AppConstants.favoriteImagesKey)), 
        argThat(isA<String>())
      )).thenAnswer((_) async => true);
      
      // Act
      await repository.addToFavorites(testImage);
      
      // Assert
      verify(mockSharedPreferences.getString(AppConstants.favoriteImagesKey)).called(1);
      verify(mockSharedPreferences.setString(
        argThat(equals(AppConstants.favoriteImagesKey)), 
        argThat(isA<String>())
      )).called(1);
    });
    
    test('getFavoriteImages retrieves from SharedPreferences', () {
      // Arrange
      final jsonImage = {
        'id': 'test123',
        'title': 'Test Image',
        'description': 'A test image',
        'datetime': 1612345678,
        'link': 'https://i.imgur.com/test123.jpg',
        'animated': false,
      };
      
      when(mockSharedPreferences.getString(AppConstants.favoriteImagesKey))
          .thenReturn(jsonEncode([jsonImage]));
      
      // Act
      final result = repository.getFavoriteImages();
      
      // Assert
      expect(result.length, 1);
      expect(result[0].id, 'test123');
      expect(result[0].link, 'https://i.imgur.com/test123.jpg');
      verify(mockSharedPreferences.getString(AppConstants.favoriteImagesKey)).called(1);
    });
  });
  
  group('ImgurRepository - Recent Searches Storage', () {
    test('addRecentSearch stores search term in SharedPreferences', () async {
      // Arrange
      when(mockSharedPreferences.getStringList(AppConstants.recentSearchesKey))
          .thenReturn(['cats']);
      when(mockSharedPreferences.setStringList(
        argThat(equals(AppConstants.recentSearchesKey)), 
        argThat(isA<List<String>>())
      )).thenAnswer((_) async => true);
      
      // Act
      await repository.addRecentSearch('dogs');
      
      // Assert
      verify(mockSharedPreferences.getStringList(AppConstants.recentSearchesKey)).called(1);
      verify(mockSharedPreferences.setStringList(
        argThat(equals(AppConstants.recentSearchesKey)), 
        argThat(isA<List<String>>())
      )).called(1);
    });
    
    test('getRecentSearches retrieves from SharedPreferences', () {
      // Arrange
      when(mockSharedPreferences.getStringList(AppConstants.recentSearchesKey))
          .thenReturn(['cats', 'dogs', 'birds']);
      
      // Act
      final result = repository.getRecentSearches();
      
      // Assert
      expect(result.length, 3);
      expect(result, contains('cats'));
      expect(result, contains('dogs'));
      expect(result, contains('birds'));
      verify(mockSharedPreferences.getStringList(AppConstants.recentSearchesKey)).called(1);
    });
    
    test('clearRecentSearches uses SharedPreferences to clear searches', () async {
      // Arrange
      when(mockSharedPreferences.remove(AppConstants.recentSearchesKey))
          .thenAnswer((_) async => true);
      
      // Act
      await repository.clearRecentSearches();
      
      // Assert
      verify(mockSharedPreferences.remove(AppConstants.recentSearchesKey)).called(1);
    });
  });
} 