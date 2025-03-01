import 'package:equatable/equatable.dart';
import '../../models/imgur_image.dart';

enum FavoritesStatus { initial, loading, loaded, error }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<ImgurImage> favoriteImages;
  final String? error;
  
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favoriteImages = const <ImgurImage>[],
    this.error,
  });
  
  FavoritesState copyWith({
    FavoritesStatus? status,
    List<ImgurImage>? favoriteImages,
    String? error,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favoriteImages: favoriteImages ?? this.favoriteImages,
      error: error,
    );
  }
  
  @override
  List<Object?> get props => [status, favoriteImages, error];
} 