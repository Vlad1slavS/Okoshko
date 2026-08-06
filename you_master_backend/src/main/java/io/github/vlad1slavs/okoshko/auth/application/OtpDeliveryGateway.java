package io.github.vlad1slavs.okoshko.auth.application;

public interface OtpDeliveryGateway {
    void send(String phone, String code);
}
