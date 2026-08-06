package io.github.vlad1slavs.okoshko.schedule.api;

import io.github.vlad1slavs.okoshko.testsupport.PostgresIntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.time.ZoneId;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;

@AutoConfigureMockMvc
@Sql(scripts = "classpath:db/local/R__local_demo_data.sql")
class ProfessionalAvailabilityControllerIntegrationTest extends PostgresIntegrationTest {

    private static final String PROFESSIONAL_ID = "20000000-0000-0000-0000-000000000001";
    private static final String SERVICE_ID = "60000000-0000-0000-0000-000000000001";

    @Autowired
    private MockMvc mockMvc;

    @Test
    void replacesAndReturnsStartBasedAvailabilityWithServiceRestriction() throws Exception {
        var date = LocalDate.now(ZoneId.of("Asia/Chita")).plusDays(2);
        var body = """
                {
                  "dates": [{
                    "date": "%s",
                    "starts": [
                      {"time": "09:30", "restrictedServiceId": "%s"},
                      {"time": "12:00", "restrictedServiceId": null}
                    ]
                  }]
                }
                """.formatted(date, SERVICE_ID);

        mockMvc.perform(put("/api/v1/professionals/{id}/availability-starts", PROFESSIONAL_ID)
                        .with(jwt().jwt(token -> token.subject("10000000-0000-0000-0000-000000000001")))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.dates[0].starts.length()").value(2))
                .andExpect(jsonPath("$.dates[0].starts[0].time").value("09:30:00"))
                .andExpect(jsonPath("$.dates[0].starts[0].restrictedServiceId").value(SERVICE_ID))
                .andExpect(jsonPath("$.dates[0].starts[0].restrictedServiceName")
                        .value("Маникюр с покрытием"));

        mockMvc.perform(get("/api/v1/professionals/{id}/availability-starts", PROFESSIONAL_ID)
                        .with(jwt().jwt(token -> token.subject("10000000-0000-0000-0000-000000000001")))
                        .param("from", date.toString())
                        .param("to", date.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.timezone").value("Asia/Chita"))
                .andExpect(jsonPath("$.dates[0].starts.length()").value(2));
    }

    @Test
    void rejectsServiceThatDoesNotBelongToProfessional() throws Exception {
        var date = LocalDate.now(ZoneId.of("Asia/Chita")).plusDays(3);
        var body = """
                {"dates":[{"date":"%s","starts":[{
                  "time":"09:30",
                  "restrictedServiceId":"60000000-0000-0000-0000-000000000004"
                }]}]}
                """.formatted(date);

        mockMvc.perform(put("/api/v1/professionals/{id}/availability-starts", PROFESSIONAL_ID)
                        .with(jwt().jwt(token -> token.subject("10000000-0000-0000-0000-000000000001")))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("INVALID_REQUEST"));
    }

    @Test
    void rejectsAnonymousAndForeignProfessionalChanges() throws Exception {
        var date = LocalDate.now(ZoneId.of("Asia/Chita")).plusDays(4);
        var body = "{\"dates\":[{\"date\":\"" + date + "\",\"starts\":[]}]}";

        mockMvc.perform(put("/api/v1/professionals/{id}/availability-starts", PROFESSIONAL_ID)
                        .contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isUnauthorized());

        mockMvc.perform(put("/api/v1/professionals/{id}/availability-starts", PROFESSIONAL_ID)
                        .with(jwt().jwt(token -> token.subject("11000000-0000-0000-0000-000000000001")))
                        .contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isForbidden());
    }
}
