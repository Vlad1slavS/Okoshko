package io.github.vlad1slavs.okoshko.auth.api;

import io.github.vlad1slavs.okoshko.auth.application.AuthSessionService;
import io.github.vlad1slavs.okoshko.auth.application.IssuedSession;
import io.github.vlad1slavs.okoshko.auth.config.AuthProperties;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.time.Duration;
import java.util.Objects;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthSessionController {
    private final AuthSessionService sessions;
    private final AuthProperties properties;
    public AuthSessionController(AuthSessionService sessions, AuthProperties properties) { this.sessions = sessions; this.properties = properties; }

    @PostMapping("/refresh")
    AuthTokenResponse refresh(@CookieValue("okoshko_refresh") String token, HttpServletRequest request, HttpServletResponse response) {
        var issued = sessions.refresh(token, request.getRemoteAddr(), request.getHeader("User-Agent"));
        setCookie(response, issued);
        return response(issued);
    }

    @PostMapping("/logout")
    java.util.Map<String, String> logout(@CookieValue(value = "okoshko_refresh", required = false) String token, HttpServletResponse response) {
        if (token != null) sessions.logout(token);
        clearCookie(response);
        return java.util.Map.of("status", "logged_out");
    }

    @PostMapping("/logout-all")
    java.util.Map<String, String> logoutAll(@AuthenticationPrincipal Jwt jwt, HttpServletResponse response) {
        sessions.logoutAll(UUID.fromString(Objects.requireNonNull(jwt.getSubject())));
        clearCookie(response);
        return java.util.Map.of("status", "logged_out");
    }

    @GetMapping("/me")
    AuthUserResponse me(@AuthenticationPrincipal Jwt jwt) { return sessions.currentUser(UUID.fromString(Objects.requireNonNull(jwt.getSubject()))); }

    @PutMapping("/me/profile")
    AuthUserResponse completeProfile(
            @AuthenticationPrincipal Jwt jwt,
            @jakarta.validation.Valid @RequestBody CompleteProfileRequest request
    ) {
        return sessions.completeProfile(UUID.fromString(Objects.requireNonNull(jwt.getSubject())), request.firstName(), request.lastName());
    }

    private AuthTokenResponse response(IssuedSession issued) { return new AuthTokenResponse(issued.accessToken(), issued.expiresInSeconds(), issued.user()); }
    private void setCookie(HttpServletResponse response, IssuedSession issued) {
        response.addHeader(HttpHeaders.SET_COOKIE, cookie(issued.refreshToken(), properties.refreshTokenTtl()).toString());
    }
    private void clearCookie(HttpServletResponse response) {
        response.addHeader(HttpHeaders.SET_COOKIE, cookie("", Duration.ZERO).toString());
    }
    private ResponseCookie cookie(String value, Duration age) {
        return ResponseCookie.from("okoshko_refresh", value).httpOnly(true).secure(properties.cookieSecure())
                .sameSite(properties.cookieSameSite()).path("/api/v1/auth").maxAge(age).build();
    }
}
