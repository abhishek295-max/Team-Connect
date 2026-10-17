package ems.model;

import jakarta.persistence.*;
import java.math.BigDecimal; import java.time.LocalDate;

@Entity @Table(name="salary_records")
public class SalaryRecord {
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id; @Column(name="employee_id",nullable=false) private Long employeeId;
    @Column(nullable=false,precision=15,scale=2) private BigDecimal amount; @Column(name="payment_date",nullable=false) private LocalDate paymentDate; @Column(name="period_label") private String periodLabel; @Column(nullable=false) private String status="PROCESSED"; private String notes;
    public Long getId(){return id;} public Long getEmployeeId(){return employeeId;} public void setEmployeeId(Long v){employeeId=v;} public BigDecimal getAmount(){return amount;} public void setAmount(BigDecimal v){amount=v;} public LocalDate getPaymentDate(){return paymentDate;} public void setPaymentDate(LocalDate v){paymentDate=v;} public String getPeriodLabel(){return periodLabel;} public void setPeriodLabel(String v){periodLabel=v;} public String getStatus(){return status;} public void setStatus(String v){status=v;} public String getNotes(){return notes;} public void setNotes(String v){notes=v;}
}
