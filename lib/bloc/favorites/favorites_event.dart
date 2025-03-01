import 'package:equatable/equatable.dart';
import '../../models/imgur_image.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  
  @override
  List<Object?> get props => [];
}


class LoadFavorites extends FavoritesEvent {}


class AddToFavorites extends FavoritesEvent {
  final ImgurImage image;
  
  const AddToFavorites(this.image);
  
  @override
  List<Object?> get props => [image];
}


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