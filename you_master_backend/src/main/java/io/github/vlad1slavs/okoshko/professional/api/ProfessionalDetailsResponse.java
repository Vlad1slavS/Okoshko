package io.github.vlad1slavs.okoshko.professional.api;

import io.github.vlad1slavs.okoshko.service.api.ServiceResponse;

import java.util.List;

public record ProfessionalDetailsResponse(
        ProfessionalResponse professional,
        List<ServiceResponse> services
) {

    public ProfessionalDetailsResponse {
        services = List.copyOf(services);
    }
}
