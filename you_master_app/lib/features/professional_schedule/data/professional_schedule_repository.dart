import 'package:you_master_app/core/network/api_client.dart';
import 'package:you_master_app/features/professional_schedule/domain/professional_schedule.dart';

abstract interface class ProfessionalScheduleRepository {
  Future<List<ScheduleServiceOption>> getServices(String professionalId);

  Future<void> saveStarts({
    required String professionalId,
    required Set<DateTime> dates,
    required List<EditableAvailabilityStart> starts,
  });
}

class BackendProfessionalScheduleRepository
    implements ProfessionalScheduleRepository {
  const BackendProfessionalScheduleRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ScheduleServiceOption>> getServices(String professionalId) async {
    final payload = await _apiClient.getList(
      '/api/v1/professionals/${Uri.encodeComponent(professionalId)}/services',
    );
    return payload
        .cast<Map<String, Object?>>()
        .map(
          (item) => ScheduleServiceOption(
            id: item['id']! as String,
            name: item['name']! as String,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveStarts({
    required String professionalId,
    required Set<DateTime> dates,
    required List<EditableAvailabilityStart> starts,
  }) async {
    await _apiClient.putObject(
      '/api/v1/professionals/${Uri.encodeComponent(professionalId)}/availability-starts',
      {
        'dates': [
          for (final date in dates)
            {
              'date': _date(date),
              'starts': [
                for (final start in starts)
                  {
                    'time': start.time.label,
                    'restrictedServiceId': start.restrictedServiceId,
                  },
              ],
            },
        ],
      },
    );
  }

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
