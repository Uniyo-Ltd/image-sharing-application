import 'package:equatable/equatable.dart';

enum RecentSearchesStatus { initial, loading, loaded, error }

class RecentSearchesState extends Equatable {
  final RecentSearchesStatus status;
  final List<String> searches;
  final String? error;
  
  const RecentSearchesState({
    this.status = RecentSearchesStatus.initial,
    this.searches = const <String>[],
    this.error,
  });
  
  RecentSearchesState copyWith({
    RecentSearchesStatus? status,
    List<String>? searches,
    String? error,
  }) {
    return RecentSearchesState(
      status: status ?? this.status,
      searches: searches ?? this.searches,
      error: error,
    );
  }
  
  @override
  List<Object?> get props => [status, searches, error];
}

class RecentSearchesInitial extends RecentSearchesState {
  const RecentSearchesInitial();
}

class RecentSearchesLoading extends RecentSearchesState {
  const RecentSearchesLoading();
}

class RecentSearchesLoaded extends RecentSearchesState {
  final List<String> searches;
  
  const RecentSearchesLoaded({required this.searches});
  
  @override
  List<Object?> get props => [searches];
}

class RecentSearchesError extends RecentSearchesState {
  final String message;
  
  const RecentSearchesError({required this.message});
  
  @override
  List<Object?> get props => [message];
} 