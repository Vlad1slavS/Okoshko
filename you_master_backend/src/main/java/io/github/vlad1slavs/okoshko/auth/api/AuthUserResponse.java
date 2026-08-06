package io.github.vlad1slavs.okoshko.auth.api;

import java.util.UUID;

public record AuthUserResponse(
        UUID id,
        String phone,
        String email,
        String displayName,
        boolean hasClientProfile,
        boolean hasProfessionalProfile
) {}
