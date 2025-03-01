import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../repositories/imgur_repository.dart';
import 'recent_searches_event.dart';
import 'recent_searches_state.dart';

class RecentSearchesBloc extends Bloc<RecentSearchesEvent, RecentSearchesState> {
  final ImgurRepository repository;
  
  RecentSearchesBloc({required this.repository}) : super(const RecentSearchesState()) {
    on<LoadRecentSearches>(_onLoadRecentSearches);
    on<AddRecentSearch>(_onAddRecentSearch);
    on<RemoveRecentSearch>(_onRemoveRecentSearch);
    on<ClearRecentSearches>(_onClearRecentSearches);
  }
  
  void _onLoadRecentSearches(
    LoadRecentSearches event,
    Emitter<RecentSearchesState> emit,
  ) {
    emit(state.copyWith(status: RecentSearchesStatus.loading));
    
    try {
      final searches = repository.getRecentSearches();
      
      emit(state.copyWith(
        status: RecentSearchesStatus.loaded,
        searches: searches,
        error: null,
      ));
    } catch (e) {
      debugPrint('Error loading recent searches: $e');
      emit(state.copyWith(
        status: RecentSearchesStatus.error,
        error: 'Could not load recent searches',
      ));
    }
  }
  
  Future<void> _onAddRecentSearch(
    AddRecentSearch event,
    Emitter<RecentSearchesState> emit,
  ) async {
    try {
      await repository.addRecentSearch(event.searchTerm);
      
      
      final searches = repository.getRecentSearches();
      emit(state.copyWith(
        status: RecentSearchesStatus.loaded,
        searches: searches,
        error: null,
      ));
    } catch (e) {
      debugPrint('Error adding recent search: $e');
      
      
    }
  }
  
  Future<void> _onRemoveRecentSearch(
    RemoveRecentSearch event,
    Emitter<RecentSearchesState> emit,
  ) async {
    try {
      await repository.removeRecentSearch(event.searchTerm);
      
      
      final searches = repository.getRecentSearches();
      emit(state.copyWith(
        status: RecentSearchesStatus.loaded,
        searches: searches,
        error: null,
      ));
    } catch (e) {
      debugPrint('Error removing recent search: $e');
      
      
    }
  }
  
  Future<void> _onClearRecentSearches(
    ClearRecentSearches event,
    Emitter<RecentSearchesState> emit,
  ) async {
    try {
      await repository.clearRecentSearches();
      
      emit(state.copyWith(
        status: RecentSearchesStatus.loaded,
        searches: const [],
        error: null,
      ));
    } catch (e) {
      debugPrint('Error clearing recent searches: $e');
      
      emit(state.copyWith(
        status: RecentSearchesStatus.loaded,
        searches: const [],
        error: null,
      ));
    }
  }
} 