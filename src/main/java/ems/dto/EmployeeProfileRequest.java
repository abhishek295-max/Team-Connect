package ems.dto;

import jakarta.validation.constraints.Size;

public record EmployeeProfileRequest(
        @Size(max=40) String phone,
        @Size(max=40) String gender,
        @Size(max=160) String jobTitle,
        @Size(max=500) String address) {}
