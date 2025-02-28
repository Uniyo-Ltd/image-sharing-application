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

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final SearchController _searchController = SearchController();
  
  @override
  void initState() {
    super.initState();
    // Load recent searches when the widget is created
    context.read<RecentSearchesBloc>().add(const LoadRecentSearches());
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SearchAnchor(
            searchController: _searchController,
            builder: (BuildContext context, SearchController controller) {
              return SearchBar(
                controller: controller,
                padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
                onTap: () {
                  controller.openView();
                },
                onChanged: (_) {
                  // This callback is needed to make the SearchBar active on text changes
                },
                leading: const Icon(Icons.search),
                trailing: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ],
                hintText: 'Search images...',
              );
            },
            suggestionsBuilder: (BuildContext context, SearchController controller) {
              return _buildRecentSearchesList(controller);
            },
          ),
        ),
      ],
    );
  }
  
  List<Widget> _buildRecentSearchesList(SearchController controller) {
    return [
      BlocBuilder<RecentSearchesBloc, RecentSearchesState>(
        builder: (context, state) {
          if (state.status == RecentSearchesStatus.loading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              ),
            );
          } else if (state.status == RecentSearchesStatus.loaded && state.searches.isNotEmpty) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Searches',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton.icon(
                        icon: Icon(
                          Icons.delete_sweep_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        label: Text(
                          'Clear All',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          context.read<RecentSearchesBloc>().add(const ClearRecentSearches());
                          controller.closeView(null);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 0.5),
                ...state.searches.map((term) => _buildSearchItem(term, controller)),
              ],
            );
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: Theme.of(context).disabledColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Recent Searches',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).disabledColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search results will appear here',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).disabledColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    ];
  }
  
  Widget _buildSearchItem(String term, SearchController controller) {
    return Dismissible(
      key: Key('search_$term'),
      background: Container(
        color: Theme.of(context).colorScheme.error.withOpacity(0.8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        context.read<RecentSearchesBloc>().add(RemoveRecentSearch(searchTerm: term));
      },
      child: ListTile(
        leading: Icon(
          Icons.history_rounded,
          size: 20,
          color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
        ),
        title: Text(
          term,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.north_west_rounded,
          size: 16,
          color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
        ),
        dense: true,
        visualDensity: VisualDensity.compact,
        onTap: () {
          _performSearch(term);
          controller.closeView(term);
        },
      ),
    );
  }
  
  void _performSearch(String query) {
    widget.onSearch(query);
    
    // Add to recent searches
    context.read<RecentSearchesBloc>().add(AddRecentSearch(searchTerm: query));
  }
} 