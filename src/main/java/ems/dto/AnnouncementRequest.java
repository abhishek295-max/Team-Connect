package ems.dto;
import jakarta.validation.constraints.*;
public record AnnouncementRequest(@NotBlank @Size(max=180) String title,@NotBlank @Size(max=10000) String body,@NotBlank String audience) {}
