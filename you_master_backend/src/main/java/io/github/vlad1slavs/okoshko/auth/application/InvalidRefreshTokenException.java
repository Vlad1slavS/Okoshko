package io.github.vlad1slavs.okoshko.auth.application;

public class InvalidRefreshTokenException extends RuntimeException {
    public InvalidRefreshTokenException(String message) { super(message); }
}
