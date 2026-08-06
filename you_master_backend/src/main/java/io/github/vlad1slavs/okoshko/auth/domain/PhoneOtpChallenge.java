package io.github.vlad1slavs.okoshko.auth.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

@Getter
@Entity
@Table(name = "phone_otp_challenges")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class PhoneOtpChallenge {
    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false, length = 20) private String phone;
    @Column(name = "code_hash", nullable = false, length = 64) private String codeHash;
    @Column(name = "expires_at", nullable = false) private Instant expiresAt;
    @Column(name = "resend_available_at", nullable = false) private Instant resendAvailableAt;
    @Column(name = "attempts_remaining", nullable = false) private short attemptsRemaining;
    @Column(name = "consumed_at") private Instant consumedAt;
    @Column(name = "created_at", nullable = false, updatable = false) private Instant createdAt;
    @Column(name = "request_ip", length = 45) private String requestIp;

    public PhoneOtpChallenge(String phone, String codeHash, String requestIp, Instant now, Instant expiresAt, Instant resendAvailableAt) {
        this.phone = phone;
        this.codeHash = codeHash;
        this.createdAt = now;
        this.expiresAt = expiresAt;
        this.resendAvailableAt = resendAvailableAt;
        this.attemptsRemaining = 5;
        this.requestIp = requestIp;
    }

    public boolean canVerify(Instant now) {
        return consumedAt == null && attemptsRemaining > 0 && expiresAt.isAfter(now);
    }

    public void failAttempt() { attemptsRemaining = (short) Math.max(0, attemptsRemaining - 1); }
    public void consume(Instant now) { consumedAt = now; }
}
