package io.github.vlad1slavs.okoshko.appointment.api;

import io.github.vlad1slavs.okoshko.appointment.application.ProfessionalCalendarService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.UUID;
import io.github.vlad1slavs.okoshko.professional.application.ProfessionalAccessService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;

@RestController
@RequestMapping("/api/v1/professionals/{professionalId}/calendar")
public class ProfessionalCalendarController {

    private final ProfessionalCalendarService service;
    private final ProfessionalAccessService access;

    public ProfessionalCalendarController(ProfessionalCalendarService service, ProfessionalAccessService access) {
        this.service = service;
        this.access = access;
    }

    @GetMapping
    ProfessionalCalendarResponse getCalendar(
            @PathVariable UUID professionalId,
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to
    ) {
        access.assertOwner(professionalId, jwt.getSubject());
        return service.getCalendar(professionalId, from, to);
    }
}
