package io.github.vlad1slavs.okoshko.service.data;

import io.github.vlad1slavs.okoshko.service.domain.ServiceOffering;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ServiceOfferingRepository extends JpaRepository<ServiceOffering, UUID> {

    @EntityGraph(attributePaths = "category")
    List<ServiceOffering> findAllByBusinessAccountIdAndActiveTrueOrderByNameAsc(
            UUID businessAccountId
    );
}
