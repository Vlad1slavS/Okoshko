package io.github.vlad1slavs.okoshko.professional.api;

import java.math.BigDecimal;
import java.util.List;

public record ProfessionalPreviewResponse(
        String slug,
        String displayName,
        String description,
        String avatarUrl,
        BigDecimal rating,
        int reviewsCount,
        long priceFromMinor,
        int durationFromMinutes,
        int durationToMinutes,
        List<String> categorySlugs,
        BigDecimal distanceKm
) {
}
