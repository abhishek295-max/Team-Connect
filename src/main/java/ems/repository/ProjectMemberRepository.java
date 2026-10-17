package ems.repository;
import ems.model.ProjectMember; import org.springframework.data.jpa.repository.JpaRepository; import java.util.List;
public interface ProjectMemberRepository extends JpaRepository<ProjectMember,ProjectMember.Id>{List<ProjectMember> findByIdEmployeeId(Long id); List<ProjectMember> findByIdProjectId(Long id);}
