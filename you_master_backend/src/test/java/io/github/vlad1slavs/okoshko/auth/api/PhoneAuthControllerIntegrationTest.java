package io.github.vlad1slavs.okoshko.auth.api;

import io.github.vlad1slavs.okoshko.testsupport.PostgresIntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.context.TestPropertySource;
import io.github.vlad1slavs.okoshko.auth.data.PhoneOtpChallengeRepository;
import jakarta.servlet.http.Cookie;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@TestPropertySource(properties = "app.auth.expose-dev-code=true")
@AutoConfigureMockMvc
class PhoneAuthControllerIntegrationTest extends PostgresIntegrationTest {
    @Autowired MockMvc mockMvc;
    @Autowired PhoneOtpChallengeRepository challenges;

    @Test
    void requestsAndVerifiesDevelopmentOtp() throws Exception {
        var requestResult = mockMvc.perform(post("/api/v1/auth/otp/request")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phone\":\"+79995554433\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.devCode", matchesPattern("[0-9]{6}")))
                .andReturn();

        var body = requestResult.getResponse().getContentAsString();
        var code = body.replaceAll(".*\\\"devCode\\\":\\\"([0-9]{6})\\\".*", "$1");
        var verifyResult = mockMvc.perform(post("/api/v1/auth/otp/verify")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phone\":\"+79995554433\",\"code\":\"" + code + "\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.accessToken", not(blankString())))
                .andExpect(jsonPath("$.refreshToken").doesNotExist())
                .andExpect(jsonPath("$.user.hasProfessionalProfile").value(false))
                .andExpect(header().string("Set-Cookie", containsString("HttpOnly")))
                .andReturn();

        var refreshToken = verifyResult.getResponse().getCookie("okoshko_refresh").getValue();
        var accessToken = verifyResult.getResponse().getContentAsString()
                .replaceAll(".*\\\"accessToken\\\":\\\"([^\\\"]+)\\\".*", "$1");

        mockMvc.perform(put("/api/v1/auth/me/profile")
                        .header("Authorization", "Bearer " + accessToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"firstName\":\" Анна \",\"lastName\":\" Иванова \"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.displayName").value("Анна Иванова"))
                .andExpect(jsonPath("$.hasClientProfile").value(true));

        mockMvc.perform(post("/api/v1/auth/refresh").cookie(new Cookie("okoshko_refresh", refreshToken)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.accessToken", not(blankString())))
                .andExpect(header().string("Set-Cookie", containsString("okoshko_refresh")));

        mockMvc.perform(post("/api/v1/auth/refresh").cookie(new Cookie("okoshko_refresh", refreshToken)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("AUTH_SESSION_INVALID"));
    }

    @Test
    void rejectsIncorrectOtp() throws Exception {
        mockMvc.perform(post("/api/v1/auth/otp/request")
                .contentType(MediaType.APPLICATION_JSON).content("{\"phone\":\"+79995554434\"}"));
        mockMvc.perform(post("/api/v1/auth/otp/verify")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phone\":\"+79995554434\",\"code\":\"000000\"}"))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("OTP_INVALID"));
        org.assertj.core.api.Assertions.assertThat(
                challenges.findTopByPhoneOrderByCreatedAtDesc("+79995554434").orElseThrow().getAttemptsRemaining()
        ).isEqualTo((short) 4);
    }
}
