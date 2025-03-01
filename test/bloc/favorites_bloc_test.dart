import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:image_sharing_application/repositories/imgur_repository.dart';
import 'package:image_sharing_application/bloc/favorites/favorites_bloc.dart';
import 'package:image_sharing_application/bloc/favorites/favorites_event.dart';
import 'package:image_sharing_application/bloc/favorites/favorites_state.dart';
import 'package:image_sharing_application/models/imgur_image.dart';

@GenerateMocks([ImgurRepository])
import 'favorites_bloc_test.mocks.dart';

void main() {
  late MockImgurRepository mockRepository;
  late FavoritesBloc favoritesBloc;
  
  setUp(() {
    mockRepository = MockImgurRepository();
    favoritesBloc = FavoritesBloc(repository: mockRepository);
  });
  
  tearDown(() {
    favoritesBloc.close();
  });
  
  final testImage = ImgurImage(
    id: 'test123',
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
    link: 'https://i.imgur.com/test123.jpg',
    animated: false,
  );
  
  test('initial state should be empty FavoritesState', () {
    // Verify initial state properties
    expect(favoritesBloc.state.status, equals(FavoritesStatus.initial));
    expect(favoritesBloc.state.favoriteImages, isEmpty);
    expect(favoritesBloc.state.error, isNull);
  });
  
  blocTest<FavoritesBloc, FavoritesState>(
    'emits [loading, loaded] when LoadFavorites is added and successful',
    build: () {
      when(mockRepository.getFavoriteImages())
          .thenReturn([testImage]);
      return favoritesBloc;
    },
    act: (bloc) => bloc.add(LoadFavorites()),
    expect: () => [
      FavoritesState(status: FavoritesStatus.loading, favoriteImages: const [], error: null),
      FavoritesState(status: FavoritesStatus.loaded, favoriteImages: [testImage], error: null),
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
      const FavoritesState(status: FavoritesStatus.loading),
      const FavoritesState(
        status: FavoritesStatus.error,
        error: 'Exception: Failed to load favorites',
      ),
    ],
    verify: (_) {
      verify(mockRepository.getFavoriteImages()).called(1);
    },
  );
  
  blocTest<FavoritesBloc, FavoritesState>(
    'emits updated state when AddToFavorites is added',
    build: () {
      when(mockRepository.addToFavorites(testImage)).thenAnswer((_) async => true);
      when(mockRepository.getFavoriteImages()).thenReturn([testImage]);
      return favoritesBloc;
    },
    act: (bloc) => bloc.add(AddToFavorites(testImage)),
    expect: () => [
      FavoritesState(
        status: FavoritesStatus.loaded,
        favoriteImages: [testImage],
      ),
    ],
    verify: (_) {
      verify(mockRepository.addToFavorites(testImage)).called(1);
      verify(mockRepository.getFavoriteImages()).called(1);
    },
  );
  
  blocTest<FavoritesBloc, FavoritesState>(
    'emits updated state when RemoveFromFavorites is added',
    build: () {
      when(mockRepository.removeFromFavorites('test123')).thenAnswer((_) async => true);
      when(mockRepository.getFavoriteImages()).thenReturn([]);
      return favoritesBloc;
    },
    act: (bloc) => bloc.add(const RemoveFromFavorites('test123')),
    expect: () => [
      const FavoritesState(
        status: FavoritesStatus.loaded,
        favoriteImages: [],
      ),
    ],
    verify: (_) {
      verify(mockRepository.removeFromFavorites('test123')).called(1);
      verify(mockRepository.getFavoriteImages()).called(1);
    },
  );
} 