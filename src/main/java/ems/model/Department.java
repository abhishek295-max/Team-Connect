package ems.model;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "departments")
public class Department {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(nullable = false, unique = true, length = 160) private String name;
    private String description;
    @Column(name = "team_connect_channel_id") private Integer teamConnectChannelId;
    @Column(name = "created_at", insertable = false, updatable = false) private Instant createdAt;
    @Column(name = "updated_at", insertable = false, updatable = false) private Instant updatedAt;
    public Long getId(){return id;} public String getName(){return name;} public void setName(String v){name=v;}
    public String getDescription(){return description;} public void setDescription(String v){description=v;}
    public Integer getTeamConnectChannelId(){return teamConnectChannelId;} public void setTeamConnectChannelId(Integer v){teamConnectChannelId=v;}
}
