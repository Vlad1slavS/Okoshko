import 'package:flutter/foundation.dart';
import 'package:you_master_app/features/appointments/domain/appointment.dart';

@immutable
class AppointmentsState {
  const AppointmentsState({
    required this.selectedTab,
    required this.items,
    required this.hasNextPage,
    required this.nextPage,
    this.isLoadingMore = false,
  });

  final AppointmentsTab selectedTab;
  final List<Appointment> items;
  final bool hasNextPage;
  final int? nextPage;
  final bool isLoadingMore;

  AppointmentsState copyWith({
    List<Appointment>? items,
    bool? hasNextPage,
    int? nextPage,
    bool clearNextPage = false,
    bool? isLoadingMore,
  }) {
    return AppointmentsState(
      selectedTab: selectedTab,
      items: items ?? this.items,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      nextPage: clearNextPage ? null : nextPage ?? this.nextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
