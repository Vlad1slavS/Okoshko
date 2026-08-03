package io.github.vlad1slavs.okoshko.service.api;

import java.util.UUID;

public record ServiceResponse(
        UUID id,
        UUID categoryId,
        String categoryName,
        String name,
        String description,
        int durationMinutes,
        int bufferBeforeMinutes,
        int bufferAfterMinutes,
        long priceMinor,
        String currency
) {
}
