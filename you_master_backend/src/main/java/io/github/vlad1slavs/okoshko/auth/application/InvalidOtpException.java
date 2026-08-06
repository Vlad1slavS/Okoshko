package io.github.vlad1slavs.okoshko.auth.application;

public class InvalidOtpException extends RuntimeException {
    public InvalidOtpException(String message) { super(message); }
}
