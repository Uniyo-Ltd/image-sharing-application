import 'package:equatable/equatable.dart';

abstract class RecentSearchesEvent extends Equatable {
  const RecentSearchesEvent();
  
  @override
  List<Object> get props => [];
}


class LoadRecentSearches extends RecentSearchesEvent {
  const LoadRecentSearches();
}


class AddRecentSearch extends RecentSearchesEvent {
  final String searchTerm;
  
  const AddRecentSearch({required this.searchTerm});
  
  @override
  List<Object> get props => [searchTerm];
}


class RemoveRecentSearch extends RecentSearchesEvent {
  final String searchTerm;
  
  const RemoveRecentSearch({required this.searchTerm});
  
  @override
  List<Object> get props => [searchTerm];
}


class ClearRecentSearches extends RecentSearchesEvent {
  const ClearRecentSearches();
} 