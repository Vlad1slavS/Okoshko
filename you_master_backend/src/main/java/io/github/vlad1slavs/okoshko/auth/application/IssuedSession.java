package io.github.vlad1slavs.okoshko.auth.application;

import io.github.vlad1slavs.okoshko.auth.api.AuthUserResponse;

public record IssuedSession(String accessToken, String refreshToken, long expiresInSeconds, AuthUserResponse user) {}
