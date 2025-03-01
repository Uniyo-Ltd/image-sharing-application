import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_sharing_application/api/imgur_api_client.dart';
import 'package:image_sharing_application/models/imgur_gallery_item.dart';
import 'package:image_sharing_application/models/imgur_image.dart';
import 'package:image_sharing_application/repositories/imgur_repository.dart';
import 'package:image_sharing_application/utils/constants.dart';

@GenerateMocks([ImgurApiClient, SharedPreferences])
import 'imgur_repository_test.mocks.dart';

void main() {
  late MockImgurApiClient mockApiClient;
  late MockSharedPreferences mockSharedPreferences;
  late ImgurRepository repository;

  setUp(() {
    mockApiClient = MockImgurApiClient();
    mockSharedPreferences = MockSharedPreferences();
    repository = ImgurRepository(
      apiClient: mockApiClient,
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('getGalleryImages', () {
    final testGalleryResponse = {
      'data': [
        {
          'id': 'abc123',
          'title': 'Test Gallery Item',
          'description': 'Test description',
          'datetime': 1612345678,
          'cover': 'def456',
          'cover_width': 800,
          'cover_height': 600,
          'account_url': 'testuser',
          'account_id': 12345,
          'views': 1000,
          'ups': 50,
          'downs': 5,
          'points': 45,
          'score': 45,
          'comment_count': 10,
          'is_album': true,
          'images': [
            {
              'id': 'def456',
              'title': 'Test Image',
              'description': 'Test image description',
              'link': 'https://i.imgur.com/def456.jpg',
              'width': 800,
              'height': 600,
            }
          ],
          'images_count': 1,
          'link': 'https://imgur.com/a/abc123',
          'nsfw': false,
        }
      ],
      'success': true,
      'status': 200,
    };

    test('returns list of gallery items when API call is successful', () async {
      // Arrange
      when(mockApiClient.getGalleryImages(
        section: 'hot',
        sort: 'viral',
        window: 'day',
        page: 0,
      )).thenAnswer((_) async => testGalleryResponse);

      // Act
      final result = await repository.getGalleryImages();

      // Assert
      expect(result, isA<List<ImgurGalleryItem>>());
      expect(result.length, 1);
      expect(result[0].id, 'abc123');
      expect(result[0].title, 'Test Gallery Item');
      expect(result[0].link, 'https://imgur.com/a/abc123');
      expect(result[0].images?.length, 1);
      expect(result[0].images?[0].id, 'def456');
      expect(result[0].images?[0].link, 'https://i.imgur.com/def456.jpg');
      verify(mockApiClient.getGalleryImages(
        section: 'hot',
        sort: 'viral',
        window: 'day',
        page: 0,
      )).called(1);
    });

    test('returns empty list when API call fails', () async {
      // Arrange
      when(mockApiClient.getGalleryImages(
        section: 'hot',
        sort: 'viral',
        window: 'day',
        page: 0,
      )).thenThrow(Exception('API error'));

      // Act & Assert
      expect(
        () => repository.getGalleryImages(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('searchGalleryImages', () {
    final testSearchResponse = {
      'data': [
        {
          'id': 'xyz789',
          'title': 'Search Result',
          'description': 'A search result',
          'datetime': 1612345678,
          'cover': 'ghi789',
          'cover_width': 800,
          'cover_height': 600,
          'account_url': 'testuser',
          'account_id': 12345,
          'views': 1000,
          'ups': 50,
          'downs': 5,
          'points': 45,
          'score': 45,
          'comment_count': 10,
          'is_album': true,
          'images': [
            {
              'id': 'ghi789',
              'title': 'Search Image',
              'description': 'A search image',
              'link': 'https://i.imgur.com/ghi789.jpg',
              'width': 800,
              'height': 600,
            }
          ],
          'images_count': 1,
          'link': 'https://imgur.com/a/xyz789',
          'nsfw': false,
        }
      ],
      'success': true,
      'status': 200,
    };

    test('returns list of gallery items when search is successful', () async {
      // Arrange
      final searchQuery = 'cats';
      when(mockApiClient.searchImages(
        query: searchQuery,
        sort: 'viral',
        window: 'all',
        page: 0,
      )).thenAnswer((_) async => testSearchResponse);

      // Act
      final result = await repository.searchGalleryImages(query: searchQuery);

      // Assert
      expect(result, isA<List<ImgurGalleryItem>>());
      expect(result.length, 1);
      expect(result[0].id, 'xyz789');
      expect(result[0].title, 'Search Result');
      expect(result[0].link, 'https://imgur.com/a/xyz789');
      verify(mockApiClient.searchImages(
        query: searchQuery,
        sort: 'viral',
        window: 'all',
        page: 0,
      )).called(1);
    });

    test('throws exception when search fails', () async {
      // Arrange
      final searchQuery = 'invalid';
      when(mockApiClient.searchImages(
        query: searchQuery,
        sort: 'viral',
        window: 'all',
        page: 0,
      )).thenThrow(Exception('API error'));

      // Act & Assert
      expect(
        () => repository.searchGalleryImages(query: searchQuery),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getImageDetails', () {
    final testImageResponse = {
      'data': {
        'id': 'def456',
        'title': 'Test Image',
        'description': 'A test image',
        'datetime': 1612345678,
        'type': 'image/jpeg',
        'animated': false,
        'width': 800,
        'height': 600,
        'size': 123456,
        'views': 1000,
        'link': 'https://i.imgur.com/def456.jpg',
      },
      'success': true,
      'status': 200,
    };

    test('returns image details when API call is successful', () async {
      // Arrange
      final imageId = 'def456';
      when(mockApiClient.getImageDetails(imageId))
          .thenAnswer((_) async => testImageResponse);

      // Act
      final result = await repository.getImageDetails(imageId);

      // Assert
      expect(result, isA<ImgurImage>());
      expect(result.id, 'def456');
      expect(result.title, 'Test Image');
      expect(result.link, 'https://i.imgur.com/def456.jpg');
      verify(mockApiClient.getImageDetails(imageId)).called(1);
    });

    test('throws exception when API call fails', () async {
      // Arrange
      final imageId = 'invalid';
      when(mockApiClient.getImageDetails(imageId))
          .thenThrow(Exception('API error'));

      // Act & Assert
      expect(
        () => repository.getImageDetails(imageId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getAlbumDetails', () {
    final testAlbumResponse = {
      'data': {
        'id': 'abc123',
        'title': 'Test Album',
        'description': 'A test album',
        'datetime': 1612345678,
        'cover': 'def456',
        'cover_width': 800,
        'cover_height': 600,
        'account_url': 'testuser',
        'account_id': 12345,
        'views': 1000,
        'ups': 50,
        'downs': 5,
        'points': 45,
        'score': 45,
        'comment_count': 10,
        'images': [
          {
            'id': 'def456',
            'title': 'First Image',
            'description': 'First image in album',
            'link': 'https://i.imgur.com/def456.jpg',
            'width': 800,
            'height': 600,
          },
          {
            'id': 'ghi789',
            'title': 'Second Image',
            'description': 'Second image in album',
            'link': 'https://i.imgur.com/ghi789.jpg',
            'width': 800,
            'height': 600,
          }
        ],
        'images_count': 2,
        'link': 'https://imgur.com/a/abc123',
        'nsfw': false,
      },
      'success': true,
      'status': 200,
    };

    test('returns album details when API call is successful', () async {
      // Arrange
      final albumId = 'abc123';
      when(mockApiClient.getAlbumDetails(albumId))
          .thenAnswer((_) async => testAlbumResponse);

      // Act
      final result = await repository.getAlbumDetails(albumId);

      // Assert
      expect(result, isA<ImgurGalleryItem>());
      expect(result.id, 'abc123');
      expect(result.title, 'Test Album');
      expect(result.link, 'https://imgur.com/a/abc123');
      expect(result.images?.length, 2);
      expect(result.images?[0].id, 'def456');
      expect(result.images?[1].id, 'ghi789');
      verify(mockApiClient.getAlbumDetails(albumId)).called(1);
    });

    test('throws exception when API call fails', () async {
      // Arrange
      final albumId = 'invalid';
      when(mockApiClient.getAlbumDetails(albumId))
          .thenThrow(Exception('API error'));

      // Act & Assert
      expect(
        () => repository.getAlbumDetails(albumId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Favorites operations', () {
    final testImage = ImgurImage(
      id: 'def456',
      title: 'Test Image',
      description: 'A test image',
      datetime: 1612345678,
      accountUrl: 'testuser',
      accountId: '12345',
      width: 800,
      height: 600,
      size: 123456,
      views: 1000,
      score: 45,
      commentCount: 10,
      points: 45,
      link: 'https://i.imgur.com/def456.jpg',
      animated: false,
    );

    final testImageJson = {
      'id': 'def456',
      'title': 'Test Image',
      'description': 'A test image',
      'datetime': 1612345678,
      'account_url': 'testuser',
      'account_id': '12345',
      'width': 800,
      'height': 600,
      'size': 123456,
      'views': 1000,
      'score': 45,
      'comment_count': 10,
      'points': 45,
      'link': 'https://i.imgur.com/def456.jpg',
      'animated': false,
    };

    test('getFavoriteImages returns empty list when no favorites exist', () {
      // Arrange
      when(mockSharedPreferences.getString(AppConstants.favoriteImagesKey))
          .thenReturn(null);

      // Act
      final result = repository.getFavoriteImages();

      // Assert
      expect(result, isA<List<ImgurImage>>());
      expect(result.isEmpty, true);
    });

    test('getFavoriteImages returns list of favorites when they exist', () {
      // Arrange
      when(mockSharedPreferences.getString(AppConstants.favoriteImagesKey))
          .thenReturn(jsonEncode([testImageJson]));

      // Act
      final result = repository.getFavoriteImages();

      // Assert
      expect(result, isA<List<ImgurImage>>());
      expect(result.length, 1);
      expect(result[0].id, 'def456');
      expect(result[0].title, 'Test Image');
      expect(result[0].link, 'https://i.imgur.com/def456.jpg');
    });

    test('addToFavorites adds image to favorites', () async {
      // Arrange
      when(mockSharedPreferences.getString(AppConstants.favoriteImagesKey))
          .thenReturn(null);
      when(mockSharedPreferences.setString(
        AppConstants.favoriteImagesKey,
        any,
      )).thenAnswer((_) async => true);

      // Act
      await repository.addToFavorites(testImage);

      // Assert
      verify(mockSharedPreferences.setString(
        AppConstants.favoriteImagesKey,
        any,
      )).called(1);
    });

    test('addToFavorites does not add duplicate image', () async {
      // Arrange
      when(mockSharedPreferences.getString(AppConstants.favoriteImagesKey))
          .thenReturn(jsonEncode([testImageJson]));

      // Act
      await repository.addToFavorites(testImage);

      // Assert
      verifyNever(mockSharedPreferences.setString(
        AppConstants.favoriteImagesKey,
        any,
      ));
    });

    test('removeFromFavorites removes image from favorites', () async {
      // Arrange
      when(mockSharedPreferences.getString(AppConstants.favoriteImagesKey))
          .thenReturn(jsonEncode([testImageJson]));
      when(mockSharedPreferences.setString(
        AppConstants.favoriteImagesKey,
        any,
      )).thenAnswer((_) async => true);

      // Act
      await repository.removeFromFavorites(testImage.id);

      // Assert
      verify(mockSharedPreferences.setString(
        AppConstants.favoriteImagesKey,
        any,
      )).called(1);
    });
  });

  group('Recent searches operations', () {
    test('getRecentSearches returns empty list when no searches exist', () {
      // Arrange
      when(mockSharedPreferences.getStringList(AppConstants.recentSearchesKey))
          .thenReturn(null);

      // Act
      final result = repository.getRecentSearches();

      // Assert
      expect(result, isA<List<String>>());
      expect(result.isEmpty, true);
    });

    test('getRecentSearches returns list of searches when they exist', () {
      // Arrange
      final testSearches = ['cats', 'dogs', 'birds'];
      when(mockSharedPreferences.getStringList(AppConstants.recentSearchesKey))
          .thenReturn(testSearches);

      // Act
      final result = repository.getRecentSearches();

      // Assert
      expect(result, isA<List<String>>());
      expect(result.length, 3);
      expect(result, testSearches);
    });

    test('addRecentSearch adds search term to recent searches', () async {
      // Arrange
      final testSearches = ['dogs', 'birds'];
      when(mockSharedPreferences.getStringList(AppConstants.recentSearchesKey))
          .thenReturn(testSearches);
      when(mockSharedPreferences.setStringList(
        AppConstants.recentSearchesKey,
        any,
      )).thenAnswer((_) async => true);

      // Act
      await repository.addRecentSearch('cats');

      // Assert
      verify(mockSharedPreferences.setStringList(
        AppConstants.recentSearchesKey,
        ['cats', 'dogs', 'birds'],
      )).called(1);
    });

    test('addRecentSearch moves existing term to front of list', () async {
      // Arrange
      final testSearches = ['cats', 'dogs', 'birds'];
      when(mockSharedPreferences.getStringList(AppConstants.recentSearchesKey))
          .thenReturn(testSearches);
      when(mockSharedPreferences.setStringList(
        AppConstants.recentSearchesKey,
        any,
      )).thenAnswer((_) async => true);

      // Act
      await repository.addRecentSearch('dogs');

      // Assert
      verify(mockSharedPreferences.setStringList(
        AppConstants.recentSearchesKey,
        ['dogs', 'cats', 'birds'],
      )).called(1);
    });

    test('removeRecentSearch removes search term from recent searches', () async {
      // Arrange
      final testSearches = ['cats', 'dogs', 'birds'];
      when(mockSharedPreferences.getStringList(AppConstants.recentSearchesKey))
          .thenReturn(testSearches);
      when(mockSharedPreferences.setStringList(
        AppConstants.recentSearchesKey,
        any,
      )).thenAnswer((_) async => true);

      // Act
      await repository.removeRecentSearch('dogs');

      // Assert
      verify(mockSharedPreferences.setStringList(
        AppConstants.recentSearchesKey,
        ['cats', 'birds'],
      )).called(1);
    });

    test('clearRecentSearches clears all recent searches', () async {
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