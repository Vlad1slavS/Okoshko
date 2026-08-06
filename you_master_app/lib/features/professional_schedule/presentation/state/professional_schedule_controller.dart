import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/core/network/api_retry_policy.dart';
import 'package:you_master_app/core/network/network_providers.dart';
import 'package:you_master_app/features/professional_calendar/presentation/state/professional_calendar_controller.dart';
import 'package:you_master_app/features/professional_schedule/data/professional_schedule_repository.dart';
import 'package:you_master_app/features/professional_schedule/domain/professional_schedule.dart';

class ProfessionalScheduleState {
  const ProfessionalScheduleState({
    required this.selectedDates,
    required this.starts,
    required this.services,
    this.isSaving = false,
    this.saveError,
  });

  final Set<DateTime> selectedDates;
  final List<EditableAvailabilityStart> starts;
  final List<ScheduleServiceOption> services;
  final bool isSaving;
  final String? saveError;

  ProfessionalScheduleState copyWith({
    Set<DateTime>? selectedDates,
    List<EditableAvailabilityStart>? starts,
    bool? isSaving,
    String? saveError,
    bool clearSaveError = false,
  }) {
    return ProfessionalScheduleState(
      selectedDates: selectedDates ?? this.selectedDates,
      starts: starts ?? this.starts,
      services: services,
      isSaving: isSaving ?? this.isSaving,
      saveError: clearSaveError ? null : saveError ?? this.saveError,
    );
  }
}

final professionalScheduleRepositoryProvider =
    Provider<ProfessionalScheduleRepository>(
      (ref) =>
          BackendProfessionalScheduleRepository(ref.watch(apiClientProvider)),
    );

final professionalScheduleControllerProvider =
    AsyncNotifierProvider<
      ProfessionalScheduleController,
      ProfessionalScheduleState
    >(
      ProfessionalScheduleController.new,
      retry: ApiRetryPolicy.transientErrors,
    );

class ProfessionalScheduleController
    extends AsyncNotifier<ProfessionalScheduleState> {
  @override
  Future<ProfessionalScheduleState> build() async {
    final today = DateTime.now();
    final services = await ref
        .read(professionalScheduleRepositoryProvider)
        .getServices(demoProfessionalId);
    return ProfessionalScheduleState(
      selectedDates: {DateTime(today.year, today.month, today.day)},
      starts: const [
        EditableAvailabilityStart(time: TimeOfDayValue(9, 30)),
        EditableAvailabilityStart(time: TimeOfDayValue(12, 0)),
        EditableAvailabilityStart(time: TimeOfDayValue(14, 30)),
        EditableAvailabilityStart(time: TimeOfDayValue(17, 0)),
      ],
      services: services,
    );
  }

  void toggleDate(DateTime value) {
    final current = state.value;
    if (current == null) return;
    final date = DateTime(value.year, value.month, value.day);
    final dates = {...current.selectedDates};
    if (!dates.remove(date)) dates.add(date);
    state = AsyncData(current.copyWith(selectedDates: dates));
  }

  void addStart(TimeOfDayValue time) {
    final current = state.value;
    if (current == null || current.starts.any((item) => item.time == time)) {
      return;
    }
    final starts = [...current.starts, EditableAvailabilityStart(time: time)]
      ..sort((first, second) => first.time.compareTo(second.time));
    state = AsyncData(current.copyWith(starts: starts));
  }

  void removeStart(int index) {
    final current = state.value;
    if (current == null) return;
    final starts = [...current.starts]..removeAt(index);
    state = AsyncData(current.copyWith(starts: starts));
  }

  void restrictStart(int index, String? serviceId) {
    final current = state.value;
    if (current == null) return;
    final starts = [...current.starts];
    starts[index] = starts[index].copyWith(
      restrictedServiceId: serviceId,
      clearRestriction: serviceId == null,
    );
    state = AsyncData(current.copyWith(starts: starts));
  }

  Future<bool> save() async {
    final current = state.value;
    if (current == null ||
        current.selectedDates.isEmpty ||
        current.starts.isEmpty) {
      return false;
    }
    state = AsyncData(current.copyWith(isSaving: true, clearSaveError: true));
    try {
      await ref
          .read(professionalScheduleRepositoryProvider)
          .saveStarts(
            professionalId: demoProfessionalId,
            dates: current.selectedDates,
            starts: current.starts,
          );
      ref.invalidate(professionalCalendarControllerProvider);
      state = AsyncData(
        current.copyWith(isSaving: false, clearSaveError: true),
      );
      return true;
    } catch (error) {
      state = AsyncData(
        current.copyWith(isSaving: false, saveError: error.toString()),
      );
      return false;
    }
  }
}
