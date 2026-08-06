class ScheduleServiceOption {
  const ScheduleServiceOption({required this.id, required this.name});
  final String id;
  final String name;
}

class EditableAvailabilityStart {
  const EditableAvailabilityStart({
    required this.time,
    this.restrictedServiceId,
  });

  final TimeOfDayValue time;
  final String? restrictedServiceId;

  EditableAvailabilityStart copyWith({
    TimeOfDayValue? time,
    String? restrictedServiceId,
    bool clearRestriction = false,
  }) {
    return EditableAvailabilityStart(
      time: time ?? this.time,
      restrictedServiceId: clearRestriction
          ? null
          : restrictedServiceId ?? this.restrictedServiceId,
    );
  }
}

class TimeOfDayValue implements Comparable<TimeOfDayValue> {
  const TimeOfDayValue(this.hour, this.minute);
  final int hour;
  final int minute;

  String get label =>
      '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';

  @override
  int compareTo(TimeOfDayValue other) =>
      (hour * 60 + minute).compareTo(other.hour * 60 + other.minute);

  @override
  bool operator ==(Object other) =>
      other is TimeOfDayValue && hour == other.hour && minute == other.minute;

  @override
  int get hashCode => Object.hash(hour, minute);
}
