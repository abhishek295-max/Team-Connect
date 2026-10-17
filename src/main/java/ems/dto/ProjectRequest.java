package ems.dto;
import jakarta.validation.constraints.NotBlank; import jakarta.validation.constraints.Size; import java.time.LocalDate;
public record ProjectRequest(@NotBlank @Size(max=180) String projectName,@Size(max=5000) String description,LocalDate startDate,LocalDate endDate,@NotBlank String status) {}
