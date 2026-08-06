package io.github.vlad1slavs.okoshko.professional.application;

import io.github.vlad1slavs.okoshko.professional.data.ProfessionalProfileRepository;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class ProfessionalAccessService {
    private final ProfessionalProfileRepository professionals;
    public ProfessionalAccessService(ProfessionalProfileRepository professionals) { this.professionals = professionals; }

    public void assertOwner(UUID professionalId, String subject) {
        if (!professionals.existsByIdAndUserId(professionalId, UUID.fromString(subject))) {
            throw new AccessDeniedException("Нет доступа к данным этого мастера");
        }
    }
}
