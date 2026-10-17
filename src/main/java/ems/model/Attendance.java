package ems.model;

import jakarta.persistence.*;
import java.time.*;

@Entity @Table(name="attendance")
public class Attendance {
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id; @Column(name="employee_id",nullable=false) private Long employeeId;
    @Column(name="date",nullable=false) private LocalDate date; @Column(nullable=false) private String status; @Column(name="check_in") private LocalTime checkIn; @Column(name="check_out") private LocalTime checkOut; private String notes;
    public Long getId(){return id;} public Long getEmployeeId(){return employeeId;} public void setEmployeeId(Long v){employeeId=v;} public LocalDate getDate(){return date;} public void setDate(LocalDate v){date=v;} public String getStatus(){return status;} public void setStatus(String v){status=v;} public LocalTime getCheckIn(){return checkIn;} public void setCheckIn(LocalTime v){checkIn=v;} public LocalTime getCheckOut(){return checkOut;} public void setCheckOut(LocalTime v){checkOut=v;} public String getNotes(){return notes;} public void setNotes(String v){notes=v;}
}
