import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/favorites/favorites_bloc.dart';
import '../bloc/favorites/favorites_event.dart';
import '../bloc/favorites/favorites_state.dart';
import '../models/imgur_gallery_item.dart';
import '../models/imgur_image.dart';

class ImageDetailScreen extends StatelessWidget {
  final ImgurGalleryItem galleryItem;
  
  const ImageDetailScreen({
    super.key,
    required this.galleryItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(galleryItem.title ?? 'Image Details'),
        actions: [
          if (galleryItem.firstImage != null)
            _buildFavoriteButton(context, galleryItem.firstImage!),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageView(context),
            _buildImageInfo(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImageView(BuildContext context) {
    final String imageUrl = galleryItem.coverImageUrl;
    
    if (imageUrl.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Icon(Icons.image_not_supported, size: 100),
        ),
      );
    }
    
    return Image.network(
      imageUrl,
      width: double.infinity,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          height: 300,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        height: 300,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.error, color: Colors.red, size: 50),
        ),
      ),
    );
  }
  
  Widget _buildImageInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          if (galleryItem.title != null)
            Text(
              galleryItem.title!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
          const SizedBox(height: 16),
          
          
          _buildStatsRow(),
          
          const SizedBox(height: 16),
          
          
          if (galleryItem.description != null && galleryItem.description!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(galleryItem.description!),
                const SizedBox(height: 16),
              ],
            ),
          
          
          if (galleryItem.datetime != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Posted',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDateTime(galleryItem.datetime!),
                ),
                const SizedBox(height: 16),
              ],
            ),
          
          
          if (galleryItem.isAlbum == true && 
              galleryItem.images != null && 
              galleryItem.images!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Album Images (${galleryItem.images!.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildAlbumImagesGrid(),
              ],
            ),
        ],
      ),
    );
  }
  
  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        
        _buildStatItem(
          icon: Icons.visibility,
          value: galleryItem.views?.toString() ?? '0',
          label: 'Views',
        ),
        
        
        _buildStatItem(
          icon: Icons.thumb_up,
          value: galleryItem.points?.toString() ?? '0',
          label: 'Points',
        ),
        
        
        _buildStatItem(
          icon: Icons.comment,
          value: galleryItem.commentCount?.toString() ?? '0',
          label: 'Comments',
        ),
      ],
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildAlbumImagesGrid() {
    final images = galleryItem.images ?? [];
    
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        
        return GestureDetector(
          onTap: () {
            _showFullScreenImage(context, image);
          },
          child: Image.network(
            image.link,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            errorBuilder: (context, url, error) => const Center(
              child: Icon(Icons.error, color: Colors.red),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildFavoriteButton(BuildContext context, ImgurImage image) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      buildWhen: (previous, current) => 
          previous.favoriteImages != current.favoriteImages,
      builder: (context, state) {
        final isFavorite = state.favoriteImages
            .any((favImage) => favImage.id == image.id);
        
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: IconButton(
            key: ValueKey<bool>(isFavorite),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
              size: 28,
            ),
            onPressed: () {
              if (isFavorite) {
                context.read<FavoritesBloc>().add(RemoveFromFavorites(image.id));
              } else {
                context.read<FavoritesBloc>().add(AddToFavorites(image));
              }
            },
          ),
        );
      },
    );
  }
  
  void _showFullScreenImage(BuildContext context, ImgurImage image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(image.title ?? 'Image'),
            actions: [
              _buildFavoriteButton(context, image),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                image.link,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator();
                },
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 50,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatDateTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final formatter = DateFormat.yMMMMd().add_jm();
    return formatter.format(dateTime);
  }
} 