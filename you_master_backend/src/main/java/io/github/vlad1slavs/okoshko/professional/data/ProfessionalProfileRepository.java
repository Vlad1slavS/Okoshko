package io.github.vlad1slavs.okoshko.professional.data;

import io.github.vlad1slavs.okoshko.professional.domain.ProfessionalProfile;
import io.github.vlad1slavs.okoshko.professional.domain.ProfessionalStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface ProfessionalProfileRepository extends JpaRepository<ProfessionalProfile, UUID> {

    Optional<ProfessionalProfile> findByIdAndStatus(UUID id, ProfessionalStatus status);

    @Query("""
            select professional
            from ProfessionalProfile professional
            where lower(professional.slug) = lower(:slug)
              and professional.status = :status
            """)
    Optional<ProfessionalProfile> findBySlugAndStatusIgnoreCase(
            @Param("slug") String slug,
            @Param("status") ProfessionalStatus status
    );
}
