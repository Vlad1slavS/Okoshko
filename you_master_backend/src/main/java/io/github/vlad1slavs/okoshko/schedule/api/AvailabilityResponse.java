package io.github.vlad1slavs.okoshko.schedule.api;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

public record AvailabilityResponse(
        UUID professionalId,
        String timezone,
        List<AvailabilityDate> dates
) {
    public record AvailabilityDate(LocalDate date, List<AvailabilityStart> starts) {
    }

    public record AvailabilityStart(
            UUID id,
            LocalTime time,
            UUID restrictedServiceId,
            String restrictedServiceName
    ) {
    }
}
