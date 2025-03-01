import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:image_sharing_application/repositories/imgur_repository.dart';
import 'package:image_sharing_application/bloc/recent_searches/recent_searches_bloc.dart';
import 'package:image_sharing_application/bloc/recent_searches/recent_searches_event.dart';
import 'package:image_sharing_application/bloc/recent_searches/recent_searches_state.dart';

@GenerateMocks([ImgurRepository])
import 'recent_searches_bloc_test.mocks.dart';

void main() {
  late MockImgurRepository mockRepository;
  late RecentSearchesBloc recentSearchesBloc;

  setUp(() {
    mockRepository = MockImgurRepository();
    recentSearchesBloc = RecentSearchesBloc(repository: mockRepository);
  });

  test('initial state should be empty RecentSearchesState', () {
    expect(recentSearchesBloc.state.status, equals(RecentSearchesStatus.initial));
    expect(recentSearchesBloc.state.searches, isEmpty);
    expect(recentSearchesBloc.state.error, isNull);
  });

  blocTest<RecentSearchesBloc, RecentSearchesState>(
    'emits [loading, loaded] when LoadRecentSearches is added and successful',
    build: () {
      when(mockRepository.getRecentSearches())
          .thenReturn(['cats', 'dogs', 'birds']);
      return recentSearchesBloc;
    },
    act: (bloc) => bloc.add(const LoadRecentSearches()),
    expect: () => [
      RecentSearchesState(status: RecentSearchesStatus.loading, searches: const [], error: null),
      RecentSearchesState(
        status: RecentSearchesStatus.loaded,
        searches: ['cats', 'dogs', 'birds'],
        error: null,
      ),
    ],
    verify: (_) {
      verify(mockRepository.getRecentSearches()).called(1);
    },
  );

  blocTest<RecentSearchesBloc, RecentSearchesState>(
    'emits [loading, error] when LoadRecentSearches fails',
    build: () {
      when(mockRepository.getRecentSearches())
          .thenThrow(Exception('Failed to load recent searches'));
      return recentSearchesBloc;
    },
    act: (bloc) => bloc.add(const LoadRecentSearches()),
    expect: () => [
      RecentSearchesState(status: RecentSearchesStatus.loading, searches: const [], error: null),
      RecentSearchesState(
        status: RecentSearchesStatus.error,
        searches: const [],
        error: 'Could not load recent searches',
      ),
    ],
    verify: (_) {
      verify(mockRepository.getRecentSearches()).called(1);
    },
  );

  blocTest<RecentSearchesBloc, RecentSearchesState>(
    'emits updated state when AddRecentSearch is added',
    build: () {
      when(mockRepository.addRecentSearch('cats'))
          .thenAnswer((_) async {});
      when(mockRepository.getRecentSearches())
          .thenReturn(['cats', 'dogs', 'birds']);
      return recentSearchesBloc;
    },
    seed: () => RecentSearchesState(
      status: RecentSearchesStatus.loaded,
      searches: ['dogs', 'birds'],
      error: null,
    ),
    act: (bloc) => bloc.add(const AddRecentSearch(searchTerm: 'cats')),
    expect: () => [
      RecentSearchesState(
        status: RecentSearchesStatus.loaded,
        searches: ['cats', 'dogs', 'birds'],
        error: null,
      ),
    ],
    verify: (_) {
      verify(mockRepository.addRecentSearch('cats')).called(1);
      verify(mockRepository.getRecentSearches()).called(1);
    },
  );

  blocTest<RecentSearchesBloc, RecentSearchesState>(
    'emits updated state when RemoveRecentSearch is added',
    build: () {
      when(mockRepository.removeRecentSearch('dogs'))
          .thenAnswer((_) async {});
      when(mockRepository.getRecentSearches())
          .thenReturn(['cats', 'birds']);
      return recentSearchesBloc;
    },
    seed: () => RecentSearchesState(
      status: RecentSearchesStatus.loaded,
      searches: ['cats', 'dogs', 'birds'],
      error: null,
    ),
    act: (bloc) => bloc.add(const RemoveRecentSearch(searchTerm: 'dogs')),
    expect: () => [
      RecentSearchesState(
        status: RecentSearchesStatus.loaded,
        searches: ['cats', 'birds'],
        error: null,
      ),
    ],
    verify: (_) {
      verify(mockRepository.removeRecentSearch('dogs')).called(1);
      verify(mockRepository.getRecentSearches()).called(1);
    },
  );

  blocTest<RecentSearchesBloc, RecentSearchesState>(
    'emits updated state when ClearRecentSearches is added',
    build: () {
      when(mockRepository.clearRecentSearches())
          .thenAnswer((_) async {});
      return recentSearchesBloc;
    },
    seed: () => RecentSearchesState(
      status: RecentSearchesStatus.loaded,
      searches: ['cats', 'dogs', 'birds'],
      error: null,
    ),
    act: (bloc) => bloc.add(const ClearRecentSearches()),
    expect: () => [
      RecentSearchesState(
        status: RecentSearchesStatus.loaded,
        searches: const [],
        error: null,
      ),
    ],
    verify: (_) {
      verify(mockRepository.clearRecentSearches()).called(1);
    },
  );
} 