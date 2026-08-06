package io.github.vlad1slavs.okoshko.auth.api;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record VerifyOtpRequest(
        @NotBlank @Pattern(regexp = "^\\+[1-9][0-9]{7,14}$") String phone,
        @NotBlank @Pattern(regexp = "^[0-9]{6}$", message = "Код должен содержать 6 цифр") String code
) {}
