import 'package:equatable/equatable.dart';

abstract class RecentSearchesEvent extends Equatable {
  const RecentSearchesEvent();
  
  @override
  List<Object> get props => [];
}

// Event to load recent searches
class LoadRecentSearches extends RecentSearchesEvent {
  const LoadRecentSearches();
}

// Event to add a search term to recent searches
class AddRecentSearch extends RecentSearchesEvent {
  final String searchTerm;
  
  const AddRecentSearch({required this.searchTerm});
  
  @override
  List<Object> get props => [searchTerm];
}

// Event to remove a specific search term
class RemoveRecentSearch extends RecentSearchesEvent {
  final String searchTerm;
  
  const RemoveRecentSearch({required this.searchTerm});
  
  @override
  List<Object> get props => [searchTerm];
}

// Event to clear all recent searches
class ClearRecentSearches extends RecentSearchesEvent {
  const ClearRecentSearches();
} 