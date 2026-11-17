package ems.dto;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDate;

public record PayrollRequest(
        @NotNull Long employeeId,
        @DecimalMin("0.0") BigDecimal amount,
        @DecimalMin("0.0") BigDecimal baseSalary,
        @DecimalMin("0.0") BigDecimal bonus,
        @DecimalMin("0.0") BigDecimal deductions,
        @NotNull LocalDate paymentDate,
        String periodLabel,
        @NotBlank String status,
        @Size(max=500) String notes) {}
