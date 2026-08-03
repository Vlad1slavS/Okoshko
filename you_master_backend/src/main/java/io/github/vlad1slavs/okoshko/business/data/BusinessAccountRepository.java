package io.github.vlad1slavs.okoshko.business.data;

import io.github.vlad1slavs.okoshko.business.domain.BusinessAccount;
import io.github.vlad1slavs.okoshko.business.domain.BusinessStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface BusinessAccountRepository extends JpaRepository<BusinessAccount, UUID> {

    Optional<BusinessAccount> findBySoloProfessionalIdAndStatus(
            UUID professionalId,
            BusinessStatus status
    );
}
