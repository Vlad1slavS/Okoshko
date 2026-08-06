package io.github.vlad1slavs.okoshko.auth.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.Duration;

@Validated
@ConfigurationProperties("app.auth")
public record AuthProperties(
        @NotBlank @Size(min = 32) String otpPepper,
        @NotBlank @Size(min = 32) String jwtSecret,
        Duration otpTtl,
        Duration resendDelay,
        Duration accessTokenTtl,
        Duration refreshTokenTtl,
        boolean exposeDevCode,
        boolean cookieSecure,
        String cookieSameSite
) {}
