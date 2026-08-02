import 'package:flutter/foundation.dart';
import 'package:you_master_app/features/client_home/domain/home_category.dart';

@immutable
class ClientHomeState {
  const ClientHomeState({
    this.searchDraft = '',
    this.category = HomeCategory.all,
  });

  final String searchDraft;
  final HomeCategory category;

  ClientHomeState copyWith({String? searchDraft, HomeCategory? category}) {
    return ClientHomeState(
      searchDraft: searchDraft ?? this.searchDraft,
      category: category ?? this.category,
    );
  }
}
