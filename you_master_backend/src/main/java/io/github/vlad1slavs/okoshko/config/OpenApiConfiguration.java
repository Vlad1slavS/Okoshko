package io.github.vlad1slavs.okoshko.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration(proxyBeanMethods = false)
public class OpenApiConfiguration {

    @Bean
    OpenAPI okoshkoOpenApi() {
        return new OpenAPI()
                .info(new Info()
                        .title("Okoshko API")
                        .description("API сервиса онлайн-записи к мастерам и студиям")
                        .version("v1"));
    }
}
