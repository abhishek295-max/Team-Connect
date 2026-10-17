package ems.dto;
import jakarta.validation.constraints.*; import java.math.BigDecimal; import java.time.LocalDate;
public record EmployeeRequest(@NotBlank @Size(max=160) String name,@NotBlank @Email @Size(max=255) String email,@Size(max=40) String phone,String gender,String jobTitle,LocalDate hireDate,@DecimalMin("0.0") BigDecimal salary,@Size(max=500) String address,@NotBlank String role,@NotBlank String status,Long departmentId,Long emsEmployeeId,Integer teamConnectUserId) {}
