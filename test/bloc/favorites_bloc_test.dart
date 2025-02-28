import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:image_sharing_application/bloc/favorites/favorites_bloc.dart';
import 'package:image_sharing_application/bloc/favorites/favorites_event.dart';
import 'package:image_sharing_application/bloc/favorites/favorites_state.dart';
import 'package:image_sharing_application/models/imgur_image.dart';
import 'package:image_sharing_application/repositories/imgur_repository.dart';

// Generate mock classes
@GenerateMocks([ImgurRepository])
import 'favorites_bloc_test.mocks.dart';

void main() {
  late MockImgurRepository mockRepository;
  late FavoritesBloc favoritesBloc;
  
  final testImage = ImgurImage(
    id: 'test123',
    title: 'Test Image',
    description: 'A test image',
    datetime: 1612345678,
    type: 'image/jpeg',
    animated: false,
    width: 800,
    height: 600,
    size: 123456,
    views: 1000,
    bandwidth: 123456000,
    vote: null,
    section: null,
    accountUrl: null,
    accountId: null,
    isAd: false,
    inMostViral: false,
    hasSound: false,
    tags: [],
    adType: 0,
    adUrl: '',
    edited: 0,
    inGallery: false,
    link: 'https://i.imgur.com/test123.jpg',
    mp4: null,
    gifv: null,
    mp4Size: null,
    looping: false,
    processing: null,
    commentCount: null,
    favoriteCount: null,
    ups: null,
    downs: null,
    points: null,
    score: null,
  );
  
  setUp(() {
    mockRepository = MockImgurRepository();
    favoritesBloc = FavoritesBloc(repository: mockRepository);
  });
  
  tearDown(() {
    favoritesBloc.close();
  });
  
  test('initial state should be FavoritesState.initial()', () {
    // Assert
    expect(favoritesBloc.state, equals(FavoritesState.initial()));
  });
  
  blocTest<FavoritesBloc, FavoritesState>(
    'emits [loading, loaded] when LoadFavorites is added',
    build: () {
      when(mockRepository.getFavoriteImages())
          .thenAnswer((_) async => [testImage]);
      return favoritesBloc;
    },
    act: (bloc) => bloc.add(LoadFavorites()),
    expect: () => [
      FavoritesState(
        status: FavoritesStatus.loading,
        favoriteImages: [],
        error: null,
      ),
      FavoritesState(
        status: FavoritesStatus.loaded,
        favoriteImages: [testImage],
        error: null,
      ),
    ],
    verify: (_) {
      verify(mockRepository.getFavoriteImages()).called(1);
    },
  );
  
  blocTest<FavoritesBloc, FavoritesState>(
    'emits [loading, error] when LoadFavorites fails',
    build: () {
      when(mockRepository.getFavoriteImages())
          .thenThrow(Exception('Failed to load favorites'));
      return favoritesBloc;
    },
    act: (bloc) => bloc.add(LoadFavorites()),
    expect: () => [
      FavoritesState(
        status: FavoritesStatus.loading,
        favoriteImages: [],
        error: null,
      ),
      FavoritesState(
        status: FavoritesStatus.error,
        favoriteImages: [],
        error: 'Failed to load favorites',
      ),
    ],
    verify: (_) {
      verify(mockRepository.getFavoriteImages()).called(1);
    },
  );
  
  blocTest<FavoritesBloc, FavoritesState>(
    'emits updated state when AddToFavorites is added',
    build: () {
      when(mockRepository.addImageToFavorites(testImage))
          .thenAnswer((_) async => true);
      return favoritesBloc;
    },
    seed: () => FavoritesState(
      status: FavoritesStatus.loaded,
      favoriteImages: [],
      error: null,
    ),
    act: (bloc) => bloc.add(AddToFavorites(testImage)),
    expect: () => [
      FavoritesState(
        status: FavoritesStatus.loaded,
        favoriteImages: [testImage],
        error: null,
      ),
    ],
    verify: (_) {
      verify(mockRepository.addImageToFavorites(testImage)).called(1);
    },
  );
  
  blocTest<FavoritesBloc, FavoritesState>(
    'emits updated state when RemoveFromFavorites is added',
    build: () {
      when(mockRepository.removeImageFromFavorites(testImage.id))
          .thenAnswer((_) async => true);
      return favoritesBloc;
    },
    seed: () => FavoritesState(
      status: FavoritesStatus.loaded,
      favoriteImages: [testImage],
      error: null,
    ),
    act: (bloc) => bloc.add(RemoveFromFavorites(testImage.id)),
    expect: () => [
      FavoritesState(
        status: FavoritesStatus.loaded,
        favoriteImages: [],
        error: null,
      ),
    ],
    verify: (_) {
      verify(mockRepository.removeImageFromFavorites(testImage.id)).called(1);
    },
  );
} 