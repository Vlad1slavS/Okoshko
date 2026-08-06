import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/core/network/api_retry_policy.dart';
import 'package:you_master_app/features/auth/presentation/state/auth_provider_guard.dart';
import 'package:you_master_app/features/appointments/data/appointments_repository.dart';
import 'package:you_master_app/features/appointments/domain/appointment.dart';
import 'package:you_master_app/features/appointments/presentation/state/appointments_state.dart';

final appointmentsRepositoryProvider = Provider<AppointmentsRepository>(
  (ref) => const MockAppointmentsRepository(),
);

final appointmentsControllerProvider =
    AsyncNotifierProvider<AppointmentsController, AppointmentsState>(
      AppointmentsController.new,
      retry: ApiRetryPolicy.transientErrors,
    );

final appointmentsSelectedTabProvider =
    NotifierProvider<AppointmentsSelectedTabController, AppointmentsTab>(
      AppointmentsSelectedTabController.new,
    );

class AppointmentsSelectedTabController extends Notifier<AppointmentsTab> {
  @override
  AppointmentsTab build() => AppointmentsTab.upcoming;

  void select(AppointmentsTab tab) => state = tab;
}

class AppointmentsController extends AsyncNotifier<AppointmentsState> {
  static const _pageSize = 20;

  @override
  Future<AppointmentsState> build() {
    requireAuthenticatedUser(ref);
    return _load(AppointmentsTab.upcoming);
  }

  Future<void> selectTab(AppointmentsTab tab) async {
    if (ref.read(appointmentsSelectedTabProvider) == tab) return;
    ref.read(appointmentsSelectedTabProvider.notifier).select(tab);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(tab));
  }

  Future<void> refresh() async {
    final tab = ref.read(appointmentsSelectedTabProvider);
    state = await AsyncValue.guard(() => _load(tab));
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null ||
        current.isLoadingMore ||
        !current.hasNextPage ||
        current.nextPage == null) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await ref
          .read(appointmentsRepositoryProvider)
          .getAppointments(
            tab: current.selectedTab,
            page: current.nextPage!,
            pageSize: _pageSize,
          );
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items],
          hasNextPage: page.hasNextPage,
          nextPage: page.nextPage,
          clearNextPage: page.nextPage == null,
          isLoadingMore: false,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<AppointmentsState> _load(AppointmentsTab tab) async {
    final page = await ref
        .read(appointmentsRepositoryProvider)
        .getAppointments(tab: tab, page: 1, pageSize: _pageSize);
    return AppointmentsState(
      selectedTab: tab,
      items: page.items,
      hasNextPage: page.hasNextPage,
      nextPage: page.nextPage,
    );
  }
}
