package ems.model;

import jakarta.persistence.*;
import java.time.Instant;

@Entity @Table(name="ems_announcements")
public class Announcement {
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id; @Column(nullable=false) private String title; @Column(nullable=false,columnDefinition="TEXT") private String body; @Column(nullable=false) private String audience="ALL"; @Column(name="created_by",nullable=false) private Integer createdBy; @Column(name="published_at",insertable=false,updatable=false) private Instant publishedAt;
    public Long getId(){return id;} public String getTitle(){return title;} public void setTitle(String v){title=v;} public String getBody(){return body;} public void setBody(String v){body=v;} public String getAudience(){return audience;} public void setAudience(String v){audience=v;} public Integer getCreatedBy(){return createdBy;} public void setCreatedBy(Integer v){createdBy=v;}
}
