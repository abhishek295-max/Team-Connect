package ems.dto;
import jakarta.validation.constraints.*; import java.math.BigDecimal; import java.time.LocalDate;
public record PerformanceRequest(@NotNull Long employeeId,Long reviewerEmployeeId,@NotNull @DecimalMin("1.0") @DecimalMax("10.0") BigDecimal rating,@Size(max=10000) String reviewContent,@NotNull LocalDate reviewDate,@NotBlank String status) {}
