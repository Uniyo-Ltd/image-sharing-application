import 'package:equatable/equatable.dart';

class ImgurImage extends Equatable {
  final String id;
  final String? title;
  final String? description;
  final int? datetime;
  final String? accountUrl;
  final String? accountId;
  final int? width;
  final int? height;
  final int? size;
  final int? views;
  final int? score;
  final int? commentCount;
  final int? points;
  final String link;
  final bool animated;
  
  const ImgurImage({
    required this.id,
    this.title,
    this.description,
    this.datetime,
    this.accountUrl,
    this.accountId,
    this.width,
    this.height,
    this.size,
    this.views,
    this.score,
    this.commentCount,
    this.points,
    required this.link,
    this.animated = false,
  });
  
  factory ImgurImage.fromJson(Map<String, dynamic> json) {
    return ImgurImage(
      id: json['id'] ?? '',
      title: json['title'],
      description: json['description'],
      datetime: json['datetime'],
      accountUrl: json['account_url'],
      accountId: json['account_id'],
      width: json['width'],
      height: json['height'],
      size: json['size'],
      views: json['views'],
      score: json['points'],
      commentCount: json['comment_count'],
      points: json['points'],
      link: json['link'] ?? '',
      animated: json['animated'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'datetime': datetime,
      'account_url': accountUrl,
      'account_id': accountId,
      'width': width,
      'height': height,
      'size': size,
      'views': views,
      'score': score,
      'comment_count': commentCount,
      'points': points,
      'link': link,
      'animated': animated,
    };
  }
  
  @override
  List<Object?> get props => [
    id,
    title,
    description,
    datetime,
    accountUrl,
    accountId,
    width,
    height,
    size,
    views,
    score,
    commentCount,
    points,
    link,
    animated,
  ];
} 