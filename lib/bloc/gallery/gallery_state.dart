import 'package:equatable/equatable.dart';
import '../../models/imgur_gallery_item.dart';

enum GalleryStatus { initial, loading, loaded, error }

class GalleryState extends Equatable {
  final GalleryStatus status;
  final List<ImgurGalleryItem> galleryItems;
  final bool hasReachedMax;
  final String? query;
  final int page;
  final String? error;
  
  const GalleryState({
    this.status = GalleryStatus.initial,
    this.galleryItems = const <ImgurGalleryItem>[],
    this.hasReachedMax = false,
    this.query,
    this.page = 0,
    this.error,
  });
  
  GalleryState copyWith({
    GalleryStatus? status,
    List<ImgurGalleryItem>? galleryItems,
    bool? hasReachedMax,
    String? query,
    int? page,
    String? error,
  }) {
    return GalleryState(
      status: status ?? this.status,
      galleryItems: galleryItems ?? this.galleryItems,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      query: query,
      page: page ?? this.page,
      error: error,
    );
  }
  
  @override
  List<Object?> get props => [status, galleryItems, hasReachedMax, query, page, error];
} 