package ems.model;

import jakarta.persistence.*;
import java.time.*;

@Entity @Table(name="leave_requests")
public class LeaveRequest {
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id; @Column(name="employee_id",nullable=false) private Long employeeId;
    @Column(name="start_date",nullable=false) private LocalDate startDate; @Column(name="end_date",nullable=false) private LocalDate endDate; @Column(name="leave_type",nullable=false) private String leaveType;
    private String reason; @Column(nullable=false) private String status="PENDING"; @Column(name="reviewed_by") private Integer reviewedBy; @Column(name="applied_on",insertable=false,updatable=false) private Instant appliedOn;
    public Long getId(){return id;} public Long getEmployeeId(){return employeeId;} public void setEmployeeId(Long v){employeeId=v;} public LocalDate getStartDate(){return startDate;} public void setStartDate(LocalDate v){startDate=v;} public LocalDate getEndDate(){return endDate;} public void setEndDate(LocalDate v){endDate=v;} public String getLeaveType(){return leaveType;} public void setLeaveType(String v){leaveType=v;} public String getReason(){return reason;} public void setReason(String v){reason=v;} public String getStatus(){return status;} public void setStatus(String v){status=v;} public Integer getReviewedBy(){return reviewedBy;} public void setReviewedBy(Integer v){reviewedBy=v;}
}
