package ems.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "employees")
public class Employee {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name="ems_employee_id", unique=true) private Long emsEmployeeId;
    @Column(name="team_connect_user_id") private Integer teamConnectUserId;
    @ManyToOne(fetch=FetchType.LAZY) @JoinColumn(name="department_id") private Department department;
    @Column(nullable=false) private String name;
    @Column(nullable=false) private String email;
    private String phone; private String gender;
    @Column(name="job_title") private String jobTitle;
    @Column(name="hire_date") private LocalDate hireDate;
    private BigDecimal salary; private String address;
    @Column(nullable=false) private String role="EMPLOYEE";
    @Column(nullable=false) private String status="ACTIVE";
    public Long getId(){return id;} public Long getEmsEmployeeId(){return emsEmployeeId;} public void setEmsEmployeeId(Long v){emsEmployeeId=v;}
    public Integer getTeamConnectUserId(){return teamConnectUserId;} public void setTeamConnectUserId(Integer v){teamConnectUserId=v;}
    public Department getDepartment(){return department;} public void setDepartment(Department v){department=v;}
    public String getName(){return name;} public void setName(String v){name=v;} public String getEmail(){return email;} public void setEmail(String v){email=v;}
    public String getPhone(){return phone;} public void setPhone(String v){phone=v;} public String getGender(){return gender;} public void setGender(String v){gender=v;}
    public String getJobTitle(){return jobTitle;} public void setJobTitle(String v){jobTitle=v;} public LocalDate getHireDate(){return hireDate;} public void setHireDate(LocalDate v){hireDate=v;}
    public BigDecimal getSalary(){return salary;} public void setSalary(BigDecimal v){salary=v;} public String getAddress(){return address;} public void setAddress(String v){address=v;}
    public String getRole(){return role;} public void setRole(String v){role=v;} public String getStatus(){return status;} public void setStatus(String v){status=v;}
}
