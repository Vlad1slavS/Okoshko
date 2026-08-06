package io.github.vlad1slavs.okoshko.identity.data;

import io.github.vlad1slavs.okoshko.identity.domain.ClientProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface ClientProfileRepository extends JpaRepository<ClientProfile, UUID> {}
