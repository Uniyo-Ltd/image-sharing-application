import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/imgur_repository.dart';
import '../../utils/constants.dart';
import 'gallery_event.dart';
import 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final ImgurRepository repository;
  
  GalleryBloc({required this.repository}) : super(const GalleryState()) {
    on<LoadGalleryImages>(_onLoadGalleryImages);
    on<LoadMoreGalleryImages>(_onLoadMoreGalleryImages);
    on<SearchGalleryImages>(_onSearchGalleryImages);
    on<LoadMoreSearchResults>(_onLoadMoreSearchResults);
    on<ClearGallerySearch>(_onClearGallerySearch);
  }
  
  Future<void> _onLoadGalleryImages(
    LoadGalleryImages event,
    Emitter<GalleryState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: GalleryStatus.loading,
        page: 0,
        query: null,
      ));
      
      final galleryItems = await repository.getGalleryImages(page: 0);
      
      emit(state.copyWith(
        status: GalleryStatus.loaded,
        galleryItems: galleryItems,
        hasReachedMax: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GalleryStatus.error,
        error: e.toString(),
      ));
    }
  }
  
  Future<void> _onLoadMoreGalleryImages(
    LoadMoreGalleryImages event,
    Emitter<GalleryState> emit,
  ) async {
    if (state.hasReachedMax) return;
    
    try {
      final nextPage = state.page + 1;
      
      emit(state.copyWith(status: GalleryStatus.loading));
      
      final moreItems = await repository.getGalleryImages(page: nextPage);
      
      if (moreItems.isEmpty) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        emit(
          state.copyWith(
            status: GalleryStatus.loaded,
            galleryItems: List.of(state.galleryItems)..addAll(moreItems),
            hasReachedMax: false,
            page: nextPage,
            error: null,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(
        status: GalleryStatus.error,
        error: e.toString(),
      ));
    }
  }
  
  Future<void> _onSearchGalleryImages(
    SearchGalleryImages event,
    Emitter<GalleryState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: GalleryStatus.loading,
        query: event.query,
        page: 0,
      ));
      
      final searchResults = await repository.searchGalleryImages(
        query: event.query,
        page: 0,
      );
      
      emit(state.copyWith(
        status: GalleryStatus.loaded,
        galleryItems: searchResults,
        hasReachedMax: false,
        error: null,
      ));
      
      repository.addRecentSearch(event.query);
    } catch (e) {
      emit(state.copyWith(
        status: GalleryStatus.error,
        error: e.toString(),
      ));
    }
  }
  
  Future<void> _onLoadMoreSearchResults(
    LoadMoreSearchResults event,
    Emitter<GalleryState> emit,
  ) async {
    if (state.hasReachedMax || state.query == null) return;
    
    try {
      final nextPage = state.page + 1;
      
      emit(state.copyWith(status: GalleryStatus.loading));
      
      final moreItems = await repository.searchGalleryImages(
        query: state.query!,
        page: nextPage,
      );
      
      if (moreItems.isEmpty) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        emit(
          state.copyWith(
            status: GalleryStatus.loaded,
            galleryItems: List.of(state.galleryItems)..addAll(moreItems),
            hasReachedMax: false,
            page: nextPage,
            error: null,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(
        status: GalleryStatus.error,
        error: e.toString(),
      ));
    }
  }
  
  void _onClearGallerySearch(
    ClearGallerySearch event,
    Emitter<GalleryState> emit,
  ) {
    add(const LoadGalleryImages());
  }
} 