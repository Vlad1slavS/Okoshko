package io.github.vlad1slavs.okoshko.business.domain;

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

import java.math.BigDecimal;

@Getter
@Entity
@Table(name = "business_locations")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class BusinessLocation extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "business_account_id", nullable = false)
    private BusinessAccount businessAccount;

    @Column(nullable = false, length = 160)
    private String name;

    @Column(nullable = false, length = 120)
    private String city;

    @Column(name = "address_line", nullable = false, length = 300)
    private String addressLine;

    @Column(nullable = false, length = 64)
    private String timezone;

    @Column(precision = 9, scale = 6)
    private BigDecimal latitude;

    @Column(precision = 9, scale = 6)
    private BigDecimal longitude;

    @Column(length = 20)
    private String phone;

    @Column(name = "is_active", nullable = false)
    private boolean active;
}
