package io.github.vlad1slavs.okoshko.favorite.api;

import io.github.vlad1slavs.okoshko.professional.api.ProfessionalPreviewResponse;

import java.util.List;

public record FavoriteProfessionalsPageResponse(
        List<ProfessionalPreviewResponse> items,
        int page,
        int size,
        long totalItems,
        boolean hasNext
) {
}
