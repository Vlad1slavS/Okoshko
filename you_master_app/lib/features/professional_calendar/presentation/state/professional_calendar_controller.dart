import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/core/network/api_retry_policy.dart';
import 'package:you_master_app/core/network/network_providers.dart';
import 'package:you_master_app/features/auth/presentation/state/auth_provider_guard.dart';
import 'package:you_master_app/features/professional_calendar/data/professional_calendar_repository.dart';
import 'package:you_master_app/features/professional_calendar/domain/professional_calendar.dart';

const demoProfessionalId = '20000000-0000-0000-0000-000000000001';

class ProfessionalCalendarState {
  const ProfessionalCalendarState({
    required this.month,
    required this.selectedDate,
    required this.calendar,
  });

  final DateTime month;
  final DateTime selectedDate;
  final ProfessionalCalendar calendar;

  List<CalendarAppointment> get selectedAppointments => calendar.appointments
      .where((item) => _sameDay(item.date, selectedDate))
      .toList(growable: false);

  List<CalendarAvailabilityStart> get selectedAvailabilityStarts => calendar
      .availabilityStarts
      .where((item) => _sameDay(item.date, selectedDate))
      .toList(growable: false);

  ProfessionalCalendarState copyWith({DateTime? selectedDate}) {
    return ProfessionalCalendarState(
      month: month,
      selectedDate: selectedDate ?? this.selectedDate,
      calendar: calendar,
    );
  }

  static bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

final professionalCalendarRepositoryProvider =
    Provider<ProfessionalCalendarRepository>(
      (ref) =>
          BackendProfessionalCalendarRepository(ref.watch(apiClientProvider)),
    );

final professionalCalendarControllerProvider =
    AsyncNotifierProvider<
      ProfessionalCalendarController,
      ProfessionalCalendarState
    >(
      ProfessionalCalendarController.new,
      retry: ApiRetryPolicy.transientErrors,
    );

class ProfessionalCalendarController
    extends AsyncNotifier<ProfessionalCalendarState> {
  @override
  Future<ProfessionalCalendarState> build() {
    requireAuthenticatedUser(ref, professional: true);
    return _load(DateTime.now());
  }

  Future<void> changeMonth(int delta) async {
    final current = state.value;
    if (current == null) return;
    final month = DateTime(current.month.year, current.month.month + delta);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(month));
  }

  void selectDate(DateTime date) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedDate: date));
  }

  Future<void> refresh() async {
    final month = state.value?.month ?? DateTime.now();
    state = await AsyncValue.guard(() => _load(month));
  }

  Future<ProfessionalCalendarState> _load(DateTime value) async {
    final month = DateTime(value.year, value.month);
    final calendar = await ref
        .read(professionalCalendarRepositoryProvider)
        .getMonth(professionalId: demoProfessionalId, month: month);
    final now = DateTime.now();
    final selected = now.year == month.year && now.month == month.month
        ? DateTime(now.year, now.month, now.day)
        : month;
    return ProfessionalCalendarState(
      month: month,
      selectedDate: selected,
      calendar: calendar,
    );
  }
}
