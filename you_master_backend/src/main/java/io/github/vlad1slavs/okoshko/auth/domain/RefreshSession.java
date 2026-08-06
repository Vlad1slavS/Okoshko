package io.github.vlad1slavs.okoshko.auth.domain;

import io.github.vlad1slavs.okoshko.identity.domain.UserAccount;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

@Getter
@Entity
@Table(name = "auth_refresh_sessions")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class RefreshSession {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private UUID id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "user_id") private UserAccount user;
    @Column(name = "token_hash", nullable = false, unique = true, length = 64) private String tokenHash;
    @Column(name = "expires_at", nullable = false) private Instant expiresAt;
    @Column(name = "revoked_at") private Instant revokedAt;
    @Column(name = "created_at", nullable = false, updatable = false) private Instant createdAt;
    @Column(name = "last_used_at", nullable = false) private Instant lastUsedAt;
    @Column(name = "family_id", nullable = false) private UUID familyId;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "replaced_by_session_id") private RefreshSession replacedBy;
    @Column(name = "ip_address", length = 45) private String ipAddress;
    @Column(name = "user_agent", length = 300) private String userAgent;

    public RefreshSession(UserAccount user, String tokenHash, UUID familyId, String ipAddress, String userAgent, Instant now, Instant expiresAt) {
        this.user = user; this.tokenHash = tokenHash; this.createdAt = now;
        this.lastUsedAt = now; this.expiresAt = expiresAt; this.familyId = familyId;
        this.ipAddress = ipAddress; this.userAgent = userAgent;
    }

    public boolean isUsable(Instant now) { return revokedAt == null && expiresAt.isAfter(now); }
    public void rotateTo(RefreshSession replacement, Instant now) { revokedAt = now; lastUsedAt = now; replacedBy = replacement; }
    public void revoke(Instant now) { if (revokedAt == null) revokedAt = now; }
}
