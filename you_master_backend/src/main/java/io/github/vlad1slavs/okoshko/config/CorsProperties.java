package io.github.vlad1slavs.okoshko.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.List;

@ConfigurationProperties(prefix = "app.cors")
public record CorsProperties(List<String> allowedOriginPatterns) {

    public CorsProperties {
        allowedOriginPatterns = List.copyOf(allowedOriginPatterns);
    }
}
