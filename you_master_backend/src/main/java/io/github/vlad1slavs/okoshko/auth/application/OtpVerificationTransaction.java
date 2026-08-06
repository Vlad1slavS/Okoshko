package io.github.vlad1slavs.okoshko.auth.application;

import io.github.vlad1slavs.okoshko.auth.data.PhoneOtpChallengeRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Clock;

@Service
public class OtpVerificationTransaction {
    public enum Result { VERIFIED, NOT_FOUND, EXPIRED_OR_BLOCKED, INVALID }
    private final PhoneOtpChallengeRepository challenges;
    private final Clock clock;

    public OtpVerificationTransaction(PhoneOtpChallengeRepository challenges, Clock clock) {
        this.challenges = challenges; this.clock = clock;
    }

    @Transactional
    public Result verify(String phone, String expectedHash) {
        challenges.lockPhone(phone);
        var now = clock.instant();
        var challenge = challenges.findFirstByPhoneOrderByCreatedAtDesc(phone).orElse(null);
        if (challenge == null) return Result.NOT_FOUND;
        if (!challenge.canVerify(now)) return Result.EXPIRED_OR_BLOCKED;
        if (!MessageDigest.isEqual(challenge.getCodeHash().getBytes(StandardCharsets.UTF_8),
                expectedHash.getBytes(StandardCharsets.UTF_8))) {
            challenge.failAttempt();
            return Result.INVALID;
        }
        challenge.consume(now);
        return Result.VERIFIED;
    }
}
