package io.github.vlad1slavs.okoshko.professional.domain;

import io.github.vlad1slavs.okoshko.identity.domain.UserAccount;
import io.github.vlad1slavs.okoshko.shared.persistence.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Entity
@Table(name = "professional_profiles")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ProfessionalProfile extends BaseEntity {

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private UserAccount user;

    @Column(nullable = false, length = 120)
    private String slug;

    @Column(name = "display_name", nullable = false, length = 120)
    private String displayName;

    @Column
    private String description;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Column(name = "experience_started_on")
    private LocalDate experienceStartedOn;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private ProfessionalStatus status;

    @Column(nullable = false, precision = 3, scale = 2)
    private BigDecimal rating;

    @Column(name = "reviews_count", nullable = false)
    private int reviewsCount;

    @Column(name = "completed_appointments_count", nullable = false)
    private int completedAppointmentsCount;
}
