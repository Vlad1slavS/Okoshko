package io.github.vlad1slavs.okoshko.service.domain;

import io.github.vlad1slavs.okoshko.business.domain.BusinessAccount;
import io.github.vlad1slavs.okoshko.shared.persistence.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(name = "services")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ServiceOffering extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "business_account_id", nullable = false)
    private BusinessAccount businessAccount;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "category_id", nullable = false)
    private ServiceCategory category;

    @Column(nullable = false, length = 160)
    private String name;

    @Column
    private String description;

    @Column(name = "duration_minutes", nullable = false)
    private int durationMinutes;

    @Column(name = "buffer_before_minutes", nullable = false)
    private int bufferBeforeMinutes;

    @Column(name = "buffer_after_minutes", nullable = false)
    private int bufferAfterMinutes;

    @Column(name = "price_minor", nullable = false)
    private long priceMinor;

    @Column(nullable = false, length = 3)
    private String currency;

    @Column(name = "is_active", nullable = false)
    private boolean active;
}
