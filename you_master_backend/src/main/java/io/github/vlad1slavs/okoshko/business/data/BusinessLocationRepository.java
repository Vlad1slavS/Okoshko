package io.github.vlad1slavs.okoshko.business.data;

import io.github.vlad1slavs.okoshko.business.domain.BusinessLocation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface BusinessLocationRepository extends JpaRepository<BusinessLocation, UUID> {

    Optional<BusinessLocation> findFirstByBusinessAccountIdAndActiveTrueOrderByCreatedAtAsc(
            UUID businessAccountId
    );
}
