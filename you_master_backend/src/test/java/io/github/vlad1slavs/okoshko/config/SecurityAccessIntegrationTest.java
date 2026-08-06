package io.github.vlad1slavs.okoshko.config;

import io.github.vlad1slavs.okoshko.testsupport.PostgresIntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@AutoConfigureMockMvc
@Sql(scripts = "classpath:db/local/R__local_demo_data.sql")
class SecurityAccessIntegrationTest extends PostgresIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void exposesOnlyPublicProfessionalDiscoveryEndpointsAnonymously() throws Exception {
        mockMvc.perform(get("/api/v1/professionals").param("city", "Чита"))
                .andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/professionals/popular").param("city", "Чита"))
                .andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/professionals/by-slug/anna-ivanova/details"))
                .andExpect(status().isOk());
    }

    @Test
    void protectsPersonalAndProfessionalWorkspaceEndpoints() throws Exception {
        mockMvc.perform(get("/api/v1/auth/me"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(get("/api/v1/me/favorites"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(get("/api/v1/professionals/20000000-0000-0000-0000-000000000001/calendar")
                        .param("month", "2026-08"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(get("/api/v1/professionals/20000000-0000-0000-0000-000000000001/availability-starts")
                        .param("from", "2026-08-01")
                        .param("to", "2026-08-02"))
                .andExpect(status().isUnauthorized());
    }
}
