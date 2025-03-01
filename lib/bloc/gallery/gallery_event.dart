import 'package:equatable/equatable.dart';

abstract class GalleryEvent extends Equatable {
  const GalleryEvent();
  
  @override
  List<Object?> get props => [];
}

// Event to load the initial popular gallery images
class LoadGalleryImages extends GalleryEvent {
  final bool refresh;
  
  const LoadGalleryImages({this.refresh = false});
  
  @override
  List<Object?> get props => [refresh];
}

// Event to load more gallery images (pagination)
class LoadMoreGalleryImages extends GalleryEvent {}

// Event to search for images
class SearchGalleryImages extends GalleryEvent {
  final String query;
  
  const SearchGalleryImages({required this.query});
  
  @override
  List<Object?> get props => [query];
}

// Event to load more search results (pagination)
class LoadMoreSearchResults extends GalleryEvent {}

// Event to clear the search and return to popular images
class ClearGallerySearch extends GalleryEvent {} 