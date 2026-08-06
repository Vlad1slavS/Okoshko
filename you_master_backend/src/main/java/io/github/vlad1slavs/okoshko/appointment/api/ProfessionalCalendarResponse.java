package io.github.vlad1slavs.okoshko.appointment.api;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public record ProfessionalCalendarResponse(
        UUID professionalId,
        LocalDate from,
        LocalDate to,
        String timezone,
        List<CalendarAppointmentResponse> appointments
) {
}
