package io.github.vlad1slavs.okoshko.professional.api;

import io.github.vlad1slavs.okoshko.professional.application.ProfessionalQueryService;
import io.github.vlad1slavs.okoshko.service.api.ServiceResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestParam;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import org.springframework.validation.annotation.Validated;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/professionals")
@Validated
public class ProfessionalController {

    private final ProfessionalQueryService queryService;

    public ProfessionalController(ProfessionalQueryService queryService) {
        this.queryService = queryService;
    }

    @GetMapping
    ProfessionalPageResponse searchProfessionals(
            @RequestParam @NotBlank String city,
            @RequestParam(defaultValue = "") String category,
            @RequestParam(defaultValue = "") String query,
            @RequestParam(defaultValue = "0")
            @DecimalMin("0.0") @DecimalMax("5.0") BigDecimal minimumRating,
            @RequestParam(defaultValue = "RECOMMENDED") ProfessionalSort sort,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(50) int size
    ) {
        return queryService.searchProfessionals(
                city, category, query, minimumRating, sort, page, size
        );
    }

    @GetMapping("/popular")
    List<ProfessionalPreviewResponse> getPopularProfessionals(
            @RequestParam @NotBlank String city,
            @RequestParam(defaultValue = "") String category,
            @RequestParam(defaultValue = "5") @Min(1) @Max(10) int limit
    ) {
        return queryService.searchProfessionals(
                city,
                category,
                "",
                BigDecimal.ZERO,
                ProfessionalSort.RECOMMENDED,
                0,
                limit
        ).items();
    }

    @GetMapping("/{professionalId}")
    ProfessionalResponse getProfessional(@PathVariable UUID professionalId) {
        return queryService.getProfessional(professionalId);
    }

    @GetMapping("/{professionalId}/services")
    List<ServiceResponse> getProfessionalServices(@PathVariable UUID professionalId) {
        return queryService.getProfessionalServices(professionalId);
    }

    @GetMapping("/by-slug/{slug}")
    ProfessionalResponse getProfessionalBySlug(@PathVariable String slug) {
        return queryService.getProfessionalBySlug(slug);
    }

    @GetMapping("/by-slug/{slug}/services")
    List<ServiceResponse> getProfessionalServicesBySlug(@PathVariable String slug) {
        return queryService.getProfessionalServicesBySlug(slug);
    }

    @GetMapping("/by-slug/{slug}/details")
    ProfessionalDetailsResponse getProfessionalDetailsBySlug(
            @PathVariable String slug
    ) {
        return queryService.getProfessionalDetailsBySlug(slug);
    }
}
