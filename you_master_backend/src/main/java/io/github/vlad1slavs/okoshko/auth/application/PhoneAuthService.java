package io.github.vlad1slavs.okoshko.auth.application;

import io.github.vlad1slavs.okoshko.auth.api.OtpRequestedResponse;
import io.github.vlad1slavs.okoshko.auth.config.AuthProperties;
import io.github.vlad1slavs.okoshko.auth.data.PhoneOtpChallengeRepository;
import io.github.vlad1slavs.okoshko.auth.domain.PhoneOtpChallenge;
import io.github.vlad1slavs.okoshko.identity.data.UserAccountRepository;
import io.github.vlad1slavs.okoshko.identity.domain.UserAccount;
import io.github.vlad1slavs.okoshko.identity.domain.UserStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.time.Clock;
import java.time.Duration;
import java.util.HexFormat;

@Service
public class PhoneAuthService {
    private static final SecureRandom RANDOM = new SecureRandom();
    private final PhoneOtpChallengeRepository challenges;
    private final UserAccountRepository users;
    private final OtpDeliveryGateway delivery;
    private final OtpVerificationTransaction verification;
    private final AuthSessionService sessions;
    private final AuthProperties properties;
    private final Clock clock;

    public PhoneAuthService(PhoneOtpChallengeRepository challenges, UserAccountRepository users,
                            OtpDeliveryGateway delivery, OtpVerificationTransaction verification,
                            AuthSessionService sessions, AuthProperties properties, Clock clock) {
        this.challenges = challenges; this.users = users; this.delivery = delivery;
        this.verification = verification; this.sessions = sessions; this.properties = properties; this.clock = clock;
    }

    @Transactional
    public OtpRequestedResponse request(String phone, String requestIp) {
        var now = clock.instant();
        challenges.lockPhone(phone);
        var latest = challenges.findTopByPhoneOrderByCreatedAtDesc(phone).orElse(null);
        if (latest != null && latest.getResendAvailableAt().isAfter(now))
            throw new InvalidOtpException("Запросить новый код можно чуть позже");
        if (challenges.countByPhoneAndCreatedAtAfter(phone, now.minus(Duration.ofHours(1))) >= 5
                || challenges.countByPhoneAndCreatedAtAfter(phone, now.minus(Duration.ofDays(1))) >= 10)
            throw new InvalidOtpException("Превышен лимит отправки кодов. Попробуйте позже");
        if (requestIp != null && challenges.countByRequestIpAndCreatedAtAfter(requestIp, now.minus(Duration.ofHours(1))) >= 30)
            throw new InvalidOtpException("Слишком много запросов. Попробуйте позже");

        challenges.consumeActive(phone, now);
        var code = "%06d".formatted(RANDOM.nextInt(1_000_000));
        challenges.save(new PhoneOtpChallenge(phone, hashOtp(phone, code), requestIp, now,
                now.plus(properties.otpTtl()), now.plus(properties.resendDelay())));

        // TODO: Обязательно вынести вызов внешнего шлюза в Transactional Outbox паттерн
        delivery.send(phone, code);

        return new OtpRequestedResponse(Math.toIntExact(properties.otpTtl().toSeconds()),
                Math.toIntExact(properties.resendDelay().toSeconds()), properties.exposeDevCode() ? code : null);
    }

    public IssuedSession verify(String phone, String code, String ip, String userAgent) {
        var result = verification.verify(phone, hashOtp(phone, code));
        switch (result) {
            case NOT_FOUND -> throw new InvalidOtpException("Код не запрашивался или уже недействителен");
            case EXPIRED_OR_BLOCKED -> throw new InvalidOtpException("Код истёк или исчерпаны попытки");
            case INVALID -> throw new InvalidOtpException("Неверный код из SMS");
            case VERIFIED -> { }
        }
        var now = clock.instant();
        var user = users.findByPhone(phone).orElseGet(() -> users.save(new UserAccount(phone, now)));
        if (user.getStatus() != UserStatus.ACTIVE) throw new InvalidOtpException("Аккаунт недоступен");
        user.recordPhoneLogin(now);
        users.save(user);
        return sessions.create(user, ip, userAgent);
    }

    private String hashOtp(String phone, String code) {
        try {
            var mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(properties.otpPepper().getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return HexFormat.of().formatHex(mac.doFinal((phone + ":" + code).getBytes(StandardCharsets.UTF_8)));
        } catch (Exception exception) { throw new IllegalStateException("Cannot hash OTP", exception); }
    }
}
