package io.github.vlad1slavs.okoshko.auth.api;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record RequestOtpRequest(
        @NotBlank @Pattern(regexp = "^\\+[1-9][0-9]{7,14}$", message = "Телефон должен быть в формате E.164")
        String phone
) {}
