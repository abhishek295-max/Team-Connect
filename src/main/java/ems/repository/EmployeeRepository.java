package ems.repository;
import ems.model.Employee; import org.springframework.data.jpa.repository.EntityGraph; import org.springframework.data.jpa.repository.JpaRepository; import java.util.*;
public interface EmployeeRepository extends JpaRepository<Employee,Long>{
    @Override @EntityGraph(attributePaths="department")
    Optional<Employee> findById(Long id);
    @EntityGraph(attributePaths="department")
    Optional<Employee> findByTeamConnectUserId(Integer id);
    Optional<Employee> findByEmsEmployeeId(Long id);
    Optional<Employee> findByEmailIgnoreCase(String email);
    @EntityGraph(attributePaths="department")
    List<Employee> findAllByOrderByNameAsc();
    long countByDepartment_Id(Long departmentId);
}
