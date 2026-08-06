import 'package:you_master_app/core/network/api_client.dart';
import 'package:you_master_app/features/professional_calendar/domain/professional_calendar.dart';

abstract interface class ProfessionalCalendarRepository {
  Future<ProfessionalCalendar> getMonth({
    required String professionalId,
    required DateTime month,
  });
}

class BackendProfessionalCalendarRepository
    implements ProfessionalCalendarRepository {
  const BackendProfessionalCalendarRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ProfessionalCalendar> getMonth({
    required String professionalId,
    required DateTime month,
  }) async {
    final firstDay = DateTime(month.year, month.month);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final query = Uri(
      queryParameters: {'from': _date(firstDay), 'to': _date(lastDay)},
    ).query;
    final encodedId = Uri.encodeComponent(professionalId);
    final responses = await Future.wait([
      _apiClient.getObject('/api/v1/professionals/$encodedId/calendar?$query'),
      _apiClient.getObject(
        '/api/v1/professionals/$encodedId/availability-starts?$query',
      ),
    ]);
    final payload = responses[0];
    final availabilityPayload = responses[1];
    final items = payload['appointments']! as List<Object?>;

    return ProfessionalCalendar(
      professionalId: payload['professionalId']! as String,
      timezone: payload['timezone']! as String,
      appointments: items
          .cast<Map<String, Object?>>()
          .map(_mapAppointment)
          .toList(growable: false),
      availabilityStarts: _mapAvailability(availabilityPayload),
    );
  }

  List<CalendarAvailabilityStart> _mapAvailability(
    Map<String, Object?> payload,
  ) {
    final dates = payload['dates']! as List<Object?>;
    return [
      for (final datePayload in dates.cast<Map<String, Object?>>())
        for (final start
            in (datePayload['starts']! as List<Object?>)
                .cast<Map<String, Object?>>())
          CalendarAvailabilityStart(
            id: start['id']! as String,
            date: DateTime.parse(datePayload['date']! as String),
            time: _shortTime(start['time']! as String),
            restrictedServiceName: start['restrictedServiceName'] as String?,
          ),
    ];
  }

  CalendarAppointment _mapAppointment(Map<String, Object?> payload) {
    return CalendarAppointment(
      id: payload['id']! as String,
      clientName: payload['clientName']! as String,
      serviceName: payload['serviceName']! as String,
      date: DateTime.parse(payload['localDate']! as String),
      startTime: _shortTime(payload['localStartTime']! as String),
      endTime: _shortTime(payload['localEndTime']! as String),
      status: _status(payload['status']! as String),
      priceMinor: payload['priceMinor']! as int,
      currency: payload['currency']! as String,
    );
  }

  CalendarAppointmentStatus _status(String value) => switch (value) {
    'PENDING_CONFIRMATION' => CalendarAppointmentStatus.pendingConfirmation,
    'CONFIRMED' => CalendarAppointmentStatus.confirmed,
    'COMPLETED' => CalendarAppointmentStatus.completed,
    'CANCELLED_BY_CLIENT' => CalendarAppointmentStatus.cancelledByClient,
    'CANCELLED_BY_PROFESSIONAL' =>
      CalendarAppointmentStatus.cancelledByProfessional,
    'NO_SHOW' => CalendarAppointmentStatus.noShow,
    _ => throw FormatException('Unknown appointment status: $value'),
  };

  String _shortTime(String value) =>
      value.length >= 5 ? value.substring(0, 5) : value;

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
