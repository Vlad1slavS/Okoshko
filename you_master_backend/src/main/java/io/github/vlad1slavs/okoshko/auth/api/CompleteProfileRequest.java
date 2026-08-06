package io.github.vlad1slavs.okoshko.auth.api;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CompleteProfileRequest(
        @NotBlank(message = "Укажите имя") @Size(max = 60, message = "Имя не должно превышать 60 символов") String firstName,
        @Size(max = 60, message = "Фамилия не должна превышать 60 символов") String lastName
) {}
