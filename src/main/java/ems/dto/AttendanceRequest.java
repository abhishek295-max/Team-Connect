package ems.dto;
import jakarta.validation.constraints.*; import java.time.*;
public record AttendanceRequest(@NotNull Long employeeId,@NotNull LocalDate date,@NotBlank String status,LocalTime checkIn,LocalTime checkOut,@Size(max=500) String notes) {}
