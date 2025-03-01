import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/recent_searches/recent_searches_bloc.dart';
import '../bloc/recent_searches/recent_searches_event.dart';
import '../bloc/recent_searches/recent_searches_state.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onClose;
  
  const SearchBarWidget({
    super.key,
    required this.onSearch,
    required this.onClose,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    try {
      context.read<RecentSearchesBloc>().add(const LoadRecentSearches());
    } catch (e) {
      debugPrint('Error loading recent searches: $e');
    }
    
    _focusNode.addListener(_onFocusChanged);
    _textController.addListener(_onTextChanged);
  }
  
  void _onFocusChanged() {
    setState(() {
      _isSearching = _focusNode.hasFocus;
    });
    
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }
  
  void _onTextChanged() {
    if (_focusNode.hasFocus) {
      if (_overlayEntry != null) {
        _updateOverlay();
      } else {
        _showOverlay();
      }
    }
  }
  
  void _showOverlay() {
    if (_overlayEntry != null) {
      _hideOverlay();
    }
    
    OverlayState overlayState = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height),
          child: Material(
            elevation: 4.0,
            child: _buildRecentSearchesList(),
          ),
        ),
      ),
    );
    
    overlayState.insert(_overlayEntry!);
  }
  
  void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
  }
  
  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  
  @override
  void dispose() {
    _hideOverlay();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Icon(Icons.search),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Search images...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (query) {
                      if (query.isNotEmpty) {
                        _handleSearch(query);
                      }
                    },
                  ),
                ),
                if (_textController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _textController.clear();
                      setState(() {});
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _hideOverlay();
                    widget.onClose();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRecentSearchesList() {
    return BlocBuilder<RecentSearchesBloc, RecentSearchesState>(
      builder: (context, state) {
        if (state.status == RecentSearchesStatus.error) {
          return _buildErrorMessage();
        } else if (state.status == RecentSearchesStatus.loading) {
          return _buildLoadingIndicator();
        } else if (state.status == RecentSearchesStatus.loaded && state.searches.isNotEmpty) {
          return _buildRecentSearchesContent(state.searches);
        } else {
          return _buildEmptySearchesMessage();
        }
      },
    );
  }
  
  Widget _buildRecentSearchesContent(List<String> searches) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRecentSearchesHeader(),
          const Divider(height: 1, thickness: 0.5),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: searches.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final term = searches[index];
                return Dismissible(
                  key: Key('search_$term'),
                  background: Container(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.8),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16.0),
                    child: const Icon(Icons.delete_rounded, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _removeSearchTerm(term),
                  child: ListTile(
                    leading: const Icon(Icons.history_rounded, size: 18),
                    title: Text(
                      term,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    onTap: () => _handleSearch(term),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.surface,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  Widget _buildRecentSearchesHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Recent Searches',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: _clearAllSearches,
            child: Text(
              'Clear All',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptySearchesMessage() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Text(
          'No recent searches',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
  
  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Text(
          'Error loading recent searches',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
  
  void _handleSearch(String query) {
    if (query.isEmpty) return;
    
    _hideOverlay();
    _textController.text = query;
    widget.onSearch(query);
    FocusScope.of(context).unfocus();
  }
  
  void _removeSearchTerm(String term) {
    context.read<RecentSearchesBloc>().add(RemoveRecentSearch(searchTerm: term));
  }
  
  void _clearAllSearches() {
    context.read<RecentSearchesBloc>().add(const ClearRecentSearches());
  }
} 