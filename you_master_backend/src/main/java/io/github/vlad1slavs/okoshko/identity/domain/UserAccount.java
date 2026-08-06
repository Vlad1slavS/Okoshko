package io.github.vlad1slavs.okoshko.identity.domain;

import io.github.vlad1slavs.okoshko.shared.persistence.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Getter
@Entity
@Table(name = "users")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserAccount extends BaseEntity {

    public UserAccount(String phone, Instant verifiedAt) {
        this.phone = phone;
        this.status = UserStatus.ACTIVE;
        this.phoneVerifiedAt = verifiedAt;
        this.lastLoginAt = verifiedAt;
    }

    public void recordPhoneLogin(Instant now) {
        phoneVerifiedAt = phoneVerifiedAt == null ? now : phoneVerifiedAt;
        lastLoginAt = now;
    }

    @Column(nullable = false, unique = true, length = 20)
    private String phone;

    @Column(length = 320)
    private String email;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private UserStatus status;

    @Column(name = "phone_verified_at")
    private Instant phoneVerifiedAt;

    @Column(name = "email_verified_at")
    private Instant emailVerifiedAt;

    @Column(name = "last_login_at")
    private Instant lastLoginAt;
}
