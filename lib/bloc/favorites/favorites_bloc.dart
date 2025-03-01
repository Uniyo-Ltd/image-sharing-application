import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/imgur_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final ImgurRepository repository;
  
  FavoritesBloc({required this.repository}) : super(const FavoritesState()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
  }
  
  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(status: FavoritesStatus.loading));
    
    try {
      final favoriteImages = repository.getFavoriteImages();
      
      emit(state.copyWith(
        status: FavoritesStatus.loaded,
        favoriteImages: favoriteImages,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FavoritesStatus.error,
        error: e.toString(),
      ));
    }
  }
  
  Future<void> _onAddToFavorites(
    AddToFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await repository.addToFavorites(event.image);
      
      
      final updatedFavorites = repository.getFavoriteImages();
      
      emit(state.copyWith(
        status: FavoritesStatus.loaded,
        favoriteImages: updatedFavorites,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FavoritesStatus.error,
        error: e.toString(),
      ));
    }
  }
  
  Future<void> _onRemoveFromFavorites(
    RemoveFromFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await repository.removeFromFavorites(event.imageId);
      
      
      final updatedFavorites = repository.getFavoriteImages();
      
      emit(state.copyWith(
        status: FavoritesStatus.loaded,
        favoriteImages: updatedFavorites,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FavoritesStatus.error,
        error: e.toString(),
      ));
    }
  }
} 