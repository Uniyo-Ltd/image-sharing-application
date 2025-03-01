import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:image_sharing_application/bloc/recent_searches/recent_searches_bloc.dart';
import 'package:image_sharing_application/bloc/recent_searches/recent_searches_event.dart';
import 'package:image_sharing_application/bloc/recent_searches/recent_searches_state.dart';
import 'package:image_sharing_application/repositories/imgur_repository.dart';

// Generate mock classes
@GenerateMocks([ImgurRepository])
import 'recent_searches_bloc_test.mocks.dart';

void main() {
  late MockImgurRepository mockRepository;
  late RecentSearchesBloc recentSearchesBloc;
  
  final testSearches = ['cats', 'dogs', 'space'];
  
  setUp(() {
    mockRepository = MockImgurRepository();
    recentSearchesBloc = RecentSearchesBloc(repository: mockRepository);
  });
  
  tearDown(() {
    recentSearchesBloc.close();
  });
  
  test('initial state should be RecentSearchesState.initial()', () {
    // Assert
    expect(recentSearchesBloc.state, equals(RecentSearchesState.initial()));
  });
  
  blocTest<RecentSearchesBloc, RecentSearchesState>(
    'emits [loading, loaded] when LoadRecentSearches is added',
    build: () {
      when(mockRepository.getRecentSearches())
          .thenAnswer((_) async => testSearches);
      return recentSearchesBloc;
    },
    act: (bloc) => bloc.add(const LoadRecentSearches()),
    expect: () => [
      RecentSearchesState(
        status: RecentSearchesStatus.loading,
        searches: [],
        error: null,
      ),
      RecentSearchesState(
        status: RecentSearchesStatus.loaded,
        searches: testSearches,
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
      RecentSearchesState(
        status: RecentSearchesStatus.loading,
        searches: [],
        error: null,
      ),
      RecentSearchesState(
        status: RecentSearchesStatus.error,
        searches: [],
        error: 'Failed to load recent searches',
      ),
    ],
    verify: (_) {
      verify(mockRepository.getRecentSearches()).called(1);
    },
  );
  
  blocTest<RecentSearchesBloc, RecentSearchesState>(
    'emits updated state when AddSearch is added',
    build: () {
      when(mockRepository.addRecentSearch('birds'))
          .thenAnswer((_) async => true);
      return recentSearchesBloc;
    },
    seed: () => RecentSearchesState(
      status: RecentSearchesStatus.loaded,
      searches: testSearches,
      error: null,
    ),
    act: (bloc) => bloc.add(const AddSearch('birds')),
    expect: () => [
      RecentSearchesState(
        status: RecentSearchesStatus.loaded,
        searches: ['birds', 'cats', 'dogs', 'space'],
        error: null,
      ),
    ],
    verify: (_) {
      verify(mockRepository.addRecentSearch('birds')).called(1);
    },
  );
  
  blocTest<RecentSearchesBloc, RecentSearchesState>(
    'emits updated state when RemoveSearch is added',
    build: () {
      when(mockRepository.removeRecentSearch('dogs'))
          .thenAnswer((_) async => true);
      return recentSearchesBloc;
    },
    seed: () => RecentSearchesState(
      status: RecentSearchesStatus.loaded,
      searches: testSearches,
      error: null,
    ),
    act: (bloc) => bloc.add(const RemoveSearch('dogs')),
    expect: () => [
      RecentSearchesState(
        status: RecentSearchesStatus.loaded,
        searches: ['cats', 'space'],
        error: null,
      ),
    ],
    verify: (_) {
      verify(mockRepository.removeRecentSearch('dogs')).called(1);
    },
  );
  
  blocTest<RecentSearchesBloc, RecentSearchesState>(
    'emits updated state when ClearSearches is added',
    build: () {
      when(mockRepository.clearRecentSearches())
          .thenAnswer((_) async => true);
      return recentSearchesBloc;
    },
    seed: () => RecentSearchesState(
      status: RecentSearchesStatus.loaded,
      searches: testSearches,
      error: null,
    ),
    act: (bloc) => bloc.add(const ClearSearches()),
    expect: () => [
      RecentSearchesState(
        status: RecentSearchesStatus.loaded,
        searches: [],
        error: null,
      ),
    ],
    verify: (_) {
      verify(mockRepository.clearRecentSearches()).called(1);
    },
  );
} 