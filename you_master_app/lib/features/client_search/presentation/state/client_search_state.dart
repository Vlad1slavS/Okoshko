import 'package:flutter/foundation.dart';
import 'package:you_master_app/features/client_home/domain/home_category.dart';

enum SearchSort {
  recommended('По рекомендации'),
  rating('По рейтингу'),
  distance('Сначала рядом'),
  price('Сначала дешевле');

  const SearchSort(this.label);

  final String label;
}

@immutable
class ClientSearchState {
  const ClientSearchState({
    this.query = '',
    this.queryDraft = '',
    this.category = HomeCategory.all,
    this.sort = SearchSort.recommended,
    this.availableToday = false,
    this.minimumRating = 0,
  });

  final String query;
  final String queryDraft;
  final HomeCategory category;
  final SearchSort sort;
  final bool availableToday;
  final double minimumRating;

  ClientSearchState copyWith({
    String? query,
    String? queryDraft,
    HomeCategory? category,
    SearchSort? sort,
    bool? availableToday,
    double? minimumRating,
  }) {
    return ClientSearchState(
      query: query ?? this.query,
      queryDraft: queryDraft ?? this.queryDraft,
      category: category ?? this.category,
      sort: sort ?? this.sort,
      availableToday: availableToday ?? this.availableToday,
      minimumRating: minimumRating ?? this.minimumRating,
    );
  }
}
