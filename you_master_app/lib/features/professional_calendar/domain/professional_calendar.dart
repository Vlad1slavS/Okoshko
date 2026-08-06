enum CalendarAppointmentStatus {
  pendingConfirmation,
  confirmed,
  completed,
  cancelledByClient,
  cancelledByProfessional,
  noShow,
}

class CalendarAppointment {
  const CalendarAppointment({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.priceMinor,
    required this.currency,
  });

  final String id;
  final String clientName;
  final String serviceName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final CalendarAppointmentStatus status;
  final int priceMinor;
  final String currency;
}

class ProfessionalCalendar {
  const ProfessionalCalendar({
    required this.professionalId,
    required this.timezone,
    required this.appointments,
    this.availabilityStarts = const [],
  });

  final String professionalId;
  final String timezone;
  final List<CalendarAppointment> appointments;
  final List<CalendarAvailabilityStart> availabilityStarts;
}

class CalendarAvailabilityStart {
  const CalendarAvailabilityStart({
    required this.id,
    required this.date,
    required this.time,
    this.restrictedServiceName,
  });

  final String id;
  final DateTime date;
  final String time;
  final String? restrictedServiceName;
}
