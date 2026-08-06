package io.github.vlad1slavs.okoshko.schedule.api;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

public record SaveAvailabilityRequest(
        @NotEmpty @Size(max = 31) List<@Valid DateAvailability> dates
) {
    public record DateAvailability(
            @NotNull LocalDate date,
            @NotNull @Size(max = 32) List<@Valid AvailabilityStart> starts
    ) {
    }

    public record AvailabilityStart(
            @NotNull LocalTime time,
            UUID restrictedServiceId
    ) {
    }
}
