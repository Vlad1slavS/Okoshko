package io.github.vlad1slavs.okoshko.schedule.api;

import io.github.vlad1slavs.okoshko.schedule.application.ProfessionalAvailabilityService;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.UUID;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import io.github.vlad1slavs.okoshko.professional.application.ProfessionalAccessService;

@RestController
@RequestMapping("/api/v1/professionals/{professionalId}/availability-starts")
public class ProfessionalAvailabilityController {

    private final ProfessionalAvailabilityService service;
    private final ProfessionalAccessService access;

    public ProfessionalAvailabilityController(ProfessionalAvailabilityService service, ProfessionalAccessService access) {
        this.service = service;
        this.access = access;
    }

    @GetMapping
    AvailabilityResponse getAvailability(
            @PathVariable UUID professionalId,
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to
    ) {
        access.assertOwner(professionalId, jwt.getSubject());
        return service.getAvailability(professionalId, from, to);
    }

    @PutMapping
    AvailabilityResponse replaceAvailability(
            @PathVariable UUID professionalId,
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody SaveAvailabilityRequest request
    ) {
        access.assertOwner(professionalId, jwt.getSubject());
        return service.replaceAvailability(professionalId, request);
    }
}
