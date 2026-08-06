package io.github.vlad1slavs.okoshko.appointment.api;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.util.UUID;

public record CalendarAppointmentResponse(
        UUID id,
        String clientName,
        String serviceName,
        OffsetDateTime startsAt,
        OffsetDateTime endsAt,
        LocalDate localDate,
        LocalTime localStartTime,
        LocalTime localEndTime,
        String status,
        long priceMinor,
        String currency
) {
}
