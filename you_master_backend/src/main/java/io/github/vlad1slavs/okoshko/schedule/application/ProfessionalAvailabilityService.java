package io.github.vlad1slavs.okoshko.schedule.application;

import io.github.vlad1slavs.okoshko.schedule.api.AvailabilityResponse;
import io.github.vlad1slavs.okoshko.schedule.api.SaveAvailabilityRequest;
import io.github.vlad1slavs.okoshko.schedule.data.ProfessionalAvailabilityRepository;
import io.github.vlad1slavs.okoshko.schedule.data.ProfessionalAvailabilityRepository.NewAvailabilityStart;
import io.github.vlad1slavs.okoshko.shared.error.ResourceNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.UUID;

@Service
public class ProfessionalAvailabilityService {

    private static final int MAX_RANGE_DAYS = 42;

    private final ProfessionalAvailabilityRepository repository;

    public ProfessionalAvailabilityService(ProfessionalAvailabilityRepository repository) {
        this.repository = repository;
    }

    @Transactional(readOnly = true)
    public AvailabilityResponse getAvailability(
            UUID professionalId,
            LocalDate from,
            LocalDate to
    ) {
        validateRange(from, to);
        var context = findContext(professionalId);
        return load(professionalId, from, to, context);
    }

    @Transactional
    public AvailabilityResponse replaceAvailability(
            UUID professionalId,
            SaveAvailabilityRequest request
    ) {
        var context = findContext(professionalId);
        var activeServices = repository.findActiveServiceIds(professionalId);
        var uniqueDates = new LinkedHashSet<LocalDate>();

        for (var day : request.dates()) {
            if (!uniqueDates.add(day.date())) {
                throw new IllegalArgumentException("Дата не должна повторяться в запросе");
            }
            var uniqueTimes = new LinkedHashSet<java.time.LocalTime>();
            var starts = new ArrayList<NewAvailabilityStart>();
            for (var start : day.starts()) {
                if (!uniqueTimes.add(start.time())) {
                    throw new IllegalArgumentException("Время не должно повторяться в пределах даты");
                }
                if (start.restrictedServiceId() != null
                        && !activeServices.contains(start.restrictedServiceId())) {
                    throw new IllegalArgumentException("Услуга недоступна этому мастеру");
                }
                var startsAt = day.date().atTime(start.time())
                        .atZone(context.zone())
                        .toOffsetDateTime();
                if (repository.overlapsActiveAppointment(professionalId, startsAt)) {
                    throw new IllegalArgumentException(
                            "Окно пересекается с существующей записью: " + day.date() + " " + start.time()
                    );
                }
                starts.add(new NewAvailabilityStart(startsAt, start.restrictedServiceId()));
            }

            var from = day.date().atStartOfDay(context.zone()).toOffsetDateTime();
            var toExclusive = day.date().plusDays(1).atStartOfDay(context.zone()).toOffsetDateTime();
            repository.replaceDate(
                    professionalId,
                    context.locationId(),
                    from,
                    toExclusive,
                    starts
            );
        }

        var from = request.dates().stream().map(SaveAvailabilityRequest.DateAvailability::date)
                .min(LocalDate::compareTo).orElseThrow();
        var to = request.dates().stream().map(SaveAvailabilityRequest.DateAvailability::date)
                .max(LocalDate::compareTo).orElseThrow();
        validateRange(from, to);
        return load(professionalId, from, to, context);
    }

    private AvailabilityResponse load(
            UUID professionalId,
            LocalDate from,
            LocalDate to,
            ProfessionalAvailabilityRepository.ScheduleContext context
    ) {
        var fromInstant = from.atStartOfDay(context.zone()).toOffsetDateTime();
        var toExclusive = to.plusDays(1).atStartOfDay(context.zone()).toOffsetDateTime();
        var grouped = new LinkedHashMap<LocalDate, List<AvailabilityResponse.AvailabilityStart>>();

        repository.findStarts(professionalId, fromInstant, toExclusive, context.zone())
                .forEach(start -> grouped.computeIfAbsent(start.date(), ignored -> new ArrayList<>())
                        .add(new AvailabilityResponse.AvailabilityStart(
                                start.id(),
                                start.time(),
                                start.restrictedServiceId(),
                                start.restrictedServiceName()
                        )));

        var dates = grouped.entrySet().stream()
                .map(entry -> new AvailabilityResponse.AvailabilityDate(entry.getKey(), entry.getValue()))
                .toList();
        return new AvailabilityResponse(
                professionalId,
                context.zone().getId(),
                dates
        );
    }

    private ProfessionalAvailabilityRepository.ScheduleContext findContext(UUID professionalId) {
        return repository.findContext(professionalId)
                .orElseThrow(() -> new ResourceNotFoundException("Расписание мастера не найдено"));
    }

    private void validateRange(LocalDate from, LocalDate to) {
        if (to.isBefore(from)) {
            throw new IllegalArgumentException("Параметр to не может быть раньше from");
        }
        if (ChronoUnit.DAYS.between(from, to) + 1 > MAX_RANGE_DAYS) {
            throw new IllegalArgumentException("Диапазон расписания не может превышать 42 дня");
        }
    }
}
