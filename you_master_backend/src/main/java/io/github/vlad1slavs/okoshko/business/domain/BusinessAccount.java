package io.github.vlad1slavs.okoshko.business.domain;

import io.github.vlad1slavs.okoshko.identity.domain.UserAccount;
import io.github.vlad1slavs.okoshko.professional.domain.ProfessionalProfile;
import io.github.vlad1slavs.okoshko.shared.persistence.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(name = "business_accounts")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class BusinessAccount extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "owner_user_id", nullable = false)
    private UserAccount owner;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "solo_professional_id", unique = true)
    private ProfessionalProfile soloProfessional;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 16)
    private BusinessType type;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 24)
    private BusinessStatus status;

    @Column(nullable = false, length = 120)
    private String slug;

    @Column(nullable = false, length = 160)
    private String name;

    @Column
    private String description;
}
