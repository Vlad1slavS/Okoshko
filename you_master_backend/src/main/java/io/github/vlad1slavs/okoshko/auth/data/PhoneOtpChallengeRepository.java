package io.github.vlad1slavs.okoshko.auth.data;

import io.github.vlad1slavs.okoshko.auth.domain.PhoneOtpChallenge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import jakarta.persistence.LockModeType;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

public interface PhoneOtpChallengeRepository extends JpaRepository<PhoneOtpChallenge, UUID> {
    Optional<PhoneOtpChallenge> findTopByPhoneOrderByCreatedAtDesc(String phone);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<PhoneOtpChallenge> findFirstByPhoneOrderByCreatedAtDesc(String phone);

    long countByPhoneAndCreatedAtAfter(String phone, Instant after);
    long countByRequestIpAndCreatedAtAfter(String requestIp, Instant after);

    @Query(value = "select pg_advisory_xact_lock(hashtext(:phone))", nativeQuery = true)
    Object lockPhone(@Param("phone") String phone);

    @Modifying
    @Query("update PhoneOtpChallenge c set c.consumedAt = :now where c.phone = :phone and c.consumedAt is null")
    void consumeActive(@Param("phone") String phone, @Param("now") Instant now);
}
