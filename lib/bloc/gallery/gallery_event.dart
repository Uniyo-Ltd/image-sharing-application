import 'package:equatable/equatable.dart';

abstract class GalleryEvent extends Equatable {
  const GalleryEvent();
  
  @override
  List<Object?> get props => [];
}


class LoadGalleryImages extends GalleryEvent {
  final bool refresh;
  
  const LoadGalleryImages({this.refresh = false});
  
  @override
  List<Object?> get props => [refresh];
}


class LoadMoreGalleryImages extends GalleryEvent {}


class SearchGalleryImages extends GalleryEvent {
  final String query;
  
  const SearchGalleryImages({required this.query});
  
  @override
  List<Object?> get props => [query];
}


class LoadMoreSearchResults extends GalleryEvent {}


class ClearGallerySearch extends GalleryEvent {} 