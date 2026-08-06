package io.github.vlad1slavs.okoshko.favorite.api;

import io.github.vlad1slavs.okoshko.testsupport.PostgresIntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@AutoConfigureMockMvc
@Sql(scripts = "classpath:db/local/R__local_demo_data.sql")
@Sql(statements = "DELETE FROM client_favorite_professionals")
class FavoriteProfessionalControllerIntegrationTest extends PostgresIntegrationTest {
    private static final String USER_ONE = "10000000-0000-0000-0000-000000000001";
    private static final String USER_TWO = "10000000-0000-0000-0000-000000000002";

    @Autowired
    private MockMvc mockMvc;

    @Test
    void addsIdempotentlyListsAndRemovesFavorite() throws Exception {
        var add = put("/api/v1/me/favorites/anna-ivanova")
                .with(jwt().jwt(token -> token.subject(USER_ONE)));

        mockMvc.perform(add)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.professionalId").value("anna-ivanova"))
                .andExpect(jsonPath("$.favorite").value(true));
        mockMvc.perform(add).andExpect(status().isOk());

        mockMvc.perform(get("/api/v1/me/favorites/ids")
                        .with(jwt().jwt(token -> token.subject(USER_ONE))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.professionalIds.length()").value(1))
                .andExpect(jsonPath("$.professionalIds[0]").value("anna-ivanova"));

        mockMvc.perform(get("/api/v1/me/favorites")
                        .with(jwt().jwt(token -> token.subject(USER_ONE)))
                        .param("page", "0").param("size", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items[0].slug").value("anna-ivanova"))
                .andExpect(jsonPath("$.totalItems").value(1))
                .andExpect(jsonPath("$.hasNext").value(false));

        mockMvc.perform(delete("/api/v1/me/favorites/anna-ivanova")
                        .with(jwt().jwt(token -> token.subject(USER_ONE))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.favorite").value(false));
        mockMvc.perform(delete("/api/v1/me/favorites/anna-ivanova")
                        .with(jwt().jwt(token -> token.subject(USER_ONE))))
                .andExpect(status().isOk());
    }

    @Test
    void keepsFavoritesIsolatedPerUserAndRequiresAuthentication() throws Exception {
        mockMvc.perform(put("/api/v1/me/favorites/anna-ivanova")
                        .with(jwt().jwt(token -> token.subject(USER_ONE))))
                .andExpect(status().isOk());

        mockMvc.perform(get("/api/v1/me/favorites/ids")
                        .with(jwt().jwt(token -> token.subject(USER_TWO))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.professionalIds.length()").value(0));

        mockMvc.perform(get("/api/v1/me/favorites/ids"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void returnsNotFoundForUnknownProfessional() throws Exception {
        mockMvc.perform(put("/api/v1/me/favorites/missing")
                        .with(jwt().jwt(token -> token.subject(USER_ONE))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("RESOURCE_NOT_FOUND"));
    }
}
