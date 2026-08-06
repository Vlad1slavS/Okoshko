package io.github.vlad1slavs.okoshko.appointment.api;

import io.github.vlad1slavs.okoshko.testsupport.PostgresIntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.time.ZoneId;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;

@AutoConfigureMockMvc
@Sql(scripts = "classpath:db/local/R__local_demo_data.sql")
class ProfessionalCalendarControllerIntegrationTest extends PostgresIntegrationTest {

    private static final String PROFESSIONAL_ID = "20000000-0000-0000-0000-000000000001";
    private static final ZoneId PROFESSIONAL_ZONE = ZoneId.of("Asia/Chita");

    @Autowired
    private MockMvc mockMvc;

    @Test
    void returnsAppointmentsForRequestedCalendarRange() throws Exception {
        var today = LocalDate.now(PROFESSIONAL_ZONE);

        mockMvc.perform(get("/api/v1/professionals/{id}/calendar", PROFESSIONAL_ID)
                        .with(jwt().jwt(token -> token.subject("10000000-0000-0000-0000-000000000001")))
                        .param("from", today.toString())
                        .param("to", today.plusDays(7).toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.professionalId").value(PROFESSIONAL_ID))
                .andExpect(jsonPath("$.timezone").value("Asia/Chita"))
                .andExpect(jsonPath("$.appointments.length()").value(4))
                .andExpect(jsonPath("$.appointments[0].clientName").value("Анна Петрова"))
                .andExpect(jsonPath("$.appointments[0].serviceName").value("Маникюр с покрытием"))
                .andExpect(jsonPath("$.appointments[2].status").value("PENDING_CONFIRMATION"));
    }

    @Test
    void rejectsInvalidCalendarRange() throws Exception {
        var today = LocalDate.now(PROFESSIONAL_ZONE);

        mockMvc.perform(get("/api/v1/professionals/{id}/calendar", PROFESSIONAL_ID)
                        .with(jwt().jwt(token -> token.subject("10000000-0000-0000-0000-000000000001")))
                        .param("from", today.toString())
                        .param("to", today.minusDays(1).toString()))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("INVALID_REQUEST"));
    }
}
