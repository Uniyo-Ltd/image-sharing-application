import 'package:equatable/equatable.dart';
import 'imgur_image.dart';

class ImgurGalleryItem extends Equatable {
  final String id;
  final String? title;
  final String? description;
  final int? datetime;
  final String? cover;
  final int? coverWidth;
  final int? coverHeight;
  final bool? isAlbum;
  final int? imagesCount;
  final int? views;
  final int? score;
  final int? commentCount;
  final int? points;
  final String link;
  final List<ImgurImage>? images;
  final bool isNsfw;
  
  String get coverImageUrl {
    if (cover != null) {
      return 'https://i.imgur.com/${cover}.jpg';
    } else if (images != null && images!.isNotEmpty) {
      return images!.first.link;
    } else if (link.isNotEmpty) {
      return link;
    } else {
      return '';
    }
  }
  
  ImgurImage? get firstImage {
    if (images != null && images!.isNotEmpty) {
      return images!.first;
    }
    return null;
  }
  
  const ImgurGalleryItem({
    required this.id,
    this.title,
    this.description,
    this.datetime,
    this.cover,
    this.coverWidth,
    this.coverHeight,
    this.isAlbum = false,
    this.imagesCount,
    this.views,
    this.score,
    this.commentCount,
    this.points,
    required this.link,
    this.images,
    this.isNsfw = false,
  });
  
  factory ImgurGalleryItem.fromJson(Map<String, dynamic> json) {
    List<ImgurImage>? imagesList;
    
    if (json['images'] != null) {
      imagesList = List<ImgurImage>.from(
        json['images'].map((x) => ImgurImage.fromJson(x))
      );
    }
    
    return ImgurGalleryItem(
      id: json['id'] ?? '',
      title: json['title'],
      description: json['description'],
      datetime: json['datetime'],
      cover: json['cover'],
      coverWidth: json['cover_width'],
      coverHeight: json['cover_height'],
      isAlbum: json['is_album'] ?? false,
      imagesCount: json['images_count'],
      views: json['views'],
      score: json['score'],
      commentCount: json['comment_count'],
      points: json['points'],
      link: json['link'] ?? '',
      images: imagesList,
      isNsfw: json['nsfw'] == true || json['is_ad'] == true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'datetime': datetime,
      'cover': cover,
      'cover_width': coverWidth,
      'cover_height': coverHeight,
      'is_album': isAlbum,
      'images_count': imagesCount,
      'views': views,
      'score': score,
      'comment_count': commentCount,
      'points': points,
      'link': link,
      'images': images?.map((x) => x.toJson()).toList(),
      'nsfw': isNsfw,
    };
  }
  
  @override
  List<Object?> get props => [
    id, 
    title, 
    description, 
    datetime, 
    cover, 
    coverWidth, 
    coverHeight, 
    isAlbum, 
    imagesCount, 
    views, 
    score, 
    commentCount, 
    points, 
    link, 
    images,
    isNsfw,
  ];
} 