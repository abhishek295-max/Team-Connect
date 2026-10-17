package ems.repository;
import ems.model.EmployeeDocument; import org.springframework.data.jpa.repository.JpaRepository; import java.util.List;
public interface EmployeeDocumentRepository extends JpaRepository<EmployeeDocument,Long>{List<EmployeeDocument> findByEmployeeIdOrderByUploadedAtDesc(Long id);}
