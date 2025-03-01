import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../bloc/gallery/gallery_bloc.dart';
import '../bloc/gallery/gallery_event.dart';
import '../bloc/gallery/gallery_state.dart';
import '../models/imgur_gallery_item.dart';
import '../widgets/gallery_grid_item.dart';
import '../widgets/search_bar_widget.dart';
import 'image_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<GalleryBloc>().add(const LoadGalleryImages());
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_isBottom) {
      final state = context.read<GalleryBloc>().state;
      if (state.query != null) {
        context.read<GalleryBloc>().add(LoadMoreSearchResults());
      } else {
        context.read<GalleryBloc>().add(LoadMoreGalleryImages());
      }
    }
  }
  
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    
    return currentScroll >= (maxScroll * 0.8);
  }
  
  void _onSearch(String query) {
    context.read<GalleryBloc>().add(SearchGalleryImages(query: query));
    setState(() {
      _isSearching = false;
    });
  }
  
  void _onRefresh() async {
    context.read<GalleryBloc>().add(const LoadGalleryImages(refresh: true));
  }
  
  void _showSearchBar() {
    setState(() {
      _isSearching = true;
    });
  }
  
  void _hideSearchBar() {
    setState(() {
      _isSearching = false;
    });
    context.read<GalleryBloc>().add(ClearGallerySearch());
  }
  
  void _navigateToDetail(BuildContext context, ImgurGalleryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageDetailScreen(galleryItem: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
            ? SearchBarWidget(
                onSearch: _onSearch,
                onClose: _hideSearchBar,
              )
            : const Text('Imgur Gallery'),
        actions: _isSearching 
            ? []
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _showSearchBar,
                ),
                IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () {
                    Navigator.pushNamed(context, '/favorites');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _onRefresh,
                ),
              ],
      ),
      body: BlocBuilder<GalleryBloc, GalleryState>(
        builder: (context, state) {
          if (state.status == GalleryStatus.initial || 
              (state.status == GalleryStatus.loading && state.galleryItems.isEmpty)) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state.status == GalleryStatus.loaded || 
                    state.status == GalleryStatus.loading) {
            final items = state.galleryItems;
            
            if (items.isEmpty) {
              return const Center(
                child: Text('No results found'),
              );
            }
            
            return RefreshIndicator(
              onRefresh: () async => _onRefresh(),
              child: MasonryGridView.count(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: items.length + (state.hasReachedMax ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= items.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  return GalleryGridItem(
                    galleryItem: items[index],
                    onTap: () => _navigateToDetail(context, items[index]),
                  );
                },
              ),
            );
          } else if (state.status == GalleryStatus.error) {
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
                    onPressed: _onRefresh,
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
} 