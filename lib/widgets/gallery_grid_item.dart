import 'package:flutter/material.dart';
import '../models/imgur_gallery_item.dart';

class GalleryGridItem extends StatelessWidget {
  final ImgurGalleryItem galleryItem;
  final VoidCallback onTap;
  
  const GalleryGridItem({
    super.key,
    required this.galleryItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            if (galleryItem.title != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  galleryItem.title!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                bottom: 8.0,
              ),
              child: _buildFooter(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImage() {
    final imageUrl = _getImageUrl();
    
    if (imageUrl.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: Icon(Icons.image_not_supported, size: 50),
        ),
      );
    }
    
    
    final isVideo = _isVideoUrl(imageUrl);
    
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: _calculateAspectRatio(),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.error, color: Colors.red),
            ),
          ),
        ),
        
        
        if (isVideo)
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        
        Row(
          children: [
            const Icon(Icons.visibility, size: 16),
            const SizedBox(width: 4),
            Text(
              _formatCount(galleryItem.views),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        
        
        if (galleryItem.score != null)
          Row(
            children: [
              const Icon(Icons.thumb_up, size: 16),
              const SizedBox(width: 4),
              Text(
                _formatCount(galleryItem.score),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          
        
        if (galleryItem.isAlbum == true && galleryItem.imagesCount != null)
          Row(
            children: [
              const Icon(Icons.photo_library, size: 16),
              const SizedBox(width: 4),
              Text(
                '${galleryItem.imagesCount}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
      ],
    );
  }
  
  double _calculateAspectRatio() {
    if (galleryItem.coverWidth != null && 
        galleryItem.coverHeight != null && 
        galleryItem.coverHeight! > 0) {
      return galleryItem.coverWidth! / galleryItem.coverHeight!;
    }
    
    
    return 16 / 9;
  }
  
  String _formatCount(int? count) {
    if (count == null) return '0';
    
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }
  
  String _getImageUrl() {
    String url = galleryItem.coverImageUrl;
    
    
    if (_isVideoUrl(url)) {
      
      final RegExp regExp = RegExp(r'imgur\.com/([a-zA-Z0-9]+)\.');
      final match = regExp.firstMatch(url);
      
      if (match != null && match.groupCount >= 1) {
        final id = match.group(1);
        return 'https://i.imgur.com/${id}.jpg';
      }
    }
    
    return url;
  }
  
  bool _isVideoUrl(String url) {
    return url.endsWith('.mp4') || 
           url.endsWith('.gifv') || 
           url.endsWith('.webm') ||
           url.contains('.mp4') ||
           url.contains('.gifv') ||
           url.contains('.webm');
  }
} 