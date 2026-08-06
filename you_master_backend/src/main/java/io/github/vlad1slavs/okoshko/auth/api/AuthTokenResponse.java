package io.github.vlad1slavs.okoshko.auth.api;

public record AuthTokenResponse(
        String accessToken,
        long expiresInSeconds,
        AuthUserResponse user
) {}
