package io.github.vlad1slavs.okoshko.auth.application;

import io.github.vlad1slavs.okoshko.auth.api.AuthUserResponse;
import io.github.vlad1slavs.okoshko.auth.config.AuthProperties;
import io.github.vlad1slavs.okoshko.auth.data.RefreshSessionRepository;
import io.github.vlad1slavs.okoshko.auth.domain.RefreshSession;
import io.github.vlad1slavs.okoshko.identity.data.ClientProfileRepository;
import io.github.vlad1slavs.okoshko.identity.data.UserAccountRepository;
import io.github.vlad1slavs.okoshko.identity.domain.UserAccount;
import io.github.vlad1slavs.okoshko.identity.domain.ClientProfile;
import io.github.vlad1slavs.okoshko.professional.data.ProfessionalProfileRepository;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Clock;
import java.util.Base64;
import java.util.HexFormat;
import java.util.UUID;

@Service
public class AuthSessionService {
    private static final SecureRandom RANDOM = new SecureRandom();
    private final RefreshSessionRepository sessions;
    private final UserAccountRepository users;
    private final ClientProfileRepository clients;
    private final ProfessionalProfileRepository professionals;
    private final JwtEncoder jwtEncoder;
    private final AuthProperties properties;
    private final Clock clock;

    public AuthSessionService(RefreshSessionRepository sessions, UserAccountRepository users,
                              ClientProfileRepository clients, ProfessionalProfileRepository professionals,
                              JwtEncoder jwtEncoder, AuthProperties properties, Clock clock) {
        this.sessions = sessions; this.users = users; this.clients = clients; this.professionals = professionals;
        this.jwtEncoder = jwtEncoder; this.properties = properties; this.clock = clock;
    }

    @Transactional
    public IssuedSession create(UserAccount user, String ip, String userAgent) {
        return issue(user, UUID.randomUUID(), ip, userAgent);
    }

    @Transactional(noRollbackFor = InvalidRefreshTokenException.class)
    public IssuedSession refresh(String rawToken, String ip, String userAgent) {
        var now = clock.instant();
        var current = sessions.findByTokenHash(hash(rawToken))
                .orElseThrow(() -> new InvalidRefreshTokenException("Сессия не найдена"));
        if (!current.isUsable(now)) {
            sessions.revokeFamily(current.getFamilyId(), now);
            throw new InvalidRefreshTokenException("Сессия истекла или была отозвана");
        }
        var replacement = issue(current.getUser(), current.getFamilyId(), ip, userAgent);
        var replacementEntity = sessions.findByTokenHash(hash(replacement.refreshToken())).orElseThrow();
        current.rotateTo(replacementEntity, now);
        return replacement;
    }

    @Transactional
    public void logout(String rawToken) {
        sessions.findByTokenHash(hash(rawToken)).ifPresent(session -> session.revoke(clock.instant()));
    }

    @Transactional
    public void logoutAll(UUID userId) { sessions.revokeAllForUser(userId, clock.instant()); }

    @Transactional(readOnly = true)
    public AuthUserResponse currentUser(UUID userId) {
        return toUser(users.findById(userId).orElseThrow(() -> new InvalidRefreshTokenException("Пользователь не найден")));
    }

    @Transactional
    public AuthUserResponse completeProfile(UUID userId, String firstName, String lastName) {
        var user = users.findById(userId)
                .orElseThrow(() -> new InvalidRefreshTokenException("Пользователь не найден"));
        var normalizedFirstName = normalizeRequired(firstName);
        var normalizedLastName = normalizeOptional(lastName);
        var profile = clients.findById(userId).orElseGet(() -> new ClientProfile(user, normalizedFirstName, normalizedLastName));
        profile.updateName(normalizedFirstName, normalizedLastName);
        clients.save(profile);
        return toUser(user);
    }

    private IssuedSession issue(UserAccount user, UUID familyId, String ip, String userAgent) {
        var now = clock.instant();
        var rawRefresh = randomToken();
        sessions.saveAndFlush(new RefreshSession(user, hash(rawRefresh), familyId, ip, trim(userAgent), now,
                now.plus(properties.refreshTokenTtl())));
        var professional = professionals.existsByUserId(user.getId());
        var claims = JwtClaimsSet.builder().issuer("okoshko-api").audience(java.util.List.of("okoshko-app"))
                .issuedAt(now).expiresAt(now.plus(properties.accessTokenTtl())).subject(user.getId().toString())
                .claim("roles", professional ? new String[]{"CLIENT", "PROFESSIONAL"} : new String[]{"CLIENT"}).build();
        var access = jwtEncoder.encode(JwtEncoderParameters.from(JwsHeader.with(MacAlgorithm.HS256).build(), claims)).getTokenValue();
        return new IssuedSession(access, rawRefresh, properties.accessTokenTtl().toSeconds(), toUser(user));
    }

    private AuthUserResponse toUser(UserAccount user) {
        var client = clients.findById(user.getId());
        return new AuthUserResponse(user.getId(), user.getPhone(), user.getEmail(),
                client.map(ClientProfile::getDisplayName).orElse(null), client.isPresent(),
                professionals.existsByUserId(user.getId()));
    }

    private String randomToken() { var bytes = new byte[32]; RANDOM.nextBytes(bytes); return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes); }
    private String hash(String value) {
        try { return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8))); }
        catch (Exception exception) { throw new IllegalStateException(exception); }
    }
    private String trim(String value) { return value == null ? null : value.substring(0, Math.min(300, value.length())); }
    private String normalizeRequired(String value) {
        var result = value.trim().replaceAll("\\s+", " ");
        if (result.isBlank()) throw new IllegalArgumentException("Укажите имя");
        return result;
    }
    private String normalizeOptional(String value) {
        if (value == null || value.isBlank()) return null;
        return value.trim().replaceAll("\\s+", " ");
    }
}
