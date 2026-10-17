package ems.model;

import jakarta.persistence.*;
import java.time.Instant;

@Entity @Table(name="documents")
public class EmployeeDocument {
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id; @Column(name="employee_id",nullable=false) private Long employeeId; @Column(name="original_name",nullable=false) private String originalName; @Column(name="storage_key",nullable=false,unique=true) private String storageKey; @Column(name="content_type",nullable=false) private String contentType; @Column(name="file_size",nullable=false) private long fileSize; @Column(name="uploaded_by",nullable=false) private Integer uploadedBy; @Column(name="uploaded_at",insertable=false,updatable=false) private Instant uploadedAt;
    public Long getId(){return id;} public Long getEmployeeId(){return employeeId;} public void setEmployeeId(Long v){employeeId=v;} public String getOriginalName(){return originalName;} public void setOriginalName(String v){originalName=v;} public String getStorageKey(){return storageKey;} public void setStorageKey(String v){storageKey=v;} public String getContentType(){return contentType;} public void setContentType(String v){contentType=v;} public long getFileSize(){return fileSize;} public void setFileSize(long v){fileSize=v;} public Integer getUploadedBy(){return uploadedBy;} public void setUploadedBy(Integer v){uploadedBy=v;}
}
