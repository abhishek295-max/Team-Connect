package ems.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity @Table(name="projects")
public class Project {
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
    @Column(name="project_name", nullable=false) private String projectName;
    private String description; @Column(name="start_date") private LocalDate startDate; @Column(name="end_date") private LocalDate endDate;
    @Column(name="team_connect_channel_id") private Integer teamConnectChannelId; @Column(nullable=false) private String status="ACTIVE";
    public Long getId(){return id;} public String getProjectName(){return projectName;} public void setProjectName(String v){projectName=v;}
    public String getDescription(){return description;} public void setDescription(String v){description=v;} public LocalDate getStartDate(){return startDate;} public void setStartDate(LocalDate v){startDate=v;}
    public LocalDate getEndDate(){return endDate;} public void setEndDate(LocalDate v){endDate=v;} public Integer getTeamConnectChannelId(){return teamConnectChannelId;} public void setTeamConnectChannelId(Integer v){teamConnectChannelId=v;}
    public String getStatus(){return status;} public void setStatus(String v){status=v;}
}
