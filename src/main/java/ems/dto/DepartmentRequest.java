package ems.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record DepartmentRequest(
        @NotBlank(message = "Department name is required")
        @Size(max = 160, message = "Department name must be 160 characters or fewer")
        String name,
        @Size(max = 500, message = "Department description must be 500 characters or fewer")
        String description) {
}
