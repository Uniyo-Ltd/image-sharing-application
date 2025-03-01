import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:image_sharing_application/repositories/imgur_repository.dart';
import 'package:image_sharing_application/bloc/gallery/gallery_bloc.dart';
import 'package:image_sharing_application/bloc/gallery/gallery_event.dart';
import 'package:image_sharing_application/bloc/gallery/gallery_state.dart';
import 'package:image_sharing_application/models/imgur_gallery_item.dart';
import 'package:image_sharing_application/models/imgur_image.dart';

@GenerateMocks([ImgurRepository])
import 'gallery_bloc_test.mocks.dart';

void main() {
  late MockImgurRepository mockRepository;
  late GalleryBloc galleryBloc;

  setUp(() {
    mockRepository = MockImgurRepository();
    galleryBloc = GalleryBloc(repository: mockRepository);
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

  final testGalleryItem = ImgurGalleryItem(
    id: 'gallery123',
    title: 'Test Gallery Item',
    description: 'A test gallery item',
    datetime: 1612345678,
    cover: 'test123',
    coverWidth: 800,
    coverHeight: 600,
    isAlbum: true,
    imagesCount: 1,
    views: 1000,
    score: 45,
    commentCount: 10,
    points: 45,
    link: 'https://imgur.com/a/gallery123',
    images: [testImage],
    isNsfw: false,
  );

  test('initial state should be empty GalleryState', () {
    expect(galleryBloc.state.status, equals(GalleryStatus.initial));
    expect(galleryBloc.state.galleryItems, isEmpty);
    expect(galleryBloc.state.error, isNull);
  });

  blocTest<GalleryBloc, GalleryState>(
    'emits [loading, loaded] when LoadGalleryImages is added and successful',
    build: () {
      when(mockRepository.getGalleryImages(
        section: 'hot',
        sort: 'viral',
        window: 'day',
        page: 0,
      )).thenAnswer((_) async => [testGalleryItem]);
      return galleryBloc;
    },
    act: (bloc) => bloc.add(const LoadGalleryImages()),
    expect: () => [
      GalleryState(status: GalleryStatus.loading, galleryItems: const [], error: null),
      GalleryState(status: GalleryStatus.loaded, galleryItems: [testGalleryItem], error: null),
    ],
    verify: (_) {
      verify(mockRepository.getGalleryImages(
        section: 'hot',
        sort: 'viral',
        window: 'day',
        page: 0,
      )).called(1);
    },
  );

  blocTest<GalleryBloc, GalleryState>(
    'emits [loading, error] when LoadGalleryImages fails',
    build: () {
      when(mockRepository.getGalleryImages(page: 0))
          .thenThrow(Exception('Failed to load gallery'));
      return galleryBloc;
    },
    act: (bloc) => bloc.add(const LoadGalleryImages()),
    expect: () => [
      const GalleryState(status: GalleryStatus.loading),
      const GalleryState(
        status: GalleryStatus.error,
        error: 'Exception: Failed to load gallery',
      ),
    ],
    verify: (_) {
      verify(mockRepository.getGalleryImages(page: 0)).called(1);
    },
  );

  blocTest<GalleryBloc, GalleryState>(
    'emits [loading, loaded] when SearchGalleryImages is added and successful',
    build: () {
      when(mockRepository.searchGalleryImages(
        query: 'test',
        page: 0,
      )).thenAnswer((_) async => [testGalleryItem]);
      when(mockRepository.addRecentSearch('test')).thenAnswer((_) async {});
      return galleryBloc;
    },
    act: (bloc) => bloc.add(const SearchGalleryImages(query: 'test')),
    expect: () => [
      const GalleryState(
        status: GalleryStatus.loading,
        query: 'test',
      ),
      GalleryState(
        status: GalleryStatus.loaded,
        galleryItems: [testGalleryItem],
      ),
    ],
    verify: (_) {
      verify(mockRepository.searchGalleryImages(
        query: 'test',
        page: 0,
      )).called(1);
      verify(mockRepository.addRecentSearch('test')).called(1);
    },
  );

  blocTest<GalleryBloc, GalleryState>(
    'emits [loading, error] when SearchGalleryImages fails',
    build: () {
      when(mockRepository.searchGalleryImages(
        query: 'test',
        page: 0,
      )).thenThrow(Exception('Failed to search gallery'));
      return galleryBloc;
    },
    act: (bloc) => bloc.add(const SearchGalleryImages(query: 'test')),
    expect: () => [
      const GalleryState(
        status: GalleryStatus.loading,
        query: 'test',
      ),
      const GalleryState(
        status: GalleryStatus.error,
        error: 'Exception: Failed to search gallery',
      ),
    ],
    verify: (_) {
      verify(mockRepository.searchGalleryImages(
        query: 'test',
        page: 0,
      )).called(1);
    },
  );
} 