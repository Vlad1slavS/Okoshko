package io.github.vlad1slavs.okoshko.auth.api;

import io.github.vlad1slavs.okoshko.auth.data.PhoneOtpChallengeRepository;
import io.github.vlad1slavs.okoshko.testsupport.PostgresIntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;

@TestPropertySource(properties = "app.auth.expose-dev-code=true")
@AutoConfigureMockMvc
class OtpConcurrencyIntegrationTest extends PostgresIntegrationTest {

    @Autowired MockMvc mockMvc;
    @Autowired PhoneOtpChallengeRepository challenges;

    @Test
    @DisplayName("параллельная проверка")
    void countsEveryParallelInvalidAttemptWithoutLostUpdates() throws Exception {
        var phone = "+79995554501";
        var validCode = requestOtp(phone);
        var start = new CountDownLatch(1);
        var tasks = new ArrayList<Callable<MvcResult>>();

        for (int index = 0; index < 20; index++) {
            var candidate = "%06d".formatted(index);
            if (candidate.equals(validCode)) candidate = "999999";
            var code = candidate;
            tasks.add(() -> {
                start.await();
                return verify(phone, code);
            });
        }

        var results = runConcurrently(tasks, start);

        assertThat(results).allMatch(result -> result.getResponse().getStatus() == 422);
        assertThat(results).filteredOn(result -> responseContains(result, "Неверный код из SMS")).hasSize(5);
        assertThat(results).filteredOn(result -> responseContains(result, "Код истёк или исчерпаны попытки")).hasSize(15);
        assertThat(challenges.findTopByPhoneOrderByCreatedAtDesc(phone).orElseThrow().getAttemptsRemaining())
                .isZero();
    }

    @Test
    void acceptsAParallelCorrectOtpOnlyOnce() throws Exception {
        var phone = "+79995554502";
        var code = requestOtp(phone);
        var start = new CountDownLatch(1);
        var tasks = List.<Callable<MvcResult>>of(
                () -> {
                    start.await();
                    return verify(phone, code);
                },
                () -> {
                    start.await();
                    return verify(phone, code);
                }
        );

        var results = runConcurrently(tasks, start);

        assertThat(results).filteredOn(result -> result.getResponse().getStatus() == 200).hasSize(1);
        assertThat(results).filteredOn(result -> result.getResponse().getStatus() == 422).hasSize(1);
        assertThat(results).filteredOn(result -> responseContains(result, "Код истёк или исчерпаны попытки"))
                .hasSize(1);
        assertThat(challenges.findTopByPhoneOrderByCreatedAtDesc(phone).orElseThrow().getConsumedAt())
                .isNotNull();
    }

    private String requestOtp(String phone) throws Exception {
        var result = mockMvc.perform(post("/api/v1/auth/otp/request")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phone\":\"" + phone + "\"}"))
                .andReturn();
        assertThat(result.getResponse().getStatus()).isEqualTo(201);
        return result.getResponse().getContentAsString()
                .replaceAll(".*\\\"devCode\\\":\\\"([0-9]{6})\\\".*", "$1");
    }

    private MvcResult verify(String phone, String code) throws Exception {
        return mockMvc.perform(post("/api/v1/auth/otp/verify")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phone\":\"" + phone + "\",\"code\":\"" + code + "\"}"))
                .andReturn();
    }

    private List<MvcResult> runConcurrently(
            List<Callable<MvcResult>> tasks,
            CountDownLatch start
    ) throws Exception {
        try (var executor = Executors.newFixedThreadPool(tasks.size())) {
            var futures = tasks.stream().map(executor::submit).toList();
            start.countDown();
            var results = new ArrayList<MvcResult>(futures.size());
            for (Future<MvcResult> future : futures) results.add(future.get());
            return results;
        }
    }

    private boolean responseContains(MvcResult result, String text) {
        try {
            return result.getResponse().getContentAsString().contains(text);
        } catch (Exception exception) {
            throw new AssertionError(exception);
        }
    }
}
