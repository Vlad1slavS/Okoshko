package io.github.vlad1slavs.okoshko.appointment.application;

import io.github.vlad1slavs.okoshko.appointment.api.ProfessionalCalendarResponse;
import io.github.vlad1slavs.okoshko.appointment.data.ProfessionalCalendarRepository;
import io.github.vlad1slavs.okoshko.shared.error.ResourceNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class ProfessionalCalendarService {

    private static final int MAX_RANGE_DAYS = 42;

    private final ProfessionalCalendarRepository repository;

    public ProfessionalCalendarService(ProfessionalCalendarRepository repository) {
        this.repository = repository;
    }

    public ProfessionalCalendarResponse getCalendar(
            UUID professionalId,
            LocalDate from,
            LocalDate to
    ) {
        validateRange(from, to);
        var timezone = repository.findTimezone(professionalId)
                .orElseThrow(() -> new ResourceNotFoundException("Календарь мастера не найден"));
        var zone = ZoneId.of(timezone);
        var fromInstant = from.atStartOfDay(zone).toOffsetDateTime();
        var toExclusive = to.plusDays(1).atStartOfDay(zone).toOffsetDateTime();
        var appointments = repository.findAppointments(
                professionalId,
                fromInstant,
                toExclusive,
                zone
        );

        return new ProfessionalCalendarResponse(
                professionalId,
                from,
                to,
                timezone,
                appointments
        );
    }

    private void validateRange(LocalDate from, LocalDate to) {
        if (to.isBefore(from)) {
            throw new IllegalArgumentException("Параметр to не может быть раньше from");
        }
        if (ChronoUnit.DAYS.between(from, to) + 1 > MAX_RANGE_DAYS) {
            throw new IllegalArgumentException("Диапазон календаря не может превышать 42 дня");
        }
    }
}
