package ems.model;

import jakarta.persistence.*;
import java.math.BigDecimal; import java.time.LocalDate;

@Entity @Table(name="performance_reviews")
public class PerformanceReview {
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id; @Column(name="employee_id",nullable=false) private Long employeeId; @Column(name="reviewer_employee_id") private Long reviewerEmployeeId; private BigDecimal rating; @Column(name="review_content") private String reviewContent; @Column(name="review_date",nullable=false) private LocalDate reviewDate; @Column(nullable=false) private String status="PUBLISHED";
    public Long getId(){return id;} public Long getEmployeeId(){return employeeId;} public void setEmployeeId(Long v){employeeId=v;} public Long getReviewerEmployeeId(){return reviewerEmployeeId;} public void setReviewerEmployeeId(Long v){reviewerEmployeeId=v;} public BigDecimal getRating(){return rating;} public void setRating(BigDecimal v){rating=v;} public String getReviewContent(){return reviewContent;} public void setReviewContent(String v){reviewContent=v;} public LocalDate getReviewDate(){return reviewDate;} public void setReviewDate(LocalDate v){reviewDate=v;} public String getStatus(){return status;} public void setStatus(String v){status=v;}
}
