package io.github.vlad1slavs.okoshko.auth.config;

import com.nimbusds.jose.jwk.source.ImmutableSecret;
import com.nimbusds.jose.proc.SecurityContext;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import org.springframework.context.annotation.Profile;
import org.springframework.boot.ApplicationRunner;

@Configuration(proxyBeanMethods = false)
@EnableConfigurationProperties(AuthProperties.class)
public class AuthConfiguration {
    @Bean
    SecretKey authSecretKey(AuthProperties properties) {
        return new SecretKeySpec(properties.jwtSecret().getBytes(StandardCharsets.UTF_8), "HmacSHA256");
    }

    @Bean
    JwtEncoder jwtEncoder(SecretKey key) {
        return new NimbusJwtEncoder(new ImmutableSecret<>(key));
    }

    @Bean
    JwtDecoder jwtDecoder(SecretKey key) {
        var decoder = NimbusJwtDecoder.withSecretKey(key).build();
        var issuer = org.springframework.security.oauth2.jwt.JwtValidators.createDefaultWithIssuer("okoshko-api");
        var audience = new org.springframework.security.oauth2.core.DelegatingOAuth2TokenValidator<>(
                issuer,
                jwt -> jwt.getAudience().contains("okoshko-app")
                        ? org.springframework.security.oauth2.core.OAuth2TokenValidatorResult.success()
                        : org.springframework.security.oauth2.core.OAuth2TokenValidatorResult.failure(
                        new org.springframework.security.oauth2.core.OAuth2Error("invalid_token", "Required audience is missing", null))
        );
        decoder.setJwtValidator(audience);
        return decoder;
    }

    @Bean Clock clock() { return Clock.systemUTC(); }

    @Bean
    @Profile("prod")
    ApplicationRunner validateProductionAuth(AuthProperties properties) {
        return args -> {
            if (properties.exposeDevCode()
                    || properties.otpPepper().contains("local-development")
                    || properties.jwtSecret().contains("local-development")
                    || !properties.cookieSecure()) {
                throw new IllegalStateException("Production auth configuration is unsafe");
            }
        };
    }
}
