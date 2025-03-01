import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:image_sharing_application/bloc/gallery/gallery_bloc.dart';
import 'package:image_sharing_application/bloc/gallery/gallery_event.dart';
import 'package:image_sharing_application/bloc/gallery/gallery_state.dart';
import 'package:image_sharing_application/models/imgur_gallery_item.dart';
import 'package:image_sharing_application/models/imgur_image.dart';
import 'package:image_sharing_application/repositories/imgur_repository.dart';

// Generate mock classes
@GenerateMocks([ImgurRepository])
import 'gallery_bloc_test.mocks.dart';

void main() {
  late MockImgurRepository mockRepository;
  late GalleryBloc galleryBloc;
  
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
  
  final testGalleryItem = ImgurGalleryItem(
    id: 'gallery123',
    title: 'Test Gallery Item',
    description: 'A test gallery item',
    datetime: 1612345678,
    cover: 'test123',
    coverWidth: 800,
    coverHeight: 600,
    link: 'https://imgur.com/gallery123',
    isAlbum: true,
    images: [testImage],
    imagesCount: 1,
    views: 1000,
    score: 100,
    commentCount: 10,
    points: 90,
  );
  
  setUp(() {
    mockRepository = MockImgurRepository();
    galleryBloc = GalleryBloc(repository: mockRepository);
  });
  
  tearDown(() {
    galleryBloc.close();
  });
  
  test('initial state should be GalleryState.initial()', () {
    // Assert
    expect(galleryBloc.state, equals(GalleryState.initial()));
  });
  
  blocTest<GalleryBloc, GalleryState>(
    'emits [loading, loaded] when LoadGalleryImages is added',
    build: () {
      when(mockRepository.getPopularGallery(page: 0))
          .thenAnswer((_) async => [testGalleryItem]);
      return galleryBloc;
    },
    act: (bloc) => bloc.add(const LoadGalleryImages()),
    expect: () => [
      GalleryState(
        status: GalleryStatus.loading,
        galleryItems: [],
        currentPage: 0,
        hasReachedMax: false,
        isSearching: false,
        searchQuery: '',
        error: null,
      ),
      GalleryState(
        status: GalleryStatus.loaded,
        galleryItems: [testGalleryItem],
        currentPage: 0,
        hasReachedMax: false,
        isSearching: false,
        searchQuery: '',
        error: null,
      ),
    ],
    verify: (_) {
      verify(mockRepository.getPopularGallery(page: 0)).called(1);
    },
  );
  
  blocTest<GalleryBloc, GalleryState>(
    'emits [loading, error] when LoadGalleryImages fails',
    build: () {
      when(mockRepository.getPopularGallery(page: 0))
          .thenThrow(Exception('Failed to load gallery'));
      return galleryBloc;
    },
    act: (bloc) => bloc.add(const LoadGalleryImages()),
    expect: () => [
      GalleryState(
        status: GalleryStatus.loading,
        galleryItems: [],
        currentPage: 0,
        hasReachedMax: false,
        isSearching: false,
        searchQuery: '',
        error: null,
      ),
      GalleryState(
        status: GalleryStatus.error,
        galleryItems: [],
        currentPage: 0,
        hasReachedMax: false,
        isSearching: false,
        searchQuery: '',
        error: 'Failed to load gallery',
      ),
    ],
    verify: (_) {
      verify(mockRepository.getPopularGallery(page: 0)).called(1);
    },
  );
  
  blocTest<GalleryBloc, GalleryState>(
    'emits updated state with search results when SearchGallery is added',
    build: () {
      when(mockRepository.searchGallery(query: 'test', page: 0))
          .thenAnswer((_) async => [testGalleryItem]);
      return galleryBloc;
    },
    act: (bloc) => bloc.add(const SearchGallery('test')),
    expect: () => [
      GalleryState(
        status: GalleryStatus.loading,
        galleryItems: [],
        currentPage: 0,
        hasReachedMax: false,
        isSearching: true,
        searchQuery: 'test',
        error: null,
      ),
      GalleryState(
        status: GalleryStatus.loaded,
        galleryItems: [testGalleryItem],
        currentPage: 0,
        hasReachedMax: false,
        isSearching: true,
        searchQuery: 'test',
        error: null,
      ),
    ],
    verify: (_) {
      verify(mockRepository.searchGallery(query: 'test', page: 0)).called(1);
    },
  );
  
  blocTest<GalleryBloc, GalleryState>(
    'emits updated state with more items when LoadMoreGalleryImages is added',
    build: () {
      when(mockRepository.getPopularGallery(page: 1))
          .thenAnswer((_) async => [testGalleryItem]);
      return galleryBloc;
    },
    seed: () => GalleryState(
      status: GalleryStatus.loaded,
      galleryItems: [testGalleryItem],
      currentPage: 0,
      hasReachedMax: false,
      isSearching: false,
      searchQuery: '',
      error: null,
    ),
    act: (bloc) => bloc.add(const LoadMoreGalleryImages()),
    expect: () => [
      GalleryState(
        status: GalleryStatus.loading,
        galleryItems: [testGalleryItem],
        currentPage: 0,
        hasReachedMax: false,
        isSearching: false,
        searchQuery: '',
        error: null,
      ),
      GalleryState(
        status: GalleryStatus.loaded,
        galleryItems: [testGalleryItem, testGalleryItem],
        currentPage: 1,
        hasReachedMax: false,
        isSearching: false,
        searchQuery: '',
        error: null,
      ),
    ],
    verify: (_) {
      verify(mockRepository.getPopularGallery(page: 1)).called(1);
    },
  );
} 