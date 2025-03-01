import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:image_sharing_application/api/imgur_api_client.dart';
import 'package:image_sharing_application/utils/constants.dart';

@GenerateMocks([http.Client])
import 'imgur_api_client_test.mocks.dart';

void main() {
  group('ImgurApiClient', () {
    
    test('can be instantiated', () {
      expect(ImgurApiClient(), isNotNull);
    });
    
    group('getGalleryImages', () {
      late MockClient mockClient;
      late ImgurApiClient apiClient;
      
      setUp(() {
        mockClient = MockClient();
        apiClient = ImgurApiClient(httpClient: mockClient);
      });
      
      test('returns gallery images when the call is successful', () async {
        // Arrange
        final galleryResponse = {
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
                  'datetime': 1612345678,
                  'type': 'image/jpeg',
                  'animated': false,
                  'width': 800,
                  'height': 600,
                  'size': 123456,
                  'views': 1000,
                  'bandwidth': 123456000,
                  'vote': null,
                  'section': null,
                  'account_url': 'testuser',
                  'account_id': 12345,
                  'is_ad': false,
                  'in_most_viral': false,
                  'has_sound': false,
                  'tags': [],
                  'ad_type': 0,
                  'ad_url': '',
                  'edited': 0,
                  'in_gallery': true,
                  'link': 'https://i.imgur.com/def456.jpg',
                  'mp4': null,
                  'gifv': null,
                  'mp4_size': null,
                  'looping': false,
                  'processing': null,
                  'comment_count': null,
                  'favorite_count': null,
                  'ups': null,
                  'downs': null,
                  'points': null,
                  'score': null,
                }
              ],
              'images_count': 1,
              'link': 'https://imgur.com/a/abc123',
            }
          ],
          'success': true,
          'status': 200,
        };
        
        final url = Uri.parse('${AppConstants.imgurApiBaseUrl}/gallery/hot/viral/day/0');
        
        when(mockClient.get(
          url,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => 
          http.Response(jsonEncode(galleryResponse), 200)
        );
        
        // Act
        final result = await apiClient.getGalleryImages();
        
        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['success'], isTrue);
        expect(result['data'], isA<List>());
        expect(result['data'].length, 1);
        expect(result['data'][0]['id'], 'abc123');
        verify(mockClient.get(url, headers: anyNamed('headers'))).called(1);
      });
      
      test('throws an exception when the call fails', () async {
        // Arrange
        final url = Uri.parse('${AppConstants.imgurApiBaseUrl}/gallery/hot/viral/day/0');
        
        when(mockClient.get(
          url,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => 
          http.Response('Not found', 404)
        );
        
        // Act & Assert
        expect(
          () => apiClient.getGalleryImages(),
          throwsA(isA<Exception>()),
        );
        verify(mockClient.get(url, headers: anyNamed('headers'))).called(1);
      });
    });
    
    group('searchImages', () {
      late MockClient mockClient;
      late ImgurApiClient apiClient;
      
      setUp(() {
        mockClient = MockClient();
        apiClient = ImgurApiClient(httpClient: mockClient);
      });
      
      test('returns search results when the call is successful', () async {
        // Arrange
        final searchQuery = 'cats';
        final searchResponse = {
          'data': [
            {
              'id': 'xyz789',
              'title': 'Search Result',
              'description': 'A cat image',
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
                  'title': 'Cat Image',
                  'description': 'A cute cat',
                  'link': 'https://i.imgur.com/ghi789.jpg',
                }
              ],
              'images_count': 1,
              'link': 'https://imgur.com/a/xyz789',
            }
          ],
          'success': true,
          'status': 200,
        };
        
        final url = Uri.parse('${AppConstants.imgurApiBaseUrl}/gallery/search/viral/all/0?q=$searchQuery');
        
        when(mockClient.get(
          url,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => 
          http.Response(jsonEncode(searchResponse), 200)
        );
        
        // Act
        final result = await apiClient.searchImages(query: searchQuery);
        
        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['success'], isTrue);
        expect(result['data'], isA<List>());
        expect(result['data'].length, 1);
        expect(result['data'][0]['id'], 'xyz789');
        expect(result['data'][0]['title'], 'Search Result');
        verify(mockClient.get(url, headers: anyNamed('headers'))).called(1);
      });
      
      test('throws an exception when the call fails', () async {
        // Arrange
        final searchQuery = 'invalid';
        final url = Uri.parse('${AppConstants.imgurApiBaseUrl}/gallery/search/viral/all/0?q=$searchQuery');
        
        when(mockClient.get(
          url,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => 
          http.Response('Not found', 404)
        );
        
        // Act & Assert
        expect(
          () => apiClient.searchImages(query: searchQuery),
          throwsA(isA<Exception>()),
        );
        verify(mockClient.get(url, headers: anyNamed('headers'))).called(1);
      });
    });
    
    group('getImageDetails', () {
      late MockClient mockClient;
      late ImgurApiClient apiClient;
      
      setUp(() {
        mockClient = MockClient();
        apiClient = ImgurApiClient(httpClient: mockClient);
      });
      
      test('returns image details when the call is successful', () async {
        // Arrange
        final imageId = 'def456';
        final imageResponse = {
          'data': {
            'id': imageId,
            'title': 'Test Image',
            'description': 'A test image',
            'datetime': 1612345678,
            'type': 'image/jpeg',
            'animated': false,
            'width': 800,
            'height': 600,
            'size': 123456,
            'views': 1000,
            'bandwidth': 123456000,
            'vote': null,
            'section': null,
            'account_url': 'testuser',
            'account_id': 12345,
            'is_ad': false,
            'in_most_viral': false,
            'has_sound': false,
            'tags': [],
            'ad_type': 0,
            'ad_url': '',
            'edited': 0,
            'in_gallery': true,
            'link': 'https://i.imgur.com/def456.jpg',
          },
          'success': true,
          'status': 200,
        };
        
        final url = Uri.parse('${AppConstants.imgurApiBaseUrl}/image/$imageId');
        
        when(mockClient.get(
          url,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => 
          http.Response(jsonEncode(imageResponse), 200)
        );
        
        // Act
        final result = await apiClient.getImageDetails(imageId);
        
        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['success'], isTrue);
        expect(result['data'], isA<Map<String, dynamic>>());
        expect(result['data']['id'], imageId);
        expect(result['data']['title'], 'Test Image');
        expect(result['data']['link'], 'https://i.imgur.com/def456.jpg');
        verify(mockClient.get(url, headers: anyNamed('headers'))).called(1);
      });
      
      test('throws an exception when the call fails', () async {
        // Arrange
        final imageId = 'invalid';
        final url = Uri.parse('${AppConstants.imgurApiBaseUrl}/image/$imageId');
        
        when(mockClient.get(
          url,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => 
          http.Response('Not found', 404)
        );
        
        // Act & Assert
        expect(
          () => apiClient.getImageDetails(imageId),
          throwsA(isA<Exception>()),
        );
        verify(mockClient.get(url, headers: anyNamed('headers'))).called(1);
      });
    });
    
    group('getAlbumDetails', () {
      late MockClient mockClient;
      late ImgurApiClient apiClient;
      
      setUp(() {
        mockClient = MockClient();
        apiClient = ImgurApiClient(httpClient: mockClient);
      });
      
      test('returns album details when the call is successful', () async {
        // Arrange
        final albumId = 'abc123';
        final albumResponse = {
          'data': {
            'id': albumId,
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
              },
              {
                'id': 'ghi789',
                'title': 'Second Image',
                'description': 'Second image in album',
                'link': 'https://i.imgur.com/ghi789.jpg',
              }
            ],
            'images_count': 2,
            'link': 'https://imgur.com/a/abc123',
          },
          'success': true,
          'status': 200,
        };
        
        final url = Uri.parse('${AppConstants.imgurApiBaseUrl}/album/$albumId');
        
        when(mockClient.get(
          url,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => 
          http.Response(jsonEncode(albumResponse), 200)
        );
        
        // Act
        final result = await apiClient.getAlbumDetails(albumId);
        
        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['success'], isTrue);
        expect(result['data'], isA<Map<String, dynamic>>());
        expect(result['data']['id'], albumId);
        expect(result['data']['title'], 'Test Album');
        expect(result['data']['images'], isA<List>());
        expect(result['data']['images'].length, 2);
        expect(result['data']['images'][0]['id'], 'def456');
        expect(result['data']['images'][1]['id'], 'ghi789');
        verify(mockClient.get(url, headers: anyNamed('headers'))).called(1);
      });
      
      test('throws an exception when the call fails', () async {
        // Arrange
        final albumId = 'invalid';
        final url = Uri.parse('${AppConstants.imgurApiBaseUrl}/album/$albumId');
        
        when(mockClient.get(
          url,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => 
          http.Response('Not found', 404)
        );
        
        // Act & Assert
        expect(
          () => apiClient.getAlbumDetails(albumId),
          throwsA(isA<Exception>()),
        );
        verify(mockClient.get(url, headers: anyNamed('headers'))).called(1);
      });
    });
  });
} 