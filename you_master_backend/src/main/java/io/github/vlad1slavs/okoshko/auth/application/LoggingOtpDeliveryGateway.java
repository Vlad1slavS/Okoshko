package io.github.vlad1slavs.okoshko.auth.application;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Component
@Profile("!prod")
public class LoggingOtpDeliveryGateway implements OtpDeliveryGateway {
    private static final Logger log = LoggerFactory.getLogger(LoggingOtpDeliveryGateway.class);
    @Override public void send(String phone, String code) {
        log.info("DEV OTP for {}: {}", mask(phone), code);
    }
    private String mask(String phone) {
        return phone.length() < 5 ? "***" : phone.substring(0, 2) + "***" + phone.substring(phone.length() - 2);
    }
}
