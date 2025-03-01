import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../bloc/favorites/favorites_bloc.dart';
import '../bloc/favorites/favorites_event.dart';
import '../bloc/favorites/favorites_state.dart';
import '../models/imgur_gallery_item.dart';
import '../models/imgur_image.dart';
import '../widgets/gallery_grid_item.dart';
import 'image_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FavoritesBloc>().add(LoadFavorites());
            },
          ),
        ],
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state.status == FavoritesStatus.initial || 
              state.status == FavoritesStatus.loading && state.favoriteImages.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state.status == FavoritesStatus.loaded || 
                    state.status == FavoritesStatus.loading) {
            final favorites = state.favoriteImages;
            
            if (favorites.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No favorites yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add some images to your favorites',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.home),
                      label: const Text('Explore Images'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            }
            
            return MasonryGridView.count(
              padding: const EdgeInsets.all(8),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final ImgurImage image = favorites[index];
                
                final galleryItem = _convertToGalleryItem(image);
                
                return Stack(
                  children: [
                    GalleryGridItem(
                      galleryItem: galleryItem,
                      onTap: () => _navigateToDetail(context, galleryItem),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: _buildRemoveButton(context, image),
                    ),
                  ],
                );
              },
            );
          } else if (state.status == FavoritesStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FavoritesBloc>().add(LoadFavorites());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          return const Center(
            child: Text('Unknown state'),
          );
        },
      ),
    );
  }
  
  Widget _buildRemoveButton(BuildContext context, ImgurImage image) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(
          Icons.favorite,
          color: Colors.red,
          size: 22,
        ),
        onPressed: () {
          
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Remove from Favorites?'),
              content: const Text('This image will be removed from your favorites.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    
                    context.read<FavoritesBloc>().add(RemoveFromFavorites(image.id));
                  },
                  child: const Text('Remove'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _navigateToDetail(BuildContext context, ImgurGalleryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageDetailScreen(galleryItem: item),
      ),
    );
  }
  
  
  ImgurGalleryItem _convertToGalleryItem(ImgurImage image) {
    return ImgurGalleryItem(
      id: image.id,
      title: image.title,
      description: image.description,
      datetime: image.datetime,
      cover: image.id,
      coverWidth: image.width,
      coverHeight: image.height,
      link: image.link,
      isAlbum: false,
      views: image.views,
      score: image.score,
      commentCount: image.commentCount,
      points: image.points,
      imagesCount: 1,
      images: [image],
    );
  }
} 