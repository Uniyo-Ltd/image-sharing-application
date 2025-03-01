import 'package:equatable/equatable.dart';
import '../../models/imgur_image.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  
  @override
  List<Object?> get props => [];
}

// Event to load the user's favorite images
class LoadFavorites extends FavoritesEvent {}

// Event to add an image to favorites
class AddToFavorites extends FavoritesEvent {
  final ImgurImage image;
  
  const AddToFavorites(this.image);
  
  @override
  List<Object?> get props => [image];
}

// Event to remove an image from favorites
class RemoveFromFavorites extends FavoritesEvent {
  final String imageId;
  
  const RemoveFromFavorites(this.imageId);
  
  @override
  List<Object?> get props => [imageId];
}

class FavoritesCheckEvent extends FavoritesEvent {
  final String imageId;
  
  const FavoritesCheckEvent({required this.imageId});
  
  @override
  List<Object?> get props => [imageId];
} 