package ems.model;

import jakarta.persistence.*;

@Entity @Table(name="project_members")
public class ProjectMember {
    @EmbeddedId private Id id;
    public ProjectMember(){} public ProjectMember(Long projectId, Long employeeId){id=new Id(projectId,employeeId);}
    public Id getId(){return id;}
    @Embeddable public static class Id implements java.io.Serializable {
        @Column(name="project_id") private Long projectId; @Column(name="employee_id") private Long employeeId;
        public Id(){} public Id(Long p,Long e){projectId=p;employeeId=e;} public Long getProjectId(){return projectId;} public Long getEmployeeId(){return employeeId;}
        public boolean equals(Object o){if(this==o)return true;if(!(o instanceof Id x))return false;return java.util.Objects.equals(projectId,x.projectId)&&java.util.Objects.equals(employeeId,x.employeeId);}
        public int hashCode(){return java.util.Objects.hash(projectId,employeeId);}
    }
}
