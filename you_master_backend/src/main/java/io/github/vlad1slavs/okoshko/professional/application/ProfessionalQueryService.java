package io.github.vlad1slavs.okoshko.professional.application;

import io.github.vlad1slavs.okoshko.business.data.BusinessAccountRepository;
import io.github.vlad1slavs.okoshko.business.data.BusinessLocationRepository;
import io.github.vlad1slavs.okoshko.business.domain.BusinessAccount;
import io.github.vlad1slavs.okoshko.business.domain.BusinessLocation;
import io.github.vlad1slavs.okoshko.business.domain.BusinessStatus;
import io.github.vlad1slavs.okoshko.professional.api.ProfessionalResponse;
import io.github.vlad1slavs.okoshko.professional.api.ProfessionalDetailsResponse;
import io.github.vlad1slavs.okoshko.professional.api.ProfessionalPageResponse;
import io.github.vlad1slavs.okoshko.professional.api.ProfessionalSort;
import io.github.vlad1slavs.okoshko.professional.data.ProfessionalCatalogRepository;
import io.github.vlad1slavs.okoshko.professional.data.ProfessionalProfileRepository;
import io.github.vlad1slavs.okoshko.professional.domain.ProfessionalProfile;
import io.github.vlad1slavs.okoshko.professional.domain.ProfessionalStatus;
import io.github.vlad1slavs.okoshko.service.api.ServiceResponse;
import io.github.vlad1slavs.okoshko.service.data.ServiceOfferingRepository;
import io.github.vlad1slavs.okoshko.service.domain.ServiceOffering;
import io.github.vlad1slavs.okoshko.shared.error.ResourceNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.math.BigDecimal;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class ProfessionalQueryService {

    private final ProfessionalProfileRepository professionalRepository;
    private final BusinessAccountRepository businessRepository;
    private final BusinessLocationRepository locationRepository;
    private final ServiceOfferingRepository serviceRepository;
    private final ProfessionalCatalogRepository catalogRepository;

    public ProfessionalQueryService(
            ProfessionalProfileRepository professionalRepository,
            BusinessAccountRepository businessRepository,
            BusinessLocationRepository locationRepository,
            ServiceOfferingRepository serviceRepository,
            ProfessionalCatalogRepository catalogRepository
    ) {
        this.professionalRepository = professionalRepository;
        this.businessRepository = businessRepository;
        this.locationRepository = locationRepository;
        this.serviceRepository = serviceRepository;
        this.catalogRepository = catalogRepository;
    }

    public ProfessionalPageResponse searchProfessionals(
            String city,
            String category,
            String query,
            BigDecimal minimumRating,
            ProfessionalSort sort,
            int page,
            int size
    ) {
        var normalizedCategory = category == null ? "" : category.trim();
        var normalizedQuery = query == null ? "" : query.trim();
        var items = catalogRepository.findAll(
                city.trim(),
                normalizedCategory,
                normalizedQuery,
                minimumRating,
                sort,
                size,
                page * size
        );
        var totalItems = catalogRepository.count(
                city.trim(),
                normalizedCategory,
                normalizedQuery,
                minimumRating
        );
        return new ProfessionalPageResponse(
                items,
                page,
                size,
                totalItems,
                (long) (page + 1) * size < totalItems
        );
    }

    public ProfessionalResponse getProfessional(UUID professionalId) {
        var professional = findActiveProfessional(professionalId);
        var business = findActiveSoloBusiness(professionalId);
        var location = locationRepository
                .findFirstByBusinessAccountIdAndActiveTrueOrderByCreatedAtAsc(business.getId())
                .orElse(null);

        return toResponse(professional, business, location);
    }

    public List<ServiceResponse> getProfessionalServices(UUID professionalId) {
        findActiveProfessional(professionalId);
        var business = findActiveSoloBusiness(professionalId);
        return serviceRepository
                .findAllByBusinessAccountIdAndActiveTrueOrderByNameAsc(business.getId())
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public ProfessionalResponse getProfessionalBySlug(String slug) {
        var professional = findActiveProfessional(slug);
        var business = findActiveSoloBusiness(professional.getId());
        var location = locationRepository
                .findFirstByBusinessAccountIdAndActiveTrueOrderByCreatedAtAsc(business.getId())
                .orElse(null);
        return toResponse(professional, business, location);
    }

    public List<ServiceResponse> getProfessionalServicesBySlug(String slug) {
        var professional = findActiveProfessional(slug);
        var business = findActiveSoloBusiness(professional.getId());
        return findActiveServices(business.getId());
    }

    public ProfessionalDetailsResponse getProfessionalDetailsBySlug(String slug) {
        var professional = findActiveProfessional(slug);
        var business = findActiveSoloBusiness(professional.getId());
        var location = locationRepository
                .findFirstByBusinessAccountIdAndActiveTrueOrderByCreatedAtAsc(business.getId())
                .orElse(null);

        return new ProfessionalDetailsResponse(
                toResponse(professional, business, location),
                findActiveServices(business.getId())
        );
    }

    private ProfessionalProfile findActiveProfessional(UUID professionalId) {
        return professionalRepository
                .findByIdAndStatus(professionalId, ProfessionalStatus.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException("Мастер не найден"));
    }

    private ProfessionalProfile findActiveProfessional(String slug) {
        return professionalRepository
                .findBySlugAndStatusIgnoreCase(slug, ProfessionalStatus.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException("Мастер не найден"));
    }

    private List<ServiceResponse> findActiveServices(UUID businessId) {
        return serviceRepository
                .findAllByBusinessAccountIdAndActiveTrueOrderByNameAsc(businessId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    private BusinessAccount findActiveSoloBusiness(UUID professionalId) {
        return businessRepository
                .findBySoloProfessionalIdAndStatus(professionalId, BusinessStatus.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException("Профиль мастера недоступен"));
    }

    private ProfessionalResponse toResponse(
            ProfessionalProfile professional,
            BusinessAccount business,
            BusinessLocation location
    ) {
        var businessSummary = new ProfessionalResponse.BusinessSummary(
                business.getId(),
                business.getSlug(),
                business.getName(),
                business.getType().name()
        );
        var locationSummary = location == null ? null : new ProfessionalResponse.LocationSummary(
                location.getId(),
                location.getName(),
                location.getCity(),
                location.getAddressLine(),
                location.getTimezone(),
                location.getLatitude(),
                location.getLongitude()
        );

        return new ProfessionalResponse(
                professional.getId(),
                professional.getSlug(),
                professional.getDisplayName(),
                professional.getDescription(),
                professional.getAvatarUrl(),
                professional.getExperienceStartedOn(),
                professional.getRating(),
                professional.getReviewsCount(),
                professional.getCompletedAppointmentsCount(),
                businessSummary,
                locationSummary
        );
    }

    private ServiceResponse toResponse(ServiceOffering service) {
        return new ServiceResponse(
                service.getId(),
                service.getCategory().getId(),
                service.getCategory().getName(),
                service.getName(),
                service.getDescription(),
                service.getDurationMinutes(),
                service.getBufferBeforeMinutes(),
                service.getBufferAfterMinutes(),
                service.getPriceMinor(),
                service.getCurrency()
        );
    }
}
