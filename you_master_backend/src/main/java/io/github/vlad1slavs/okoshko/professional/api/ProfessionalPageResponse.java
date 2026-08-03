package io.github.vlad1slavs.okoshko.professional.api;

import java.util.List;

public record ProfessionalPageResponse(
        List<ProfessionalPreviewResponse> items,
        int page,
        int size,
        long totalItems,
        boolean hasNext
) {
}
