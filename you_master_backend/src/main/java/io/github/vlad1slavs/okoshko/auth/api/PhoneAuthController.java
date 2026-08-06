package io.github.vlad1slavs.okoshko.auth.api;

import io.github.vlad1slavs.okoshko.auth.application.PhoneAuthService;
import jakarta.validation.Valid;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import io.github.vlad1slavs.okoshko.auth.config.AuthProperties;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth/otp")
public class PhoneAuthController {
    private final PhoneAuthService service;
    private final AuthProperties properties;
    public PhoneAuthController(PhoneAuthService service, AuthProperties properties) { this.service = service; this.properties = properties; }

    @PostMapping("/request") @ResponseStatus(HttpStatus.CREATED)
    OtpRequestedResponse request(@Valid @RequestBody RequestOtpRequest request, HttpServletRequest http) {
        return service.request(request.phone(), http.getRemoteAddr());
    }

    @PostMapping("/verify")
    AuthTokenResponse verify(@Valid @RequestBody VerifyOtpRequest request, HttpServletRequest http, HttpServletResponse response) {
        var issued = service.verify(request.phone(), request.code(), http.getRemoteAddr(), http.getHeader("User-Agent"));
        response.addHeader(HttpHeaders.SET_COOKIE, refreshCookie(issued.refreshToken()).toString());
        return new AuthTokenResponse(issued.accessToken(), issued.expiresInSeconds(), issued.user());
    }

    private ResponseCookie refreshCookie(String token) {
        return ResponseCookie.from("okoshko_refresh", token).httpOnly(true).secure(properties.cookieSecure())
                .sameSite(properties.cookieSameSite()).path("/api/v1/auth").maxAge(properties.refreshTokenTtl()).build();
    }
}
