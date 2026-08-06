package io.github.vlad1slavs.okoshko.auth.api;

public record OtpRequestedResponse(int expiresInSeconds, int resendAfterSeconds, String devCode) {}
