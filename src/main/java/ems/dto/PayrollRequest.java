package ems.dto;
import jakarta.validation.constraints.*; import java.math.BigDecimal; import java.time.LocalDate;
public record PayrollRequest(@NotNull Long employeeId,@NotNull @DecimalMin("0.0") BigDecimal amount,@NotNull LocalDate paymentDate,String periodLabel,@NotBlank String status,@Size(max=500) String notes) {}
