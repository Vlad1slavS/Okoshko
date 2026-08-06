package io.github.vlad1slavs.okoshko.favorite.api;

import io.github.vlad1slavs.okoshko.favorite.application.FavoriteProfessionalService;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@Validated
@RestController
@RequestMapping("/api/v1/me/favorites")
public class FavoriteProfessionalController {
    private final FavoriteProfessionalService service;

    public FavoriteProfessionalController(FavoriteProfessionalService service) {
        this.service = service;
    }

    @GetMapping("/ids")
    FavoriteIdsResponse ids(@AuthenticationPrincipal Jwt jwt) {
        return service.ids(userId(jwt));
    }

    @GetMapping
    FavoriteProfessionalsPageResponse page(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(50) int size
    ) {
        return service.page(userId(jwt), page, size);
    }

    @PutMapping("/{professionalId}")
    FavoriteStateResponse add(@AuthenticationPrincipal Jwt jwt, @PathVariable String professionalId) {
        return service.add(userId(jwt), professionalId);
    }

    @DeleteMapping("/{professionalId}")
    FavoriteStateResponse remove(@AuthenticationPrincipal Jwt jwt, @PathVariable String professionalId) {
        return service.remove(userId(jwt), professionalId);
    }

    private UUID userId(Jwt jwt) {
        return UUID.fromString(jwt.getSubject());
    }
}
