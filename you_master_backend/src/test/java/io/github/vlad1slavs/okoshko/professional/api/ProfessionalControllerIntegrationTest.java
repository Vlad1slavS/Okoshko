package io.github.vlad1slavs.okoshko.professional.api;

import io.github.vlad1slavs.okoshko.testsupport.PostgresIntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@AutoConfigureMockMvc
@Sql(scripts = "classpath:db/local/R__local_demo_data.sql")
class ProfessionalControllerIntegrationTest extends PostgresIntegrationTest {

    private static final String PROFESSIONAL_ID = "20000000-0000-0000-0000-000000000001";

    @Autowired
    private MockMvc mockMvc;

    @Test
    void returnsPublicProfessionalProfile() throws Exception {
        mockMvc.perform(get("/api/v1/professionals/{id}", PROFESSIONAL_ID))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(PROFESSIONAL_ID))
                .andExpect(jsonPath("$.displayName").value("Екатерина Смирнова"))
                .andExpect(jsonPath("$.business.type").value("SOLO"))
                .andExpect(jsonPath("$.location.city").value("Чита"));
    }

    @Test
    void returnsPaginatedProfessionalCatalog() throws Exception {
        mockMvc.perform(get("/api/v1/professionals")
                        .param("city", "Чита")
                        .param("category", "manicure")
                        .param("page", "0")
                        .param("size", "20"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items.length()").value(2))
                .andExpect(jsonPath("$.items[0].slug").value("ekaterina-smirnova"))
                .andExpect(jsonPath("$.items[0].priceFromMinor").value(120000))
                .andExpect(jsonPath("$.items[0].categorySlugs[0]").value("manicure"))
                .andExpect(jsonPath("$.totalItems").value(2))
                .andExpect(jsonPath("$.hasNext").value(false));
    }

    @Test
    void filtersCatalogByQueryAndReturnsPopularProfessionals() throws Exception {
        mockMvc.perform(get("/api/v1/professionals")
                        .param("city", "Чита")
                        .param("query", "покрытием"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items[0].slug").value("ekaterina-smirnova"));

        mockMvc.perform(get("/api/v1/professionals/popular")
                        .param("city", "Чита")
                        .param("limit", "5"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].slug").value("olga-sokolova"));
    }

    @Test
    void returnsActiveProfessionalServices() throws Exception {
        mockMvc.perform(get("/api/v1/professionals/{id}/services", PROFESSIONAL_ID))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(3))
                .andExpect(jsonPath("$[0].categoryName").value("Маникюр"))
                .andExpect(jsonPath("$[0].currency").value("RUB"));
    }

    @Test
    void returnsProfessionalAndServicesByPublicSlug() throws Exception {
        mockMvc.perform(get("/api/v1/professionals/by-slug/ekaterina-smirnova"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(PROFESSIONAL_ID));

        mockMvc.perform(get("/api/v1/professionals/by-slug/ekaterina-smirnova/services"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(3));
    }

    @Test
    void returnsAggregatedProfessionalDetailsByPublicSlug() throws Exception {
        mockMvc.perform(get(
                        "/api/v1/professionals/by-slug/{slug}/details",
                        "EKATERINA-SMIRNOVA"
                ))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.professional.id").value(PROFESSIONAL_ID))
                .andExpect(jsonPath("$.professional.location.city").value("Чита"))
                .andExpect(jsonPath("$.services.length()").value(3));
    }

    @Test
    void aggregateReturnsNotFoundWithoutLoadingServices() throws Exception {
        mockMvc.perform(get(
                        "/api/v1/professionals/by-slug/{slug}/details",
                        "missing-professional"
                ))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("RESOURCE_NOT_FOUND"));
    }

    @Test
    void returnsUnifiedProblemForMissingProfessional() throws Exception {
        mockMvc.perform(get(
                        "/api/v1/professionals/{id}",
                        "99999999-0000-0000-0000-000000000999"
                ))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("RESOURCE_NOT_FOUND"))
                .andExpect(jsonPath("$.detail").value("Мастер не найден"));
    }
}
