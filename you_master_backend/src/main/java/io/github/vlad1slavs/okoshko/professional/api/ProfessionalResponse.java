package io.github.vlad1slavs.okoshko.professional.api;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record ProfessionalResponse(
        UUID id,
        String slug,
        String displayName,
        String description,
        String avatarUrl,
        LocalDate experienceStartedOn,
        BigDecimal rating,
        int reviewsCount,
        int completedAppointmentsCount,
        BusinessSummary business,
        LocationSummary location
) {

    public record BusinessSummary(UUID id, String slug, String name, String type) {
    }

    public record LocationSummary(
            UUID id,
            String name,
            String city,
            String address,
            String timezone,
            BigDecimal latitude,
            BigDecimal longitude
    ) {
    }
}
