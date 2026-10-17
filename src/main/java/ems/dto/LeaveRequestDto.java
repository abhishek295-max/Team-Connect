package ems.dto;
import jakarta.validation.constraints.*; import java.time.LocalDate;
public record LeaveRequestDto(@NotNull LocalDate startDate,@NotNull LocalDate endDate,@NotBlank String leaveType,@Size(max=1000) String reason) {}
